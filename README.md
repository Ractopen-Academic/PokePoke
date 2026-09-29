# PokéPoke

A retro-styled Pokémon companion mobile application developed with Flutter. It combines NeoPoP-inspired design, PokéAPI lookups, height-proportional sprite sizing, interactive evolution trees, and offline-first local persistence.

---

## Demo App

Run the app locally with `flutter pub get` followed by `flutter run`. No hosted demo or recording is currently included in this repository.

---

## Features

- **Proportional Size Scaling**: Pokémon are rendered according to their canonical Pokédex heights rather than identical bounding boxes (ranging from 72 px for smaller Pokémon like Caterpie to 125 px for larger Pokémon like Venusaur and Arbok). Sprites are anchored to the bottom-right corner to ensure uniform alignment within the grid.
- **Wide Evolution and Detail Sheet**: Selecting any Pokémon opens an expandable bottom sheet providing species taxonomy, metric dimensions, ability profiles, defensive weaknesses, lore descriptions, and an interactive evolution pathway. Selecting any evolutionary node immediately pivots the sheet to that target Pokémon.
- **Specific Search with Online Fallback**: Supports instantaneous filtering by name or Pokédex number (`25`, `#025`, `pikachu`). If an entry is not present in local storage, a dedicated "Search Online" action queries PokéAPI directly, indexes the response, and caches it locally.
- **Persistent Favourites System**: Direct heart toggles on cards and within the detail view allow users to bookmark Pokémon. State is synchronized across views via a reactive notifier and persisted through local storage. The bottom navigation bar displays a live item counter badge.
- **NeoPoP Design Architecture**: Employs elevated surfaces, custom press mechanics, and retro typography.
- **PokéWalk Mystery Walk Simulation**: An atmospheric walking simulation that conceals the exact step distance needed (secretly 10–50 steps). Features a real-time tall-grass radar scanner that transitions from Calm → Rustling → Signals Detected → Pokémon Nearby.
- **Real Physical Step Detection (Pedometer)**: Supports physical step tracking using device hardware activity sensors with a permission prompt dialog. Every real-world step advances the exploration towards the wild encounter, alongside the manual tap-to-step button.
- **Roaming Safari Meadow Sanctuary (Profile Tab)**: Caught Pokémon actively roam, wander, and spread out across an animated 2D meadow habitat. Tapping any roaming Pokémon brings up a quick training popover.
- **Quick Safari Inventory Modal**: Clicking the "X / 20 SLOTS" badge opens an inventory sheet to review all caught Pokémon, grant +25 XP to level up / auto-evolve, or release unwanted Pokémon.
- **8-Bit Retro Chiptune Background Music**: Implements looping authentic 8-bit background audio (*"8bit Dungeon Boss"* by Kevin MacLeod) with an interactive sound toggle.
- **Offline Reliability**: Bundles a 20-entry seed dataset and built-in evolution chains, with persistent caches for previously loaded Pokémon and evolution data.

---

## Tech Stack

