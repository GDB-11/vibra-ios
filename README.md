# Vibra iOS

App nativa de streaming de música (SwiftUI, Swift 6) para un curso de iOS. *Todo el catálogo, o solo lo que amas.*

## Estado actual

Están las pantallas del diseño (estilo Aeroglass sobre Liquid Glass) con navegación completa y datos de ejemplo. Sin red y sin compras: "Me gusta", comprar y restaurar envían la intención, pero no cambian nada.

El reproductor es real (`PlaybackService`), con audio en segundo plano. Todavía no hay cola, así que saltar de canción no hace nada.

> **Pendiente:** la fuente de audio es temporal. Ver [PENDIENTE-fuente-de-audio.md](PENDIENTE-fuente-de-audio.md).

## Probar el audio (solo Debug)

1. Entra en la app, toca **Audio (DEBUG)** y pega una URL firmada `https`. Usa una vigencia mayor que la duración de la pista.
2. Toca una canción. Todas suenan con ese archivo; en una vista previa tampoco se corta a los 30 s.

Sin una URL, el reproductor queda vacío. La URL se olvida al cerrar la app. No la guardes en el repositorio, en notas ni en capturas, y revisa los registros de la consola antes de compartirlos.

## Requisitos

- Xcode 26.6 (build 17F113).
- Objetivo mínimo: iOS 26.5, el SDK más reciente de ese Xcode (confirmado el 2026-11-24).
- La app se ejecuta solo en el simulador.

## Estructura

| Ruta | Contenido |
|---|---|
| `Vibra/` | Objetivo delgado: composición (`AppEnvironment`), navegación (`Navigation/`) y Live Activity |
| `VibraWidgets/` | Extensión con el widget "Reproduciendo ahora" y la Live Activity |
| `Config/` | `Info.plist` parciales de la app (modo de fondo de audio) y de la extensión |
| `Packages/Domain` | Modelos, protocolos de repositorio y datos de ejemplo (`Samples/`), sin dependencias |
| `Packages/Networking` | Cliente de API y copia sincronizada del contrato |
| `Packages/Persistence` | Caché y metadatos de descargas |
| `Packages/Playback` | `PlaybackService`: `AVPlayer`, sesión de audio, Now Playing y comandos remotos |
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
| Compra de álbum | "Comprar" en un álbum bloqueado: comprarlo para siempre o suscribirse |
| Muro de pago | Insignia "Gratis", Cuenta → Suscripción o "Suscribirse" en las hojas de compra y de contenido bloqueado |

## Integrar el backend

1. Sincroniza el contrato y genera el cliente en `Networking`.
2. Implementa allí los protocolos de `Packages/Domain/Sources/Domain/Repositories`.
3. Sustituye los `Sample*` en `Vibra/AppEnvironment.swift`. El reproductor ya es el de `Playback`; la fuente de audio se sustituye según [PENDIENTE-fuente-de-audio.md](PENDIENTE-fuente-de-audio.md).
4. Revisa `MainShell.open(_:)`: el `403` de `streamAccess` debe abrir la hoja de bloqueo con su `previewUrl`.
5. Revisa los comentarios "Falta mostrar el error" en los ViewModels.

`isLocked` representa la respuesta del backend; la app no calcula derechos. Los modelos de `Domain` se definieron a partir de `vibra-docs`, porque el contrato todavía no tiene endpoints; ajústalos cuando existan.

## Widget y Live Activity

- **Widget:** ejecuta la app y, en la pantalla de inicio del simulador, añade el widget mediano de Vibra. Muestra datos fijos.
- **Live Activity:** abre una canción y bloquea el simulador (⌘L). También aparece en la Dynamic Island si el simulador la tiene. Se cierra al cerrar sesión.
- Tocar cualquiera de las dos abre el reproductor, siempre que haya sesión.
- Sus controles son solo visuales (harían falta App Intents). Los controles multimedia del sistema (reproducir, pausar y mover la posición) los da `PlaybackService`.
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
xcodebuild -scheme Features -destination 'platform=iOS Simulator,name=<simulador>' test
```

`PlaybackTests` cubre `PlaybackService` con dobles de prueba, sin red ni audio:

```bash
cd Packages/Playback
xcodebuild -scheme Playback -destination 'platform=iOS Simulator,name=<simulador>' test
```

## Contrato de la API

```bash
./scripts/sync-contract.sh   # requiere vibra-contracts junto a este repositorio
```
