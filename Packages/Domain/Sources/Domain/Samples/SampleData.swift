/// Datos fijos del diseño, usados mientras el backend no está disponible y en las vistas previas.
public enum SampleData {
    public static let user = UserProfile(displayName: "Julián Souza", email: "julian@vibra.demo")

    public static let entitlements = Entitlements(hasActiveSubscription: false)

    public static let plans = [
        Plan(code: .monthly, price: usd(999)),
        Plan(code: .annual, price: usd(8999))
    ]

    public static let artist = Artist(
        id: "strokes",
        name: "The Strokes",
        genre: "Rock indie",
        origin: "Nueva York",
        albumCount: 6,
        artworkHue: 205
    )

    private struct AlbumSeed: Sendable {
        let id: String
        let title: String
        let year: Int
        let hue: Int
        let isLocked: Bool
        let tracks: [String]
    }

    private static let seeds = [
        AlbumSeed(
            id: "itit", title: "Is This It", year: 2001, hue: 205, isLocked: false,
            tracks: ["Is This It", "The Modern Age", "Last Nite", "Someday", "Hard to Explain"]
        ),
        AlbumSeed(
            id: "rof", title: "Room on Fire", year: 2003, hue: 262, isLocked: true,
            tracks: ["Reptilia", "12:51", "Under Control", "The End Has No End"]
        ),
        AlbumSeed(
            id: "fioe", title: "First Impressions of Earth", year: 2006, hue: 18, isLocked: true,
            tracks: ["You Only Live Once", "Juicebox", "Heart in a Cage", "Razorblade"]
        ),
        AlbumSeed(
            id: "angles", title: "Angles", year: 2011, hue: 328, isLocked: true,
            tracks: ["Machu Picchu", "Under Cover of Darkness", "Taken for a Fool", "Life Is Simple in the Moonlight"]
        ),
        AlbumSeed(
            id: "cm", title: "Comedown Machine", year: 2013, hue: 142, isLocked: true,
            tracks: ["All the Time", "One Way Trigger", "Welcome to Japan", "80's Comedown Machine"]
        ),
        AlbumSeed(
            id: "tna", title: "The New Abnormal", year: 2020, hue: 42, isLocked: true,
            tracks: ["The Adults Are Talking", "Bad Decisions", "Selfless", "At the Door"]
        )
    ]

    public static let albums: [Album] = seeds.map { seed in
        Album(
            id: seed.id,
            title: seed.title,
            artistID: artist.id,
            artistName: artist.name,
            year: seed.year,
            trackCount: seed.tracks.count,
            price: usd(999),
            storeProductID: nil,
            isLocked: seed.isLocked,
            artworkHue: seed.hue
        )
    }

    public static let tracks: [Track] = seeds.flatMap { seed in
        seed.tracks.enumerated().map { index, title in
            let durations = [192, 214, 178, 245, 201]
            return Track(
                id: "\(seed.id)-\(index)",
                title: title,
                albumID: seed.id,
                albumTitle: seed.title,
                artistName: artist.name,
                number: index + 1,
                durationSeconds: durations[index % durations.count],
                price: usd(129),
                storeProductID: nil,
                isLocked: seed.isLocked,
                artworkHue: seed.hue
            )
        }
    }

    public static let likedTracks = lookUp(["itit-2", "itit-3", "rof-0"])

    public static let recentlyPlayed = lookUp(["itit-2", "itit-0", "tna-1"])

    public static let playlists = [
        Playlist(id: "favorites", name: "Mis favoritos", trackCount: likedTracks.count, artworkHue: 205),
        Playlist(id: "indie", name: "Indie de los 2000", trackCount: 9, artworkHue: 262),
        Playlist(id: "gym", name: "Para el gimnasio", trackCount: 12, artworkHue: 18)
    ]

    public static func playlistTracks(id: String) -> [Track] {
        switch id {
        case "favorites": likedTracks
        case "indie": Array(tracks.prefix(9))
        case "gym": Array(tracks.suffix(12))
        default: []
        }
    }

    private static func lookUp(_ ids: [String]) -> [Track] {
        ids.compactMap { id in tracks.first { $0.id == id } }
    }

    private static func usd(_ cents: Int) -> Money {
        Money(cents: cents, currencyCode: "USD")
    }
}
