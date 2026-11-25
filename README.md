# Vibra iOS

App nativa de streaming de música (SwiftUI, Swift 6) para un curso de iOS. *Todo el catálogo, o solo lo que amas.*

## Estado actual

Están las pantallas del diseño (estilo Aeroglass sobre Liquid Glass) con navegación completa y datos de ejemplo. No hay lógica: sin red, sin audio y sin compras. Reproducir, saltar, "Me gusta", comprar y restaurar envían la intención, pero no cambian nada.

## Requisitos

- Xcode 26.6 (build 17F113).
- Objetivo mínimo: iOS 26.5, el SDK más reciente de ese Xcode (confirmado el 2026-11-24).
- La app se ejecuta solo en el simulador.

## Estructura

| Ruta | Contenido |
|---|---|
| `Vibra/` | Objetivo delgado: composición (`AppEnvironment`), navegación (`Navigation/`) y Live Activity |
| `VibraWidgets/` | Extensión con el widget "Reproduciendo ahora" y la Live Activity |
| `Config/` | `Info.plist` parcial de la extensión |
| `Packages/Domain` | Modelos, protocolos de repositorio y datos de ejemplo (`Samples/`), sin dependencias |
| `Packages/Networking` | Cliente de API y copia sincronizada del contrato |
| `Packages/Persistence` | Caché y metadatos de descargas |
| `Packages/Playback` | Reproducción de audio |
| `Packages/Store` | StoreKit 2 y derechos |
| `Packages/DesignSystem` | Colores y componentes Aeroglass |
| `Packages/Features` | Un objetivo `<Nombre>Feature` por funcionalidad |
| `Packages/WidgetShared` | Tipos compartidos entre la app y la extensión |
| `Vibra.storekit` | Productos de prueba de StoreKit (todavía vacío) |

## Pantallas

| Pantalla | Cómo llegar |
|---|---|
| Portada y acceso | Al abrir la app; "Comenzar" y después "Entrar" (no valida los campos) |
| Inicio, Buscar, Biblioteca, Cuenta | Barra de pestañas |
| Artista | Inicio → tarjeta "Destacado" |
| Álbum | Inicio o Artista → portada |
| Lista de reproducción | Biblioteca → Listas |
| Reproductor y minirreproductor | Tocar una canción sin candado (las de *Is This It*) |
| Contenido bloqueado | Tocar una canción con candado |
| Muro de pago | Insignia "Gratis", Cuenta → Suscripción, "Suscribirse" o "Comprar" en un álbum |

## Integrar el backend

1. Sincroniza el contrato y genera el cliente en `Networking`.
2. Implementa allí los protocolos de `Packages/Domain/Sources/Domain/Repositories`.
3. Sustituye los `Sample*` en `Vibra/AppEnvironment.swift`. El reproductor real (`PlaybackControlling`) saldrá de `Playback` y debe ser `@Observable`.
4. Revisa `MainShell.open(_:)`: el `403` de `streamAccess` debe abrir la hoja de bloqueo con su `previewUrl`.
5. Revisa los comentarios "Falta mostrar el error" en los ViewModels.

`isLocked` representa la respuesta del backend; la app no calcula derechos. Los modelos de `Domain` se definieron a partir de `vibra-docs`, porque el contrato todavía no tiene endpoints; ajústalos cuando existan.

## Widget y Live Activity

- **Widget:** ejecuta la app y, en la pantalla de inicio del simulador, añade el widget mediano de Vibra. Muestra datos fijos.
- **Live Activity:** abre una canción y bloquea el simulador (⌘L). También aparece en la Dynamic Island si el simulador la tiene. Se cierra al cerrar sesión.
- Tocar cualquiera de las dos abre el reproductor, siempre que haya sesión.
- Sus controles son solo visuales (harían falta App Intents). Los controles multimedia del sistema llegarán con la reproducción real (`MPNowPlayingInfoCenter`).
- Todavía no hay App Group; se necesitará cuando el widget muestre datos reales.

## Compilar y ejecutar

```bash
xcrun simctl list devices available
xcodebuild -scheme Vibra -destination 'platform=iOS Simulator,name=<simulador>' build
```

En Xcode, abre `Vibra.xcodeproj`, elige un simulador y pulsa ⌘R.

## Pruebas

`FeaturesTests` cubre los ViewModels con los datos de ejemplo. Los paquetes son solo para iOS, así que `swift test` en macOS no sirve:

```bash
cd Packages/Features
xcodebuild -list   # muestra el nombre del esquema
xcodebuild -scheme <esquema> -destination 'platform=iOS Simulator,name=<simulador>' test
```

## Contrato de la API

```bash
./scripts/sync-contract.sh   # requiere vibra-contracts junto a este repositorio
```