| Technology | Logo / Badge | Purpose |
|:---|:---|:---|
| **Flutter** | ![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white) | Application framework and UI runtime |
| **Dart** | ![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat&logo=dart&logoColor=white) | Core programming language |
| **NeoPoP** | ![NeoPoP](https://img.shields.io/badge/NeoPoP-FF1C1C?style=flat&logo=flutter&logoColor=white) | 3D neo-brutalist widget library |
| **PokéAPI** | ![PokéAPI](https://img.shields.io/badge/PokeAPI-EF5350?style=flat&logo=pokemon&logoColor=white) | RESTful API for Pokémon data and sprites |
| **Google Fonts** | ![Google Fonts](https://img.shields.io/badge/Google_Fonts-4285F4?style=flat&logo=google&logoColor=white) | Typography assets (`PressStart2P`, `Inter`) |
| **AudioPlayers** | ![AudioPlayers](https://img.shields.io/badge/AudioPlayers-FF9800?style=flat&logo=media&logoColor=white) | Looping 8-bit background music playback |
| **Pedometer & Sensors** | ![Pedometer](https://img.shields.io/badge/Pedometer-00E676?style=flat&logo=android&logoColor=white) | Real-world physical step tracking |
| **SharedPreferences** | ![SharedPreferences](https://img.shields.io/badge/Shared_Preferences-4CAF50?style=flat&logo=sqlite&logoColor=white) | Key-value local storage |
| **Dio & Connectivity Plus** | ![Dio](https://img.shields.io/badge/Dio-009688?style=flat&logo=dio&logoColor=white) | PokéAPI requests and network availability checks |
| **Cached Network Image** | ![Cached Network Image](https://img.shields.io/badge/Cached_Network_Image-5C6BC0?style=flat&logo=flutter&logoColor=white) | Artwork loading and image caching |
| **Flutter Animate & SVG** | ![Flutter Animate](https://img.shields.io/badge/Flutter_Animate-7E57C2?style=flat&logo=flutter&logoColor=white) | UI animations and vector assets |

---

## API Endpoints

1. **Pokémon data:** `GET https://pokeapi.co/api/v2/pokemon/{name_or_id}`. Used for online search and to fetch Pokémon by ID during pagination and background refresh.
2. **Species and evolution discovery:** `GET https://pokeapi.co/api/v2/pokemon-species/{id}`. The response provides an `evolution_chain.url`; the app follows it to `GET https://pokeapi.co/api/v2/evolution-chain/{id}/` to retrieve the evolution details.
3. **Official artwork:** `https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/{id}.png`. Artwork is loaded by `CachedNetworkImage`; this is a sprite URL, not a PokéAPI REST endpoint.

PokéAPI requests are made with Dio and do not require an API key. Network access is needed for online search and uncached data; bundled seed data, cached Pokémon, and built-in evolution chains support offline use.

---

## Project Structure

```
pokepoke/
├── assets/
│   ├── audio/
│   │   └── safari_bgm.mp3               # 8-bit retro chiptune background music (Kevin MacLeod)
│   └── images/
│       └── pokeball.svg                 # Vector asset used for status indicators and watermark backgrounds
├── lib/
│   ├── main.dart                        # Application bootstrap, orientation locking
│   ├── core/
│   │   ├── data/
│   │   │   ├── pokemon_seed.dart        # Verified offline starter dataset
│   │   │   └── pokemon_species_data.dart # Physical dimensions, lore descriptions, and combat abilities
│   │   ├── utils/
│   │   │   └── type_colors.dart          # Shared Pokémon type colors
│   │   ├── services/
│   │   │   ├── audio_service.dart       # Looping 8-bit background music service and mute controller
│   │   │   ├── cache_service.dart       # Local persistence and TTL cache manager
│   │   │   ├── evolution_service.dart   # Offline and network evolution chain resolver
│   │   │   ├── favourite_service.dart   # Reactive favourite state notifier and storage
│   │   │   ├── poke_api_client.dart     # Shared Dio client and request timeouts
│   │   │   └── pokemon_service.dart     # PokéAPI client and height-based sprite scaling
│   │   └── widgets/
│   │       ├── hold_to_spam_button.dart # Reusable auto-fire hold-to-spam button
│   │       ├── loadingscreen.dart       # Splash screen with competitive trainer tips
│   │       ├── poke_dark_dialog.dart    # Shared dark dialog styling
│   │       ├── shimmer_box.dart         # Shared image-loading placeholder
│   │       └── loading_screen/
│   │           └── loading_screen.dart  # Continuous spinning vector indicator
│   └── features/
│       ├── battle/
│       │   ├── battle_screen.dart       # PokéWalk mystery walk simulation, pedometer sensor & tap-to-catch
│       │   └── data/
│       │       ├── caught_pokemon.dart  # Caught Pokémon data model with XP progression
│       │       └── battle_pen_service.dart # Safari Pen storage (20 max), release & auto-evolution
│       └── dashboard/
│           ├── home/
│           │   ├── home_screen.dart     # Pokédex feed, search, type filters, and navigation
│           │   └── widgets/
│           │       └── pokemon_detail_sheet.dart # Modal view with interactive evolution tree
│           ├── favourite/
│           │   └── favourite_screen.dart# Saved Pokémon collection view
│           └── profile/
│               └── profile_safari_screen.dart # Roaming Safari Meadow, inventory sheet & training interface
├── test/
│   ├── widget_test.dart                 # API parsing and size scaling tests
│   ├── favourite_test.dart              # Favourites service and persistence tests
│   ├── battle_pen_test.dart             # Safari Pen capacity, XP, and auto-evolution tests
│   ├── hold_to_spam_test.dart           # Hold-to-spam rapid triggering tests
│   └── pokemon_index_cache_test.dart    # Evolution tree parsing and persistent cache tests
├── pubspec.yaml                         # Dependency definitions and asset configuration
└── gituser.md                           # Team attribution and contributor quotas
```

---

## Screen Descriptions

### 1. Splash Screen (`SplashScreen`)
- Displays an animated vector indicator and rotating competitive gameplay notes during initialization.
- Loads seed data, verifies local cache integrity, initializes audio and storage services, and restores favourite identifiers before routing to the main interface.

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

### 5. PokéWalk Arena (`BattleScreen`)
- Mystery walking simulator where the required step target is hidden (random 10–50 steps).
- **Hold-to-Walk Auto-Fire**: Press and hold the "HOLD TO WALK (+1)" button to rapidly step through the tall grass without repeated tapping.
- Real-time tall-grass radar scanner displays distance signals (Quiet → Rustling → Signals Detected → Pokémon Nearby).
- Integrates real physical step tracking via device motion sensors (`Pedometer`) with user permission request dialog.
- Wild Pokémon roams and spreads dynamically across the arena grid.
- Tap 2 times to weaken and capture the roaming Pokémon into the local Safari Pen.
- Features an 8-bit background music toggle button.

### 6. Safari Pen & Roaming Sanctuary (`ProfileSafariScreen`)
- **Interactive Roaming Meadow**: All caught Pokémon wander and roam freely across an animated green meadow habitat.
- **Hold-to-Spam Training**: Press and hold any "+25 XP" training button to continuously spam training, level up, and trigger auto-evolutions smoothly.
- Tapping any roaming Pokémon in the meadow reveals a quick training popover.
- **Quick Inventory Sheet**: Clicking the **"X / 20 SLOTS"** badge opens a modal bottom sheet listing all caught Pokémon.
- Trainers can train (+25 XP) to level up and trigger auto-evolution celebrations once level requirements are met, or release Pokémon back into the wild to free up pen slots.
- Includes view switching between Roaming Park view and Grid Inventory view, with background music control.

### 7. API Integration (shared across screens)
- The Pokédex uses `GET /pokemon/{name_or_id}` for online search and ID-based loading.
- Evolution details use `GET /pokemon-species/{id}`, then follow the evolution-chain URL returned by that response.
- Pokémon artwork is loaded from the PokéAPI sprites repository and cached by `CachedNetworkImage`.
- Offline seed data, persistent local cache, and built-in evolution chains provide fallback data when the API is unavailable.

---

## Team & Commit Distribution

| Contributor | GitHub Profile | Contribution Share |
|:---|:---|:---:|
| **Ractopen** | [ractopen](https://github.com/ractopen) | 60% |
| **Kent John** | [kentjohnllanita8978-oss](https://github.com/kentjohnllanita8978-oss) | 20% |
| **Roma** | [RomamasMPapas](https://github.com/RomamasMPapas) | 10% |
| **Jehlia** | [Jehlia-newcoder](https://github.com/Jehlia-newcoder) | 10% |

---

## License

Distributed under the MIT License. See [LICENSE](LICENSE) for details.
