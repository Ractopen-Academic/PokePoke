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
- **PokéWalk Mystery Walk Simulation**: An atmospheric walking simulation that conceals the exact step distance needed (secretly 10–50 steps). Features a real-time tall-grass radar scanner that transitions from Calm → Rustling → Signals Detected → Pokémon Nearby.
- **Real Physical Step Detection (Pedometer)**: Supports physical step tracking using device hardware activity sensors with a permission prompt dialog. Every real-world step advances the exploration towards the wild encounter, alongside the manual tap-to-step button.
- **Roaming Safari Meadow Sanctuary (Profile Tab)**: Caught Pokémon actively roam, wander, and spread out across an animated 2D meadow habitat. Tapping any roaming Pokémon brings up a quick training popover.
- **Quick Safari Inventory Modal**: Clicking the "X / 20 SLOTS" badge opens an inventory sheet to review all caught Pokémon, grant +25 XP to level up / auto-evolve, or release unwanted Pokémon.
- **8-Bit Retro Chiptune Background Music**: Implements looping authentic 8-bit background audio (*"8bit Dungeon Boss"* by Kevin MacLeod) with an interactive sound toggle.
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
| **AudioPlayers** | ![AudioPlayers](https://img.shields.io/badge/AudioPlayers-FF9800?style=flat&logo=media&logoColor=white) | Looping 8-bit background music playback |
| **Pedometer & Sensors** | ![Pedometer](https://img.shields.io/badge/Pedometer-00E676?style=flat&logo=android&logoColor=white) | Real-world physical step tracking |
| **SharedPreferences** | ![SharedPreferences](https://img.shields.io/badge/Shared_Preferences-4CAF50?style=flat&logo=sqlite&logoColor=white) | Key-value local storage |
| **HTTP Networking** | ![HTTP](https://img.shields.io/badge/HTTP-009688?style=flat&logo=apache-http-server&logoColor=white) | Network communication and connectivity checks |

---

## API Endpoints

1. **Fetch Pokémon by Name or Pokédex ID:**
   - **Endpoint:** `GET https://pokeapi.co/api/v2/pokemon/{name_or_id}`
   - **File:** `pokemon_service.dart:129`
   - **Usage:** Used in `fetchSinglePokemon` (for search & evolution details) and `fetchMore` (batching 10 Pokémon at a time by sequential ID).

2. **Fetch Pokémon Species Data (Evolution Chain Discovery):**
   - **Endpoint:** `GET https://pokeapi.co/api/v2/pokemon-species/{id}`
   - **File:** `evolution_service.dart:204`
   - **Usage:** Retrieves the species details to find the specific `evolution_chain` resource URL for that Pokémon.

3. **Fetch Evolution Chain Structure:**
   - **Endpoint:** `GET https://pokeapi.co/api/v2/evolution-chain/{id}/`
   - **File:** `evolution_service.dart:214`
   - **Usage:** Parses evolution nodes, evolution triggers (Level, Stone, Trade, Friendship), and species sequence.

4. **Official High-Res Artwork (Sprite CDN):**
   - **URL:** `https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/{id}.png`
   - **Files:** `pokemon_service.dart:46`, `evolution_service.dart:18`
   - **Usage:** High-resolution official Pokémon artwork cached to disk via `CachedNetworkImage`.

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
│   │   │   └── pokemon_species_data.dart# Physical dimensions, lore descriptions, and combat abilities
│   │   ├── services/
│   │   │   ├── audio_service.dart       # Looping 8-bit background music service and mute controller
│   │   │   ├── cache_service.dart       # Local persistence and TTL cache manager
│   │   │   ├── evolution_service.dart   # Offline and network evolution chain resolver
│   │   │   ├── favourite_service.dart   # Reactive favourite state notifier and storage
│   │   │   └── pokemon_service.dart     # PokéAPI client and height-based sprite scaling
│   │   └── widgets/
│   │       ├── loadingscreen.dart       # Splash screen with competitive trainer tips
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
│   ├── widget_test.dart                 # Size scaling boundary and calculation tests
│   ├── favourite_test.dart              # Favourites service and persistence tests
│   ├── battle_pen_test.dart             # Safari Pen capacity, XP, and auto-evolution tests
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
- Real-time tall-grass radar scanner displays distance signals (Quiet → Rustling → Signals Detected → Pokémon Nearby).
- Integrates real physical step tracking via device motion sensors (`Pedometer`) with user permission request dialog.
- Wild Pokémon roams and spreads dynamically across the arena grid.
- Tap 2 times to weaken and capture the roaming Pokémon into the local Safari Pen.
- Features an 8-bit background music toggle button.

### 6. Safari Pen & Roaming Sanctuary (`ProfileSafariScreen`)
- **Interactive Roaming Meadow**: All caught Pokémon wander and roam freely across an animated green meadow habitat.
- Tapping any roaming Pokémon in the meadow reveals a quick training popover.
- **Quick Inventory Sheet**: Clicking the **"X / 20 SLOTS"** badge opens a modal bottom sheet listing all caught Pokémon.
- Trainers can train (+25 XP) to level up and trigger auto-evolution celebrations once level requirements are met, or release Pokémon back into the wild to free up pen slots.
- Includes view switching between Roaming Park view and Grid Inventory view, with background music control.

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
