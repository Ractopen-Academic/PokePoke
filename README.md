# PokéPoke

[![Flutter](https://img.shields.io/badge/Flutter-3.13+-02569B?style=flat&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=flat&logo=dart&logoColor=white)](https://dart.dev)
[![Platforms](https://img.shields.io/badge/Platform-Android%20%7C%20Linux%20%7C%20Web-3DDC84?style=flat&logo=android&logoColor=white)](https://flutter.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat)](LICENSE)

PokéPoke is a retro-inspired Pokémon companion mobile application developed using Flutter. It integrates NeoPoP brutalist design principles with real-time PokéAPI synchronization, height-proportional sprite sizing, interactive multi-stage evolution trees, and persistent local caching.

---

## Demonstration

```
+------------------------------------------------------------------------+
|                                                                        |
|                       DEMO VIDEO RECORDING                             |
|                                                                        |
|                   [ Video Placeholder: demo.mp4 ]                      |
|                                                                        |
|   Features Demonstrated:                                               |
|   - Splash screen with competitive trainer tips                        |
|   - Height-proportional Pokédex grid with real-time type filtering     |
|   - Wide evolution sheet with stage switching                          |
|   - Name and Pokédex ID search with PokéAPI online fallback            |
|   - Persistent favourites management with live badge updates           |
|                                                                        |
+------------------------------------------------------------------------+
```

---

## Features

- **Proportional Sizing**: Pokémon are scaled dynamically using their canonical Pokédex heights (ranging from 72 px for small species such as Caterpie to 125 px for larger species like Venusaur and Arbok). Sprites are anchored to the bottom-right corner to ensure visual consistency across grid cells.
- **Evolution and Detail Sheet**: Tapping a Pokémon displays an expandable modal sheet featuring species taxonomy, physical dimensions, ability lists, defensive weaknesses, lore descriptions, and an interactive evolution chain. Tapping evolution nodes transitions the sheet to inspect the target stage.
- **Specific Search with Online Fallback**: Supports immediate filtering by name or Pokédex number (`25`, `#025`, `pikachu`). If an entry does not exist locally, the integrated "Search Online" feature queries PokéAPI, indexes the response, and writes it to local storage.
- **Favourites System**: Allows toggling favourite status directly on cards or in the detail view. The state is synchronized across screens via a reactive notifier and persisted using local storage. The bottom navigation bar includes a live counter badge.
- **NeoPoP Design Architecture**: Implements tactile elevated surfaces, custom press animations, and high-contrast retro typography.
- **Offline Reliability**: Bundles a verified initial seed dataset and offline evolution mappings to ensure instant rendering without network dependencies.

---

## Tech Stack

| Technology | Badge | Description |
|:---|:---|:---|
| **Flutter SDK** | ![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat-square&logo=flutter&logoColor=white) | Application framework and UI runtime |
| **Dart** | ![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat-square&logo=dart&logoColor=white) | Core programming language |
| **NeoPoP** | ![NeoPoP](https://img.shields.io/badge/NeoPoP-FF1C1C?style=flat-square&logo=flutter&logoColor=white) | 3D neo-brutalist widget library |
| **PokéAPI** | ![PokéAPI](https://img.shields.io/badge/PokéAPI-EF5350?style=flat-square&logo=pokemon&logoColor=white) | RESTful web service for Pokémon data |
| **Google Fonts** | ![Google Fonts](https://img.shields.io/badge/Google%20Fonts-4285F4?style=flat-square&logo=google&logoColor=white) | Typography assets (`PressStart2P`, `Inter`) |
| **SharedPreferences** | ![SharedPreferences](https://img.shields.io/badge/Storage-4CAF50?style=flat-square&logo=sqlite&logoColor=white) | Key-value data persistence |
| **HTTP Networking** | ![HTTP](https://img.shields.io/badge/HTTP-009688?style=flat-square&logo=apache-http-server&logoColor=white) | Asynchronous client requests and network monitoring |

---

## Project Structure

```
pokepoke/
├── android/                             # Android platform configuration and manifest
├── linux/                               # Linux desktop build files and CMake configuration
├── web/                                 # Web platform entrypoint
├── assets/
│   └── images/
│       └── pokeball.svg                 # Vector asset for indicators and watermarks
├── lib/
│   ├── main.dart                        # Application entrypoint and orientation setup
│   ├── core/
│   │   ├── data/
│   │   │   ├── pokemon_seed.dart        # Offline starter dataset
│   │   │   └── pokemon_species_data.dart# Physical metrics, lore quotes, and abilities
│   │   ├── services/
│   │   │   ├── cache_service.dart       # SharedPreferences caching manager
│   │   │   ├── evolution_service.dart   # Offline and network evolution chain resolver
│   │   │   ├── favourite_service.dart   # ValueNotifier favourite state and storage
│   │   │   └── pokemon_service.dart     # PokéAPI client and sprite scaling logic
│   │   └── widgets/
│   │       ├── loadingscreen.dart       # Startup splash screen and trainer tips
│   │       └── loading_screen/
│   │           └── loading_screen.dart  # Vector rotation indicator
│   └── features/
│       └── dashboard/
│           ├── home/
│           │   ├── home_screen.dart     # Grid view, search, type filter, and navigation
│           │   └── widgets/
│           │       └── pokemon_detail_sheet.dart # Modal view with evolution pathway
│           └── favourite/
│               └── favourite_screen.dart# Saved items collection view
├── test/
│   ├── widget_test.dart                 # Size scaling boundary and calculation tests
│   └── favourite_test.dart              # Favourites service and persistence tests
├── pubspec.yaml                         # Dependency definitions and assets
└── gituser.md                           # Team attribution and contributor quotas
```

---

## Screen Specifications

### 1. Splash Screen (`SplashScreen`)
- Displays an animated vector indicator and randomized competitive gameplay notes during initialization.
- Loads seed data, verifies local cache integrity, and restores favourite identifiers before routing to the main interface.

### 2. Pokédex Feed (`HomeScreen`)
- Provides real-time query matching across name, Pokédex identifier, and elemental types.
- Renders responsive cards with type-based color themes, watermark vectors, and proportional artwork.
- Supports incremental pagination via dedicated request buttons.

### 3. Detail and Evolution Sheet (`PokemonDetailSheet`)
- Modal surface displaying category classifications, metric dimensions, ability profiles, and elemental weaknesses.
- Includes an animated central viewport and an interactive evolution tree detailing progression criteria (e.g., levels, evolutionary stones).

### 4. Favourites Screen (`FavouriteScreen`)
- Dedicated view presenting saved Pokémon records with individual search and removal capabilities.
- Synchronized globally using a reactive notifier.
- Includes an empty-state action returning the user to the primary Pokédex feed.

---

## Testing

The project maintains test coverage for proportional sizing algorithms and state persistence:

```bash
flutter analyze
flutter test
```

### Verified Scenarios:
- `test/widget_test.dart`: Validates relative scaling between species (e.g., Bulbasaur vs. Venusaur) and ensures size clamps between 72 px and 125 px.
- `test/favourite_test.dart`: Confirms state toggle transitions, listener broadcasts, and disk serialization/deserialization.

---

## Team Attribution

| Contributor | GitHub Account | Domain | Target Ratio |
|:---|:---|:---|:---:|
| **Ractopen** | `ractopen` | Architecture, backend services, caching, API sync, desktop runner | **60%** |
| **Kent John** | `kentjohnllanita8978-oss` | Controllers, navigation routing, unit testing | **20%** |
| **Roma** | `RomamasMPapas` | Interface design, NeoPoP integration, proportional layout | **10%** |
| **Jehlia** | `Jehlia-newcoder` | Favourites module, responsive toggles, badge counters | **10%** |

---

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
