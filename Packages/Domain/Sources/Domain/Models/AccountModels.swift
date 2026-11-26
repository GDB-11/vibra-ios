import Foundation

public struct UserProfile: Hashable, Sendable {
    public let displayName: String
    public let email: String

    public init(displayName: String, email: String) {
        self.displayName = displayName
        self.email = email
    }

    /// Iniciales para el avatar.
    public var initials: String {
        String(displayName.split(separator: " ").prefix(2).compactMap(\.first))
    }
}

public struct Plan: Identifiable, Hashable, Sendable {
    public enum Interval: String, Hashable, Sendable {
        case monthly
        case annual
    }

    /// Código público del plan (UUID); se envía como `planCode` al suscribirse.
    public let id: String
    public let interval: Interval
    public let price: Money

    public init(id: String, interval: Interval, price: Money) {
        self.id = id
        self.interval = interval
        self.price = price
    }
}

/// Derechos del usuario tal como los entrega el backend.
public struct Entitlements: Hashable, Sendable {
    public let hasActiveSubscription: Bool

    public init(hasActiveSubscription: Bool) {
        self.hasActiveSubscription = hasActiveSubscription
    }
}
