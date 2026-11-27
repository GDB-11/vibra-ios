// TEMPORAL: ver PENDIENTE-fuente-de-audio.md para sustituirlo por la fuente real.
#if DEBUG
import Domain
import Foundation
import SwiftUI

nonisolated struct DebugStreamNotConfiguredError: Error {}

/// Fuente de audio de depuración: todas las pistas suenan con la URL pegada a mano.
///
/// La URL solo vive en memoria. Nunca se guarda, se muestra ni se registra.
actor DebugStreamingRepository: StreamingRepository {
    private var url: URL?

    /// Devuelve `false` si el texto no es una URL `https`.
    func setURL(from text: String) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = URL(string: trimmed), url.scheme == "https", url.host() != nil else { return false }
        self.url = url
        return true
    }

    func streamAccess(trackID: String) async throws -> StreamAccess {
        guard let url else { throw DebugStreamNotConfiguredError() }
        let isLocked = SampleData.tracks.first { $0.id == trackID }?.isLocked ?? false
        return isLocked ? .locked(previewURL: url) : .granted(url: url)
    }
}

/// Botón que abre el campo para pegar la URL firmada.
struct DebugStreamButton: View {
    let repository: DebugStreamingRepository

    @State private var isPresented = false

    var body: some View {
        Button(String(localized: "Audio (DEBUG)")) {
            isPresented = true
        }
        .font(.caption.bold())
        .buttonStyle(.bordered)
        .sheet(isPresented: $isPresented) {
            DebugStreamForm(repository: repository)
                .presentationDetents([.medium])
        }
    }
}

private struct DebugStreamForm: View {
    let repository: DebugStreamingRepository

    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    @State private var isInvalid = false

    var body: some View {
        Form {
            Section {
                SecureField(String(localized: "Pega la URL firmada"), text: $text)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                if isInvalid {
                    Text(String(localized: "La URL no es válida."))
                        .foregroundStyle(.red)
                }
                Button(String(localized: "Usar esta URL")) {
                    Task { await save() }
                }
                .disabled(text.isEmpty)
            } footer: {
                Text(String(localized: "Después, toca una canción. La URL se olvida al cerrar la app."))
            }
        }
    }

    private func save() async {
        if await repository.setURL(from: text) {
            text = ""
            dismiss()
        } else {
            isInvalid = true
        }
    }
}
#endif
