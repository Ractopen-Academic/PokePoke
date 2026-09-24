# PokePoke 🎮

A retro-styled Pokémon companion mobile app built with **Flutter**, featuring **NeoPop** 3D brutalist aesthetics, live Pokémon data via **PokéAPI**, animated sprites, and a personalized trainer experience.

> **Mobile Programming — Midterm Project**

---

## 👥 Team & Task Assignments

| Member | Role | Feature |
|:---|:---|:---|
| **Jehlia** | Frontend Dev | ⭐ **Favourites** — Save/unsave Pokémon, persistent favourites list with retro card UI |
| **Aed Kent** | Frontend Dev | 👤 **Local Profile** — Set trainer username, save to `localStorage`, trainer card display |
| **Roma** | Fullstack / Lead | ⚔️ **Battle Arena** — Turn-based combat, animated sprites, HP bars, move selection |

> Battle is currently reserved and will be handled separately.

---

## ✅ Feature Progress

- [x] **Splash Screen** — Animated loading with Smogon tips rotation & Pokéball spinner
- [x] **Home / Pokédex Feed** — Scrollable list, load-more (10 at a time), cached sprites
- [x] **PokéAPI Integration** — Network fetch with built-in seed data fallback & local cache
- [ ] **Favourites** _(Jehlia)_ — Heart/star toggle on Pokémon cards, dedicated Favourites tab
- [ ] **Local Profile** _(Aed Kent)_ — Username input, saved to `SharedPreferences` / localStorage, trainer card
- [ ] **Battle Arena** _(Roma)_ — Turn-based battle system with animated sprites and move pad

---

## 🎨 Design Philosophy

PokePoke blends **nostalgic Game Boy / DS aesthetics** with modern Flutter UI patterns:

- **NeoPop 3D Components** — Tactile cards, elevated buttons with press animations (`neopop`)
- **Retro Typography** — *Fredoka* / *Dela Gothic One* for headers; *VT323* / *Silkscreen* for stats & battle text (`google_fonts`)
- **Smooth Image Caching** — Prevents flicker by caching sprites locally (`cached_network_image`)
- **Sensory Feedback** — 8-bit SFX on taps and transitions; haptic vibration on battle impacts (`audioplayers`, `haptic_feedback`)

---

## 🌐 APIs & Data Sources

### PokéAPI GraphQL
- **Endpoint:** `https://graphql.pokeapi.co/v1beta2/`
- **Explorer:** `https://graphql.pokeapi.co/v1beta2/console/`
- Fetches Pokémon names, types, base stats, and move sets in single optimized queries.

### Animated Sprites (Showdown)
| View | URL Pattern |
|:---|:---|
| Front (Opponent) | `https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/showdown/{id}.gif` |
| Back (Player) | `https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/showdown/back/{id}.gif` |
| Official Art | `https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/{id}.png` |

---

## ⚔️ Battle System Overview

A lightweight state-machine battle — no game engine needed:

```
┌─────────────────────────────────────────────┐
│  [Opponent HP Bar]         (Opponent GIF)   │
│                                             │
│  (Player Back GIF)         [Player HP Bar]  │
├─────────────────────────────────────────────┤
│  [ Tackle       ]    [ Quick Attack ]        │
│  [ Potion       ]    [ Run          ]        │
└─────────────────────────────────────────────┘
```

**Combat Flow:**
1. Player picks a move from the 2×2 NeoPop button grid
2. Damage calculated → opponent HP animates down
3. Narration dialog displays (e.g. *"Pikachu used Thunderbolt!"*)
4. Enemy counter-attacks after a short delay
5. Faint audio + victory/defeat modal when HP hits 0

---

## 📦 Tech Stack

| Package | Version | Purpose |
|:---|:---|:---|
| `flutter` | SDK | Core framework |
| `neopop` | ^1.0.2 | 3D neo-brutalist buttons & cards |
| `google_fonts` | ^8.2.1 | Retro typography (VT323, Silkscreen, Fredoka) |
| `cached_network_image` | ^4.0.0 | Sprite & artwork caching |
| `audioplayers` | ^6.8.1 | 8-bit SFX & battle audio |
| `shared_preferences` | — | Local profile persistence (username, favourites) |
| `cupertino_icons` | ^1.0.8 | Icon assets |

---

## 📁 Project Structure

```
lib/
├── core/
│   ├── data/               # Seed Pokémon data (offline fallback)
│   ├── services/           # PokéAPI service, cache service
│   ├── theme/              # Colors, NeoPop styles, typography
│   └── widgets/            # Reusable UI (loading screen, etc.)
├── features/
│   ├── dashboard/
│   │   ├── home/           # ✅ Pokédex feed (done)
│   │   ├── favourite/      # ⭐ Jehlia — Favourites tab
│   │   └── profile/        # 👤 Aed Kent — Local profile / trainer card
│   └── battle/             # ⚔️  Roma — Battle arena
└── main.dart
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK ≥ 3.13.3
- Android Studio / VS Code with Flutter plugin
- Android device, emulator, or Chrome

### Setup

```bash
# 1. Clone
git clone https://github.com/Ractopen-Academic/PokePoke.git
cd PokePoke

# 2. Install dependencies
flutter pub get

# 3. Analyze & test
flutter analyze
flutter test

# 4. Run
flutter run
```

---

## 🌿 Branching

| Branch | Purpose |
|:---|:---|
| `main` | Stable releases only |
| `development` | Active development & integration |

All feature work is merged into `development` first, then to `main` when stable.

---

## 📄 License

MIT License — see [LICENSE](LICENSE) for details.
