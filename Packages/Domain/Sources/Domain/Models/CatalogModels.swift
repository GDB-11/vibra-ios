import Foundation

/// Importe en centavos enteros con su código de moneda ISO 4217.
public struct Money: Hashable, Sendable {
    public let cents: Int
    public let currencyCode: String

    public init(cents: Int, currencyCode: String) {
        self.cents = cents
        self.currencyCode = currencyCode
    }

    /// Importe formateado según la configuración regional del dispositivo.
    public var formatted: String {
        (Decimal(cents) / 100).formatted(.currency(code: currencyCode))
    }
}

public struct Artist: Identifiable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let genre: String
    public let origin: String
    public let albumCount: Int
    /// Tono (0–359) de la portada provisional mientras no haya imágenes reales.
    public let artworkHue: Int

    public init(id: String, name: String, genre: String, origin: String, albumCount: Int, artworkHue: Int) {
        self.id = id
        self.name = name
        self.genre = genre
        self.origin = origin
        self.albumCount = albumCount
        self.artworkHue = artworkHue
    }
}

public struct Album: Identifiable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let artistID: String
    public let artistName: String
    public let year: Int
    public let trackCount: Int
    public let price: Money
    public let storeProductID: String?
    /// Respuesta del backend sobre los derechos del usuario. La app nunca la calcula.
    public let isLocked: Bool
    public let artworkHue: Int

    public init(
        id: String,
        title: String,
        artistID: String,
        artistName: String,
        year: Int,
        trackCount: Int,
        price: Money,
        storeProductID: String?,
        isLocked: Bool,
        artworkHue: Int
    ) {
        self.id = id
        self.title = title
        self.artistID = artistID
        self.artistName = artistName
        self.year = year
        self.trackCount = trackCount
        self.price = price
        self.storeProductID = storeProductID
        self.isLocked = isLocked
        self.artworkHue = artworkHue
    }
}

public struct Track: Identifiable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let albumID: String
    public let albumTitle: String
    public let artistName: String
    public let number: Int
    public let durationSeconds: Int
    public let price: Money
    public let storeProductID: String?
    /// Respuesta del backend sobre los derechos del usuario. La app nunca la calcula.
    public let isLocked: Bool
    public let artworkHue: Int

    public init(
        id: String,
        title: String,
        albumID: String,
        albumTitle: String,
        artistName: String,
        number: Int,
        durationSeconds: Int,
        price: Money,
        storeProductID: String?,
        isLocked: Bool,
        artworkHue: Int
    ) {
        self.id = id
        self.title = title
        self.albumID = albumID
        self.albumTitle = albumTitle
        self.artistName = artistName
        self.number = number
        self.durationSeconds = durationSeconds
        self.price = price
        self.storeProductID = storeProductID
        self.isLocked = isLocked
        self.artworkHue = artworkHue
    }
}

public struct Playlist: Identifiable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let trackCount: Int
    public let artworkHue: Int

    public init(id: String, name: String, trackCount: Int, artworkHue: Int) {
        self.id = id
        self.name = name
        self.trackCount = trackCount
        self.artworkHue = artworkHue
    }
}

/// Página de resultados con paginación por cursor.
public struct Page<Item: Sendable>: Sendable {
    public let items: [Item]
    /// `nil` cuando no hay más páginas.
    public let nextCursor: String?

    public init(items: [Item], nextCursor: String? = nil) {
        self.items = items
        self.nextCursor = nextCursor
    }
}

extension Int {
    /// Segundos en formato `m:ss`.
    public var formattedAsTrackTime: String {
        Duration.seconds(self).formatted(.time(pattern: .minuteSecond))
    }
}
