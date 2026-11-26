import Domain
import Observation

@Observable
@MainActor
public final class LockedContentViewModel {
    public let track: Track

    private let billing: any BillingRepository

    public init(track: Track, billing: any BillingRepository) {
        self.track = track
        self.billing = billing
    }

    /// Devuelve `true` si la hoja puede cerrarse.
    public func buyTrack() async -> Bool {
        do {
            try await billing.purchaseTrack(id: track.id)
            return true
        } catch {
            // Falta mostrar el error cuando exista la compra real con StoreKit.
            return false
        }
    }
}

@Observable
@MainActor
public final class AlbumPurchaseViewModel {
    public let album: Album

    private let billing: any BillingRepository

    public init(album: Album, billing: any BillingRepository) {
        self.album = album
        self.billing = billing
    }

    /// Devuelve `true` si la hoja puede cerrarse.
    public func buyAlbum() async -> Bool {
        do {
            try await billing.purchaseAlbum(id: album.id)
            return true
        } catch {
            // Falta mostrar el error cuando exista la compra real con StoreKit.
            return false
        }
    }
}

@Observable
@MainActor
public final class PaywallViewModel {
    public var selectedPlan: Plan.Interval = .annual
    public private(set) var state: LoadState<[Plan]> = .idle

    private let billing: any BillingRepository

    public init(billing: any BillingRepository) {
        self.billing = billing
    }

    public func load() async {
        state = state.reloading
        do {
            state = .loaded(try await billing.plans())
        } catch is CancellationError {
            return
        } catch {
            state = .failed
        }
    }

    /// Ahorro del plan anual frente a doce mensualidades, en porcentaje entero.
    public var annualSavingsPercent: Int? {
        guard let plans = state.value,
              let monthly = plans.first(where: { $0.interval == .monthly }),
              let annual = plans.first(where: { $0.interval == .annual }),
              monthly.price.currencyCode == annual.price.currencyCode
        else { return nil }
        let yearly = monthly.price.cents * 12
        guard yearly > annual.price.cents else { return nil }
        return Int((Double(yearly - annual.price.cents) / Double(yearly) * 100).rounded())
    }

    /// Devuelve `true` si el muro de pago puede cerrarse.
    public func subscribe() async -> Bool {
        guard let plan = state.value?.first(where: { $0.interval == selectedPlan }) else { return false }
        do {
            try await billing.subscribe(toPlan: plan.id)
            return true
        } catch {
            // Falta mostrar el error cuando exista la compra real con StoreKit.
            return false
        }
    }

    public func restorePurchases() async {
        // Con datos de ejemplo no cambia nada. Falta mostrar el resultado con StoreKit.
        try? await billing.restorePurchases()
    }
}
