# Vibra iOS

App nativa de streaming de música (SwiftUI, Swift 6) para un curso de iOS. *Todo el catálogo, o solo lo que amas.*

## Requisitos

- Xcode 26.6 (build 17F113).
- Objetivo mínimo: iOS 26.5, el SDK más reciente de ese Xcode (confirmado el 2026-11-24).
- La app se ejecuta solo en el simulador.

## Estructura

| Ruta | Contenido |
|---|---|
| `Vibra/` | Objetivo delgado: composición, inyección de dependencias y navegación |
| `Packages/Domain` | Modelos y protocolos de repositorio, sin dependencias |
| `Packages/Networking` | Cliente de API y copia sincronizada del contrato |
| `Packages/Persistence` | Caché y metadatos de descargas |
| `Packages/Playback` | Reproducción de audio |
| `Packages/Store` | StoreKit 2 y derechos |
| `Packages/DesignSystem` | Colores, tipografías y vistas reutilizables |
| `Packages/Features` | Un objetivo `<Nombre>Feature` por funcionalidad |
| `Vibra.storekit` | Productos de prueba de StoreKit (todavía vacío) |

## Compilar y ejecutar

```bash
xcrun simctl list devices available
xcodebuild -scheme Vibra -destination 'platform=iOS Simulator,name=<simulador>' build
```

En Xcode, abre `Vibra.xcodeproj`, elige un simulador y pulsa ⌘R. Todavía no hay objetivos de prueba.

## Contrato de la API

```bash
./scripts/sync-contract.sh   # requiere vibra-contracts junto a este repositorio
```
