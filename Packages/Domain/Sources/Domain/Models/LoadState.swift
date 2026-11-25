/// Estado de una carga asíncrona que una vista puede representar.
public enum LoadState<Value: Sendable>: Sendable {
    case idle
    case loading
    case loaded(Value)
    case failed

    public var value: Value? {
        if case .loaded(let value) = self { value } else { nil }
    }

    public var hasFailed: Bool {
        if case .failed = self { true } else { false }
    }

    /// Estado al empezar una carga: conserva el contenido ya mostrado.
    public var reloading: LoadState {
        if case .loaded = self { self } else { .loading }
    }
}
