import MediaPlayer

/// Órdenes de la pantalla de bloqueo, el Centro de control y los auriculares.
enum RemoteCommand: Equatable, Sendable {
    case play
    case pause
    case togglePlayPause
    case seek(seconds: Double)
}

@MainActor
protocol RemoteCommandHandling: AnyObject {
    var onCommand: (@MainActor (RemoteCommand) -> Void)? { get set }

    func enable()
    func disable()
}

@MainActor
final class SystemRemoteCommandController: RemoteCommandHandling {
    var onCommand: (@MainActor (RemoteCommand) -> Void)?

    private var isRegistered = false

    func enable() {
        register()
        setEnabled(true)

        // Todavía no hay cola de reproducción.
        let center = MPRemoteCommandCenter.shared()
        center.nextTrackCommand.isEnabled = false
        center.previousTrackCommand.isEnabled = false
        center.skipForwardCommand.isEnabled = false
        center.skipBackwardCommand.isEnabled = false
    }

    func disable() {
        guard isRegistered else { return }
        setEnabled(false)
    }

    private func setEnabled(_ isEnabled: Bool) {
        let center = MPRemoteCommandCenter.shared()
        center.playCommand.isEnabled = isEnabled
        center.pauseCommand.isEnabled = isEnabled
        center.togglePlayPauseCommand.isEnabled = isEnabled
        center.changePlaybackPositionCommand.isEnabled = isEnabled
    }

    private func register() {
        guard !isRegistered else { return }
        isRegistered = true

        let center = MPRemoteCommandCenter.shared()
        addTarget(center.playCommand, sending: .play)
        addTarget(center.pauseCommand, sending: .pause)
        addTarget(center.togglePlayPauseCommand, sending: .togglePlayPause)

        // `@Sendable` impide que el cierre herede el actor principal: el sistema no garantiza
        // el hilo y un cierre aislado fallaría en ejecución.
        center.changePlaybackPositionCommand.addTarget { @Sendable [weak self] event in
            guard let event = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
            let seconds = event.positionTime
            Task { @MainActor [weak self] in
                self?.onCommand?(.seek(seconds: seconds))
            }
            return .success
        }
    }

    private func addTarget(_ command: MPRemoteCommand, sending remoteCommand: RemoteCommand) {
        command.addTarget { @Sendable [weak self] _ in
            Task { @MainActor [weak self] in
                self?.onCommand?(remoteCommand)
            }
            return .success
        }
    }
}
