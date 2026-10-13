# PokéPoke — Group Presentation Master Guide

> **Project:** PokéPoke (Retro-Brutalist Pokémon Companion Mobile App)  
> **Course:** Mobile Programming (Midterm API Presentation)  
> **API Provider:** [PokéAPI (v2)](https://pokeapi.co/)  
> **Stack:** Flutter 3.x, Dart 3.x, Dio, SharedPreferences, NeoPoP, AudioPlayers, Pedometer

---

## Turn-Based Presentation Order

| Order | Speaker | Assigned Role | Guide File |
|:---:|:---|:---|:---|
| **1st** | **Jehlia** | **Member 1: Project Intro, Documentation & UI** | [jehlia.md](./jehlia.md) |
| **2nd** | **Royette** | **Member 2: Packages & API Integration** | [royette.md](./royette.md) |
| **3rd** | **Rob** | **Member 3: Models, JSON Parsing & Data Handling** | [rob.md](./rob.md) |
| **4th** | **Kent** | **Member 4 & 5: State Management & Live App Demo** | [kent.md](./kent.md) |

---

## Master Pre-Flight Checklist (Do Before Presenting)

1. Open **VS Code** with the `pokepoke` project folder loaded.
2. Open a **Terminal** window pointed at `/home/ryme/Personal/School/Mobile Programming/Midterm/Classmates/pokepoke`.
3. Launch your **Android Emulator** or plug in your physical test phone.
4. Open your web browser with one tab on [https://pokeapi.co/docs/v2](https://pokeapi.co/docs/v2).

---

## Quick Copy Commands (Terminal)

### Fetch Dependencies
```bash
flutter pub get
```

### Run the App on Emulator or Device
```bash
flutter run
```

### Run All Automated Tests
```bash
flutter test
```

### Verify PokéAPI Connection (Terminal)
```bash
curl -s "https://pokeapi.co/api/v2/pokemon/pikachu" | jq '{id: .id, name: .name, height: .height, weight: .weight}'
```

---

## Source Code Quick Links

- Application Entry Point: [`../lib/main.dart`](../lib/main.dart)
- Project Packages & Config: [`../pubspec.yaml`](../pubspec.yaml)
- Dio HTTP Client Singleton: [`../lib/core/services/poke_api_client.dart`](../lib/core/services/poke_api_client.dart)
- Pokémon Model & Network Service: [`../lib/core/services/pokemon_service.dart`](../lib/core/services/pokemon_service.dart)
- Offline Cache Service: [`../lib/core/services/cache_service.dart`](../lib/core/services/cache_service.dart)
- Reactive Favourites Service: [`../lib/core/services/favourite_service.dart`](../lib/core/services/favourite_service.dart)
- Pokédex Feed Screen: [`../lib/features/dashboard/home/home_screen.dart`](../lib/features/dashboard/home/home_screen.dart)
- Detail & Evolution Sheet: [`../lib/features/dashboard/home/widgets/pokemon_detail_sheet.dart`](../lib/features/dashboard/home/widgets/pokemon_detail_sheet.dart)
- Bookmarked Favourites Screen: [`../lib/features/dashboard/favourite/favourite_screen.dart`](../lib/features/dashboard/favourite/favourite_screen.dart)
- PokéWalk Step Simulator: [`../lib/features/battle/battle_screen.dart`](../lib/features/battle/battle_screen.dart)
- Safari Meadow Sanctuary: [`../lib/features/dashboard/profile/profile_safari_screen.dart`](../lib/features/dashboard/profile/profile_safari_screen.dart)
- Automated Test Directory: [`../test/`](../test/)
