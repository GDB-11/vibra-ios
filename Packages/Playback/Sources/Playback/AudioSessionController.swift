import AVFoundation

/// Cambios del sistema que afectan a la reproducción.
enum AudioSessionEvent: Equatable, Sendable {
    /// Empieza una interrupción, como una llamada o Siri.
    case interruptionBegan
    case interruptionEnded(shouldResume: Bool)
    /// Se desconectó la salida de audio en uso, como unos auriculares.
    case outputDeviceRemoved

    init?(interruption userInfo: [AnyHashable: Any]?) {
        guard let rawType = userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: rawType)
        else { return nil }

        switch type {
        case .began:
            self = .interruptionBegan
        case .ended:
            let rawOptions = userInfo?[AVAudioSessionInterruptionOptionKey] as? UInt ?? 0
            let options = AVAudioSession.InterruptionOptions(rawValue: rawOptions)
            self = .interruptionEnded(shouldResume: options.contains(.shouldResume))
        @unknown default:
            return nil
        }
    }

    init?(routeChange userInfo: [AnyHashable: Any]?) {
        guard let rawReason = userInfo?[AVAudioSessionRouteChangeReasonKey] as? UInt,
              AVAudioSession.RouteChangeReason(rawValue: rawReason) == .oldDeviceUnavailable
        else { return nil }

        self = .outputDeviceRemoved
    }
}

@MainActor
protocol AudioSessionControlling: AnyObject {
    var onEvent: (@MainActor (AudioSessionEvent) -> Void)? { get set }

    func activate() throws
    func deactivate()
}

/// `AVAudioSession` con la categoría `.playback`, necesaria para sonar en segundo plano.
@MainActor
final class SystemAudioSessionController: AudioSessionControlling {
    var onEvent: (@MainActor (AudioSessionEvent) -> Void)?

    private var interruptionObserver: Task<Void, Never>?
    private var routeObserver: Task<Void, Never>?

    init() {
        // `Notification` no es `Sendable`: se convierte en un evento antes de llegar al actor principal.
        interruptionObserver = Task { [weak self] in
            let events = NotificationCenter.default
                .notifications(named: AVAudioSession.interruptionNotification)
                .compactMap { AudioSessionEvent(interruption: $0.userInfo) }
            for await event in events {
                self?.onEvent?(event)
            }
        }
        routeObserver = Task { [weak self] in
            let events = NotificationCenter.default
                .notifications(named: AVAudioSession.routeChangeNotification)
                .compactMap { AudioSessionEvent(routeChange: $0.userInfo) }
            for await event in events {
                self?.onEvent?(event)
            }
        }
    }

    func activate() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playback, mode: .default)
        try session.setActive(true)
    }

    func deactivate() {
        // Si falla, la sesión queda activa sin sonar; no hay nada que el usuario pueda hacer.
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}
