# 🚀 PokéPoke — Refactoring & Code Simplification Roadmap

> **For the Next AI Model / Assistant**:
> This document details the exact status, achievements, and pending tasks for simplifying and reducing boilerplate in the **PokéPoke** Flutter project.
> **Git author requirement**: `ractopen <197402134+ractopen@users.noreply.github.com>`.
> **Working Directory**: `/home/ryme/Personal/School/Mobile Programming/Midterm/pokepoke`

---

## 📊 Summary of What Was Accomplished So Far

In the initial cleanup pass, we eliminated boilerplate across UI animations and services:
1. **Consolidated Animation Libraries**:
   - Removed redundant `animate_do` package in favor of `flutter_animate`.
   - Converted all `FadeInDown`, `FadeInUp`, and `FadeInLeft` calls to `.animate().fadeIn().slideY()/slideX()`.
   - Removed manual `AnimationController` + `Tween` in `_PokemonCard` in favor of Flutter's clean `AnimatedScale`.
2. **De-duplicated UI & Styling**:
   - Created `lib/core/utils/type_colors.dart` (`kTypeColors` map & `typeColor()` helper), replacing 4 copy-pasted implementations across screens.
   - Created `lib/core/widgets/shimmer_box.dart` (`ShimmerBox`), eliminating duplicate inline `Shimmer.fromColors` placeholders.
3. **Migrated HTTP to Dio**:
   - Replaced raw `http` and manual `dart:convert` in `pokemon_service.dart` and `evolution_service.dart` with `dio: ^5.8.0`.
   - Automatic JSON decoding and exception-based error handling.
4. **Current Status**:
   - `flutter analyze` passing with **0 issues**.
   - `flutter test` passing with **13/13 tests passing**.

---

## 🎯 Next Steps: Remaining Tasks to Save Lines of Code

### Priority 1: Replace Manual CacheService with `dio_cache_interceptor`
- **Target Files**: `lib/core/services/cache_service.dart`, `lib/core/services/pokemon_service.dart`, `lib/core/services/evolution_service.dart`
- **Potential Lines Saved**: **~90–120 lines**
- **Action**:
  1. Add `dio_cache_interceptor` and `dio_cache_interceptor_hive_store` (or memory store).
  2. Attach the cache interceptor to the shared `_dio` instance in `PokemonService`.
  3. Remove manual cache staleness, timestamps, and json encoding in `cache_service.dart`.

### Priority 2: Extract Reusable `PokeDarkDialog`
- **Target Files**: `lib/features/battle/battle_screen.dart`, `lib/features/dashboard/profile/profile_safari_screen.dart`
- **Potential Lines Saved**: **~60 lines**
- **Action**:
  - Multiple `AlertDialog` instances share almost identical dark-theme container decorations, rounded borders (`Color(0xFF262640)`), title styling (`GoogleFonts.pressStart2p`), and action button setups.
  - Create `lib/core/widgets/poke_dark_dialog.dart` with a simple title, content, and positive/negative actions.

### Priority 3: Simplify Bottom Navigation in `HomeScreen`
- **Target File**: `lib/features/dashboard/home/home_screen.dart` (`_buildBottomNav()`)
- **Potential Lines Saved**: **~60–75 lines**
- **Action**:
  - Replace the ~90-line custom `Container` + `Row` + `GestureDetector` + badge calculation with Flutter's standard `NavigationBar` or `BottomNavigationBar` using `NavigationDestination` and `Badge.count`.

### Priority 4: Code Generation for Models (`json_serializable` or `freezed`)
- **Target Files**:
  - `lib/features/battle/data/caught_pokemon.dart`
  - `lib/core/services/pokemon_service.dart` (`PokemonEntry`)
  - `lib/core/services/evolution_service.dart` (`EvolutionNode`, `EvolutionChainData`)
- **Potential Lines Saved**: **~80–120 lines**
- **Action**:
  - Add `json_serializable` and `build_runner` to `dev_dependencies` and `json_annotation` to `dependencies`.
  - Replace hand-written `toMap()` and `fromMap()` methods.

### Priority 5: Architectural State Management & Routing (Optional / Post-Midterm)
- **State**: Replace `ValueNotifier` instances (`penNotifier`, `favouritesNotifier`, audio notifiers) with `flutter_riverpod`.
- **Navigation**: Replace manual tab switching with `go_router` shell routes.
- **Estimated Savings**: **~200–300 lines**.

---

## 🛠️ Important Commands for the Assistant
- Run tests: `flutter test`
- Analyze linter & syntax: `flutter analyze`
- Git commit (use author):
  ```bash
  git commit --author="ractopen <197402134+ractopen@users.noreply.github.com>" -m "..."
  ```
