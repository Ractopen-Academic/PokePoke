# PokéPoke

A retro-styled Pokémon companion mobile application developed with Flutter. It integrates NeoPoP brutalist design principles with real-time PokéAPI synchronization, height-proportional sprite sizing, interactive multi-stage evolution trees, and offline-first local persistence.

---

## Demo App

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

- **Proportional Size Scaling**: Pokémon are rendered according to their canonical Pokédex heights rather than identical bounding boxes (ranging from 72 px for smaller Pokémon like Caterpie to 125 px for larger Pokémon like Venusaur and Arbok). Sprites are anchored to the bottom-right corner to ensure uniform alignment within the grid.
- **Wide Evolution and Detail Sheet**: Selecting any Pokémon opens an expandable bottom sheet providing species taxonomy, metric dimensions, ability profiles, defensive weaknesses, lore descriptions, and an interactive evolution pathway. Selecting any evolutionary node immediately pivots the sheet to that target Pokémon.
- **Specific Search with Online Fallback**: Supports instantaneous filtering by name or Pokédex number (`25`, `#025`, `pikachu`). If an entry is not present in local storage, a dedicated "Search Online" action queries PokéAPI directly, indexes the response, and caches it locally.
- **Persistent Favourites System**: Direct heart toggles on cards and within the detail view allow users to bookmark Pokémon. State is synchronized across views via a reactive notifier and persisted through local storage. The bottom navigation bar displays a live item counter badge.
- **NeoPoP Design Architecture**: Employs elevated surfaces, custom press mechanics, and retro typography.
- **Offline Reliability**: Bundles a verified initial seed dataset and instant evolution mappings to ensure zero-latency initial rendering.

---

## Tech Stack

| Technology | Logo / Badge | Purpose |
|:---|:---|:---|
| **Flutter** | ![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white) | Application framework and UI runtime |
| **Dart** | ![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat&logo=dart&logoColor=white) | Core programming language |
| **NeoPoP** | ![NeoPoP](https://img.shields.io/badge/NeoPoP-FF1C1C?style=flat&logo=flutter&logoColor=white) | 3D neo-brutalist widget library |
| **PokéAPI** | ![PokéAPI](https://img.shields.io/badge/PokeAPI-EF5350?style=flat&logo=pokemon&logoColor=white) | RESTful API for Pokémon data and sprites |
| **Google Fonts** | ![Google Fonts](https://img.shields.io/badge/Google_Fonts-4285F4?style=flat&logo=google&logoColor=white) | Typography assets (`PressStart2P`, `Inter`) |
| **SharedPreferences** | ![SharedPreferences](https://img.shields.io/badge/Shared_Preferences-4CAF50?style=flat&logo=sqlite&logoColor=white) | Key-value local storage |
| **HTTP Networking** | ![HTTP](https://img.shields.io/badge/HTTP-009688?style=flat&logo=apache-http-server&logoColor=white) | Network communication and connectivity checks |

---

## Project Structure

```
pokepoke/
├── assets/
│   └── images/
│       └── pokeball.svg                 # Vector asset used for status indicators and watermark backgrounds
├── lib/
│   ├── main.dart                        # Application bootstrap, orientation locking
│   ├── core/
│   │   ├── data/
│   │   │   ├── pokemon_seed.dart        # Verified offline starter dataset
│   │   │   └── pokemon_species_data.dart# Physical dimensions, lore descriptions, and combat abilities
│   │   ├── services/
│   │   │   ├── cache_service.dart       # Local persistence and TTL cache manager
│   │   │   ├── evolution_service.dart   # Offline and network evolution chain resolver
│   │   │   ├── favourite_service.dart   # Reactive favourite state notifier and storage
│   │   │   └── pokemon_service.dart     # PokéAPI client and height-based sprite scaling
│   │   └── widgets/
│   │       ├── loadingscreen.dart       # Splash screen with competitive trainer tips
│   │       └── loading_screen/
│   │           └── loading_screen.dart  # Continuous spinning vector indicator
│   └── features/
│       └── dashboard/
│           ├── home/
│           │   ├── home_screen.dart     # Pokédex feed, search, type filters, and navigation
│           │   └── widgets/
│           │       └── pokemon_detail_sheet.dart # Modal view with interactive evolution tree
│           └── favourite/
│               └── favourite_screen.dart# Saved Pokémon collection view
├── test/
│   ├── widget_test.dart                 # Size scaling boundary and calculation tests
│   └── favourite_test.dart              # Favourites service and persistence tests
├── pubspec.yaml                         # Dependency definitions and asset configuration
└── gituser.md                           # Team attribution and contributor quotas
```

---

## Screen Descriptions

### 1. Splash Screen (`SplashScreen`)
- Displays an animated vector indicator and rotating competitive gameplay notes during initialization.
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

## Team & Commit Distribution

| Contributor | GitHub Profile | Commits |
|:---|:---|:---:|
| **Ractopen** | [ractopen](https://github.com/ractopen) | 11 |
| **Kent John** | [kentjohnllanita8978-oss](https://github.com/kentjohnllanita8978-oss) | 4 |
| **Roma** | [RomamasMPapas](https://github.com/RomamasMPapas) | 4 |
| **Jehlia** | [Jehlia-newcoder](https://github.com/Jehlia-newcoder) | 3 |

---

## License

Distributed under the MIT License. See [LICENSE](LICENSE) for details.
