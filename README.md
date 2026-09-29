# PokéPoke 🎮

[![Flutter](https://img.shields.io/badge/Flutter-3.13+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Platforms](https://img.shields.io/badge/Platform-Android%20%7C%20Linux%20%7C%20Web-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://flutter.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)

A retro-styled, high-performance Pokémon companion mobile application built with **Flutter**. PokéPoke combines **NeoPoP 3D brutalist aesthetics** with real-time **PokéAPI** synchronization, height-proportional sprite sizing, interactive multi-branch evolution trees, and offline-first local persistence.

> **Course:** Mobile Programming — Midterm Examination Project  
> **Team:** Ractopen Academic

---

## 🎬 Demo & Video Preview

```
┌────────────────────────────────────────────────────────────────────────┐
│                                                                        │
│               🎥 DEMO VIDEO WALKTHROUGH PLACEHOLDER                    │
│                                                                        │
│        [ Placeholder: Demo Video Recording — pokepoke-demo.mp4 ]       │
│                                                                        │
│   • Splash Screen with Smogon Trainer Tips                             │
│   • Height-Proportional Pokédex Grid & Dynamic Type Filtering          │
│   • Wide Modal Evolution Tree with Interactive Stage Switching         │
│   • Specific Name & #ID Search with Online PokéAPI Fallback           │
│   • Persistent Favourites System with Live Badge Counter               │
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘
```

---

## ✨ Features

- **📏 Relative & Proportional Size Scaling**:
  Pokémon are sized proportionally based on their canonical Pokédex heights rather than uniform boxes. Small Pokémon (like Caterpie at 0.3 m) scale to 72px, while gargantuan Pokémon (like Venusaur at 2.0 m and Arbok at 3.5 m) scale up to 125px with bottom-right anchoring.
- **🧬 Wide Evolution & Detailed Lore View**:
  Tapping any Pokémon card displays a wide bottom sheet featuring lore flavor text, physical specifications, elemental abilities, defensive weaknesses, and an interactive evolution pathway with exact evolution triggers (e.g., *Level 16*, *Thunder Stone*, *Trade*). Tap any evolution node to inspect that stage directly!
- **🔍 Specific Search & Online PokéAPI Fallback**:
  Instant filtering by name or Pokédex number (`25`, `#025`, `pikachu`). If a searched Pokémon is not present in local cache, a dedicated **Search Online** button queries PokéAPI directly, indexes the Pokémon, and caches it locally.
- **❤️ Persistent Favourites Tab & Live Badges**:
  One-tap heart toggles on both grid cards and the detail sheet. Favourites are persisted across app restarts via `SharedPreferences`. The bottom navigation bar displays a live badge count of all saved Pokémon.
- **🎨 Neo-Brutalist 3D User Interface**:
  Tactile 3D buttons, interactive card press physics (`ScaleTransition`), custom radial animated background particle shaders, and retro typography (`PressStart2P` and `Inter`).
- **⚡ Offline-First Dual-Layer Architecture**:
  Pre-packaged starter seed database and instant offline evolution paths ensure the application loads instantly without network delays, falling back gracefully to background caching.

---

## 🛠️ Tech Stack

<div align="left">

| Technology | Logo / Badge | Purpose |
|:---|:---|:---|
| **Flutter** | ![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat-square&logo=flutter&logoColor=white) | Cross-platform UI toolkit & reactive engine |
| **Dart** | ![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat-square&logo=dart&logoColor=white) | Strong-mode object-oriented language |
| **NeoPoP** | ![NeoPoP](https://img.shields.io/badge/NeoPoP-FF1C1C?style=flat-square&logo=flutter&logoColor=white) | Neo-brutalist elevated 3D tactile buttons & cards |
| **PokéAPI** | ![PokéAPI](https://img.shields.io/badge/PokéAPI-EF5350?style=flat-square&logo=pokemon&logoColor=white) | RESTful API for Pokémon species, types, and stats |
| **Google Fonts** | ![Google Fonts](https://img.shields.io/badge/Google%20Fonts-4285F4?style=flat-square&logo=google&logoColor=white) | Retro typography (`PressStart2P`, `Inter`) |
| **SharedPreferences** | ![SharedPreferences](https://img.shields.io/badge/Storage-4CAF50?style=flat-square&logo=sqlite&logoColor=white) | Local persistent storage for indexed Pokémon & favourites |
| **HTTP & Connectivity** | ![HTTP](https://img.shields.io/badge/HTTP-009688?style=flat-square&logo=apache-http-server&logoColor=white) | Asynchronous network communication and connection sensing |
| **SVG & Shimmer** | ![SVG](https://img.shields.io/badge/Vector-FF9800?style=flat-square&logo=svg&logoColor=white) | Scalable vector Pokéball icons and skeleton loading shaders |

</div>

---

## 📁 Project Structure

```
pokepoke/
├── android/                             # Android native runner & permissions
├── linux/                               # Linux desktop native runner & CMake
├── web/                                 # Web platform entry & manifest
├── assets/
│   └── images/
│       └── pokeball.svg                 # High-resolution vector Pokéball icon
├── lib/
│   ├── main.dart                        # Application bootstrap & orientation lock
│   ├── core/
│   │   ├── data/
│   │   │   ├── pokemon_seed.dart        # Verified offline seed data (Gen 1 starters & staples)
│   │   │   └── pokemon_species_data.dart# Canonical heights, weights, lore quotes, abilities
│   │   ├── services/
│   │   │   ├── cache_service.dart       # SharedPreferences caching layer & TTL validation
│   │   │   ├── evolution_service.dart   # Offline & online evolution chain parser
│   │   │   ├── favourite_service.dart   # ValueNotifier reactive favourites persistence
│   │   │   └── pokemon_service.dart     # PokeAPI client, pagination & dynamic size calculator
│   │   └── widgets/
│   │       ├── loadingscreen.dart       # Animated splash screen with Smogon tips cycle
│   │       └── loading_screen/
│   │           └── loading_screen.dart  # Continuous spinning Pokéball indicator
│   └── features/
│       └── dashboard/
│           ├── home/
│           │   ├── home_screen.dart     # Pokédex feed, search, filter chips & bottom nav
│           │   └── widgets/
│           │       └── pokemon_detail_sheet.dart # Wide modal sheet with evolution pathway
│           └── favourite/
│               └── favourite_screen.dart# Saved Pokémon collection & dedicated search
├── test/
│   ├── widget_test.dart                 # Proportional size scaling verification tests
│   └── favourite_test.dart              # Favourites service & persistence verification tests
├── pubspec.yaml                         # Package dependencies & asset configuration
└── gituser.md                           # Team attribution and contributor quotas
```

---

## 📱 Screen Descriptions

### 1. Splash Screen (`SplashScreen`)
- **Visuals**: Animated pulsing Pokéball logo with elastic scale entry, ambient floating particles, and a glowing progress indicator.
- **Trainer Tips**: Displays rotating competitive battle wisdom curated from Smogon rulesets while the local database and caches are verified.
- **Fail-Safe Startup**: Loads pre-packaged offline seeds immediately, then initializes `CacheService` and `FavouriteService` asynchronously.

### 2. Pokédex Feed Screen (`HomeScreen`)
- **Header & Search Bar**: Integrated search accepting names or `#ID` numbers (`#001`, `25`, `charizard`), equipped with a 1-tap clear button and an online PokéAPI lookup action.
- **Type Filter Bar**: Horizontal scrollable chips for all 18 elemental Pokémon types (`Fire`, `Water`, `Grass`, `Electric`, `Psychic`, etc.) with responsive color themes.
- **Scaled Cards Grid**: Dual-type gradient cards displaying official artwork anchored to the bottom-right, scaled accurately according to height, with watermark Pokéballs and a quick-tap heart button.
- **Load More Pagination**: NeoPoP 3D tilted button to fetch and index additional Pokémon in batches of 10.

### 3. Wide Evolution & Detail Sheet (`PokemonDetailSheet`)
- **Drag-to-Inspect**: Expandable modal sheet with smooth draggable dismiss.
- **Hero Centerfold Display**: Animated radial glow with an `AnimatedSwitcher` scale-and-fade transition between evolution stages.
- **Canonical Metrics**: Real-world height in meters, weight in kilograms, gender ratio, and Pokémon species classification.
- **Combat Attributes**: List of primary abilities and defensive elemental weaknesses.
- **Evolution Pathway Flow**: Interactive horizontal node chain showing prerequisites (e.g., *Bulbasaur → Level 16 → Ivysaur → Level 32 → Venusaur*). Tapping any node transitions the detail view directly to that Pokémon.

### 4. Favourites Screen (`FavouriteScreen`)
- **Dedicated Tab**: Accessible directly from the bottom navigation bar.
- **Instant Reactive Updates**: Driven by `ValueNotifier<Set<int>>`; adding or removing a favorite anywhere in the app updates the screen and navbar counter badge without requiring a reload.
- **In-Collection Search**: Fast filtering within saved Pokémon by name or ID.
- **Tactile Empty State**: If no Pokémon are saved, displays a retro prompt with a 3D NeoPoP button that routes back to the Pokédex.

---

## 🧪 Testing & Quality Assurance

PokéPoke includes unit and widget tests covering core business logic and sizing constraints:

```bash
# Run static analysis
flutter analyze

# Run unit and widget test suite
flutter test
```

### Verified Test Suites:
- `test/widget_test.dart`:
  - `Bulbasaur scales smaller than Venusaur` (verifies proportional height calculation).
  - `Min and max bounds are respected` (72.0px minimum to 125.0px maximum limits).
- `test/favourite_test.dart`:
  - `Toggling favourite updates state and persistence` (tests toggle lifecycle and notification emission).
  - `Loads previously stored favourites on init` (verifies storage deserialization).

---

## 👥 Contributors & Team Quotas

In accordance with [`gituser.md`](gituser.md), commits are distributed as follows:

| Contributor | GitHub Identity | Assigned Responsibilities | Target |
|:---|:---|:---|:---:|
| **Ractopen** | `ractopen` | Architecture, backend services, caching, API sync & Linux desktop | **60%** |
| **Kent John** | `kentjohnllanita8978-oss` | Controllers, navigation, search routing & unit test suite | **20%** |
| **Roma** | `RomamasMPapas` | UI design, NeoPoP 3D styling, animations & proportional sizing | **10%** |
| **Jehlia** | `Jehlia-newcoder` | Favourites feature, heart toggles, badges & empty states | **10%** |

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version `3.13.0` or higher)
- Android SDK or Linux desktop development libraries (`gstreamer1-devel`, `clang`, `cmake`, `ninja`)

### Installation & Run

```bash
# 1. Clone the repository
git clone https://github.com/Ractopen-Academic/PokePoke.git
cd PokePoke

# 2. Install dependencies
flutter pub get

# 3. Launch on your connected device or Linux desktop
flutter run -d linux --portrait
```

---

## 📄 License

Distributed under the MIT License. See [LICENSE](LICENSE) for more information.
