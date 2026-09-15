# PokePoke

A retro-styled Pokémon companion and turn-based battle mobile application built with **Flutter**, featuring **NeoPop** 3D brutalist aesthetics, sensory feedback, live Pokémon data via **PokéAPI GraphQL**, and animated sprites via the **Showdown Sprite API**.

Developed as a **Mobile Programming Midterm Project**.

---

## Design Philosophy & UX

PokePoke combines the nostalgic look and feel of retro handheld gaming consoles with modern mobile UI patterns. Instead of building complex 3D animations and graphics engines from scratch, the app uses pre-built ecosystem packages to achieve a tactile Game Boy / DS look with minimal code:

- **NeoPop 3D Components:** Pre-built 3D cards, surfaces, and buttons (`neopop`) featuring elevation, customizable tilt angles, stroke borders, and press animations out of the box.
- **Retro & Pixel Typography (`google_fonts`):**
  - *Titles & Headings:* **Fredoka** or **Dela Gothic One** for chunky, collectible-card styling.
  - *Stats, Dialogs & Battle Text:* **VT323** or **Silkscreen** for authentic 8-bit pixel readability.
- **Sensory Audio & Haptics (`audioplayers` & `haptic_feedback`):**
  - 8-bit sound cues on button taps, menu transitions, attack hits, and faints.
  - Haptic vibration on physical interactions and battle impacts.
- **Smooth Image Caching (`cached_network_image`):**
  - Prevents network stutter and flickering by caching sprites and artwork locally.

---

## Features & Roadmap

- [x] **Core Foundation:**
  - Standardized project architecture & responsive base layout
  - Clean loading states with retro indicators
  - Full dependency ecosystem installed and configured
- [ ] **Authentication (`lib/features/auth/`):**
  - Retro login screen with tactile NeoPop buttons
  - User registration & local session persistence
- [ ] **Pokédex Dashboard (`lib/features/dashboard/`):**
  - **Home:** Featured Pokémon, generations, types, and daily discovery
  - **Search:** Instant query filtering by name, type, and generation
  - **Favourites:** Saved Pokémon roster with quick access
  - **Profile:** Trainer card with customized avatar, stats, and achievements
  - **Settings:** Audio FX toggles, haptic controls, and theme preferences
- [ ] **Battle Arena (`lib/features/battle/`):**
  - Lightweight turn-based combat system
  - Animated front and back Pokémon sprites
  - Dynamic HP bars with smooth damage transitions
  - Action selection pad (Attack, Special, Potion, Run)
  - Turn narration dialog box and battle audio cues

---

## APIs & External Resources

### 1. PokéAPI GraphQL Endpoint
- **URL:** `https://graphql.pokeapi.co/v1beta2/`
- **Console / Explorer:** `https://graphql.pokeapi.co/v1beta2/console/`
- **Usage:** Fetch specific Pokémon attributes (names, types, base stats, and move sets) in single, payload-optimized network queries.

### 2. Animated Sprites (Showdown Sprite API)
By streaming animated GIFs directly from PokéAPI's Showdown repository, the app displays authentic moving Pokémon without requiring custom sprite-sheet slicers or animation loops:

- **Opponent (Front View):**
  ```text
  https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/showdown/{id}.gif
  ```
- **Player (Back View):**
  ```text
  https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/showdown/back/{id}.gif
  ```
- **Official Artwork (Pokédex Detail Views):**
  ```text
  https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/{id}.png
  ```

---

## Simple Battle System Architecture

Rather than using complex game engines like Flame, the battle system is implemented as a clean Flutter state machine using standard widgets and animations:

### Battle Screen Layout
```text
+------------------------------------------+
|  [Opponent HP Card]       (Opponent GIF) |
|  HP: [========  ] 80/100                 |
|                                          |
|  (Player Back GIF)        [Player HP Card|
|                           HP: [====== ]  |
+------------------------------------------+
|  [ NeoPop Battle Dialog / Move Pad ]     |
|  [ Tackle     ]        [ Quick Attack ]  |
|  [ Potion     ]        [ Run          ]  |
+------------------------------------------+
```

### Combat Flow
1. **Turn Selection:** Player chooses an action from the 2x2 NeoPop button grid.
2. **Player Action:** Plays attack audio, triggers light haptic impact, calculates damage (`max(5, attack - defense / 2)`), and smoothly animates opponent HP down.
3. **Turn Delay:** A brief delay (`Future.delayed`) displays narrative dialog ("Pikachu used Thunderbolt!").
4. **Enemy Reaction:** If the opponent survives, an automated enemy move is triggered against the player.
5. **Outcome:** When either Pokémon hits 0 HP, a faint audio clip plays and a victory/defeat modal appears with rematch options.

---

## Tech Stack & Dependencies

| Package | Version | Purpose |
| :--- | :--- | :--- |
| **flutter** | SDK | Core application framework |
| **neopop** | ^1.0.2 | 3D neo-brutalist buttons, tactile cards, and surfaces |
| **google_fonts** | ^8.2.1 | Retro typography (VT323, Silkscreen, Fredoka, Dela Gothic One) |
| **cached_network_image** | ^4.0.0 | High-performance image and sprite caching |
| **audioplayers** | ^6.8.1 | 8-bit sound effects, menu clicks, and battle audio |
| **cupertino_icons** | ^1.0.8 | Icon assets |

---

## Project Directory Structure

```text
lib/
├── core/                       # Core utilities, themes, and shared widgets
│   ├── theme/                  # Colors, NeoPop styles, and typography
│   └── widgets/                # Reusable UI components
│       └── loading_screen/     # Base loading state widget
├── features/                   # Feature modules
│   ├── auth/                   # Authentication module
│   │   ├── login/              # Login screen
│   │   └── register/           # Registration screen
│   ├── battle/                 # Battle arena module
│   │   └── battle_screen.dart  # Turn-based battle arena
│   └── dashboard/              # Main app shell and tabs
│       ├── home/               # Featured Pokémon feed
│       ├── search/             # Type and generation search
│       ├── favourite/          # Saved favourites collection
│       ├── profile/            # Trainer profile and statistics
│       └── settings/           # Audio and haptic toggles
└── main.dart                   # Application entry point
```

---

## Getting Started

### Prerequisites
- Flutter SDK (3.13.3 or higher)
- Android Studio or VS Code with Flutter extension
- Android Device, Emulator, or Chrome browser

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Ractopen-Academic/PokePoke.git
   cd PokePoke
   ```

2. **Fetch dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run static analysis and tests:**
   ```bash
   flutter analyze
   flutter test
   ```

4. **Run the application:**
   ```bash
   flutter run
   ```

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
