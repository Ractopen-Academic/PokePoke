# PokéPoke

A retro-styled Pokémon companion mobile application developed using Flutter. It integrates NeoPoP brutalist design principles with real-time PokéAPI synchronization, height-proportional sprite sizing, interactive multi-stage evolution trees, and persistent local storage.

---

## Project Structure & Assets

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

## Build & Installation (Samsung Galaxy S25 FE / Modern ARM64)

The Samsung Galaxy S25 FE and other modern Android flagships run 64-bit ARM architecture (`arm64-v8a`). Build a targeted release APK with optimal performance and minimal package size using either of the following commands:

### Target ARM64 Release APK (Recommended for modern devices)
```bash
flutter build apk --release --target-platform android-arm64
```
* **Output Path:** `build/app/outputs/flutter-apk/app-release.apk` (or `app-arm64-v8a-release.apk`)

### Split-per-ABI Release
```bash
flutter build apk --split-per-abi
```
* **Output Path for S25 FE:** `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`

### Sideload / Install via ADB
```bash
adb install -r build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

---

## Team & Commit Distribution

| Contributor | GitHub Profile | Commit Count | Responsibility |
|:---|:---|:---:|:---|
| **Ractopen** | [ractopen](https://github.com/ractopen) | 11 | Architecture, backend services, caching, API sync, desktop runner |
| **Kent John** | [kentjohnllanita8978-oss](https://github.com/kentjohnllanita8978-oss) | 4 | Controllers, navigation routing, unit testing |
| **Roma** | [RomamasMPapas](https://github.com/RomamasMPapas) | 4 | Interface design, NeoPoP integration, proportional layout |
| **Jehlia** | [Jehlia-newcoder](https://github.com/Jehlia-newcoder) | 3 | Favourites module, responsive toggles, badge counters |

---

## License

Distributed under the MIT License. See [LICENSE](LICENSE) for details.
