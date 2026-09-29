# PokéPoke: Code Simplification Handoff

This is a handoff for continuing the code-size cleanup. Prioritize fewer lines while preserving the current UI, offline behavior, and gameplay. Do not add a package unless it reduces project-maintained code without replacing important behavior with a more complicated setup.

## Current repository state

The following changes are present in the repository:

- `animate_do` has been removed; screens use the already-installed `flutter_animate`.
- `PokemonService` and `EvolutionService` use Dio for PokeAPI requests.
- Shared Pokémon type colors live in `lib/core/utils/type_colors.dart`.
- Shared image loading shimmer UI lives in `lib/core/widgets/shimmer_box.dart`.
- The Pokémon card press animation uses Flutter's `AnimatedScale`.

This document does not claim a line-count reduction or test status. The worktree was clean before this handoff was edited, so the earlier conversation's claimed savings cannot be independently measured from an available diff. Run `flutter analyze` and `flutter test` after any code changes.

## Recommended next steps

### 1. Remove duplicated PokeAPI-to-model mapping

**Files:** `lib/core/services/pokemon_service.dart`

`fetchSinglePokemon`, `fetchMore`, and `_fetchFirstPage` each read the API response and build a `PokemonEntry` in similar code. Consider extracting a single private mapper (or a `PokemonEntry` API factory) that handles the API's nested `types` shape and species height/weight fallback. Reuse it in all three paths. Keep `fromMap` for the app's existing cache shape; confirm whether that shape matches the API before trying to combine them.

**Acceptance:** all three fetch paths return equivalent entries, including correct types, height, and weight; existing cache behavior is unchanged.

### 2. Consolidate repeated dialog styling where it genuinely matches

**Files:** `lib/features/battle/battle_screen.dart`, `lib/features/dashboard/profile/profile_safari_screen.dart`; consider a shared widget under `lib/core/widgets/`.

There are multiple `AlertDialog` implementations with repeated dark styling. Compare their actions, colors, and dismissal behavior before extracting a small shared dialog widget. Keep dialogs with materially different behavior separate; a reusable component should reduce call-site code, not add configuration boilerplate.

**Acceptance:** actions, barrier behavior, text, and styling stay the same.

### 3. Evaluate standard bottom navigation

**File:** `lib/features/dashboard/home/home_screen.dart` (`_buildBottomNav`)

Check whether Flutter's `NavigationBar`/`NavigationDestination` can replace the custom bottom navigation while retaining the current appearance, selection behavior, and badges. This is optional: do not adopt it if matching the current UI requires substantial custom styling or more code.

### 4. Treat persistence and code-generation packages as investigations, not drop-in replacements

- `lib/core/services/cache_service.dart` is more than HTTP response caching: it seeds offline Pokémon data, stores the list and per-Pokémon evolution chains, upserts fetched entries, and tracks a refresh TTL. A Dio cache interceptor does not automatically replace these app-specific features. Only consider one if it clearly simplifies the overall design while preserving offline behavior and persistence.
- `CaughtPokemon`, `PokemonEntry`, `EvolutionNode`, and `EvolutionChainData` have hand-written map serialization. `json_serializable` or `freezed` may reduce handwritten model code, but generated files and build-runner workflow add overhead. Compare total maintained code and migration risk before adopting them.
- Riverpod and GoRouter are architectural migrations, not quick line-count reductions. Defer unless there is a separate need to change state management or navigation.

## Useful commands

```sh
flutter analyze
flutter test
```
