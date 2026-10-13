# Member 4 & 5 Presentation Guide — Kent

> **Role:** Member 4 & 5 — State Management, Automated Testing, and Live App Demo  
> **Presenter:** Kent  
> **Relevant Code Files:**  
> - Home Feed State: [`../lib/features/dashboard/home/home_screen.dart`](../lib/features/dashboard/home/home_screen.dart)  
> - Reactive Favourites: [`../lib/core/services/favourite_service.dart`](../lib/core/services/favourite_service.dart)  
> - PokéWalk Simulation: [`../lib/features/battle/battle_screen.dart`](../lib/features/battle/battle_screen.dart)  
> - Safari Meadow Sanctuary: [`../lib/features/dashboard/profile/profile_safari_screen.dart`](../lib/features/dashboard/profile/profile_safari_screen.dart)  
> - Automated Tests: [`../test/`](../test/)  

---

## Tools to Open Before You Speak

1. **Window 1 (Emulator / Device):** Have PokéPoke running on the screen.
2. **Window 2 (Terminal):** Have terminal ready in the project directory to run `flutter test`.
3. **Window 3 (VS Code):** Have [`../lib/core/services/favourite_service.dart`](../lib/core/services/favourite_service.dart) ready to show `ValueNotifier`.

---

## Part 1: State Management & UI States Script

### Step 1: Explaining State Architecture
- **What to show:** Show [`../lib/core/services/favourite_service.dart`](../lib/core/services/favourite_service.dart#L7).
- **What to say:**
  > "Thank you, Rob! Good day everyone, I am Kent. I will explain our state management and then walk you through the complete live demonstration of PokéPoke.
  > 
  > In our app, we combine `StatefulWidget` with `setState` for local UI interactions, and a global `ValueNotifier` for cross-screen updates.
  > 
  > For example, when a user bookmarks a Pokémon, our `favouritesNotifier` notifies listeners immediately. The card, the detail sheet, and the bottom navigation bar badge all update in real time without needing a full-page reload."

### Step 2: Explaining UI States (Loading, Empty, Error)
- **What to say:**
  > "We also designed explicit UI states:
  > - **Loading state:** Shimmer boxes pulse while images download, and spinners appear during pagination.
  > - **Empty state:** When a search returns no local matches, a 'No Pokémon Found' banner appears.
  > - **Error state:** If a network lookup fails or an invalid name is searched, an alert banner informs the user."

---

## Part 2: Step-by-Step Live Demo Checklist (Do This on Screen!)

Follow these 10 actions sequentially while presenting:

### 1. Launch & Splash Screen
- **Action:** Open the app.
- **Say:** *"Notice our splash screen initializing local seed data while rotating competitive Pokémon battle tips and starting the 8-bit chiptune background music."*

### 2. Home Pokédex Feed & Proportional Sprites
- **Action:** Scroll through the home grid.
- **Say:** *"Notice that small Pokémon like Caterpie are rendered smaller at 72 pixels, while giants like Venusaur scale up to 125 pixels, anchored to the bottom right. Notice the 3D button press depth."*

### 3. Elemental Type Filters
- **Action:** Tap the **'Fire'** chip, then **'Water'**, then tap **'All'**.
- **Say:** *"The type filter bar instantly updates the feed in memory without making extra network requests."*

### 4. Search & PokéAPI Online Fallback
- **Action:** Type `'Pikachu'` in the search bar. Then clear it and type `'mewtwo'`.
- **Action:** When the empty state appears, tap **'SEARCH ONLINE VIA POKÉAPI'**.
- **Say:** *"Mewtwo was not in our starter cache. The app queried PokéAPI live, decoded the response, added it to our feed, and cached it locally. Here is the confirmation snackbar: Indexed Mewtwo (#150)!"*

### 5. Detail Sheet & Evolution Tree
- **Action:** Tap the **Bulbasaur** card to open the sheet.
- **Action:** Scroll down and tap the **Ivysaur** node in the Evolution Tree, then tap **Venusaur**.
- **Say:** *"Tapping any node in the interactive evolution tree pivots the view directly to that evolved form."*

### 6. Reactive Favourites
- **Action:** Tap the heart icon on any Pokémon. Point to the bottom navigation bar badge incrementing.
- **Action:** Tap the **FAVOURITES** tab to show the bookmarked list.
- **Say:** *"Our ValueNotifier syncs this favourite state instantly across tabs and saves it into local storage."*

### 7. PokéWalk Step Simulation
- **Action:** Tap the **POKÉWALK** tab.
- **Action:** Press and hold the **'HOLD TO WALK (+1)'** button.
- **Say:** *"Our custom hold-to-spam button rapidly steps forward. The tall-grass radar transitions from Calm to Rustling to Pokémon Nearby! Once encountered, we tap twice to capture it into our Safari Pen."*

### 8. Safari Meadow & Auto-Evolution
- **Action:** Tap the **SAFARI** profile tab to show roaming Pokémon.
- **Action:** Tap the **'SLOTS'** badge to open the inventory modal.
- **Action:** Press and hold the **'+25 XP'** button on a Pokémon until it levels up and auto-evolves!
- **Say:** *"Our hold-to-spam training button feeds XP rapidly, triggering level-ups and automatic evolution celebration popups."*

### 9. Audio Toggle
- **Action:** Tap the speaker icon in the top header to mute and unmute the music.

### 10. Automated Test Suite Execution
- **Action:** Switch to the terminal window and run this command:
```bash
flutter test
```
- **Say after all tests pass:**
  > "All 18 automated unit and widget tests pass with 100% success, validating our models, persistence, and widget behaviors."

---

## Presentation Conclusion Line

- **Say this exact sentence to conclude the presentation:**
  > "That concludes our group presentation for PokéPoke. We demonstrated REST API communication with PokéAPI, offline persistence, proportional layout math, reactive state management, and full automated testing. Thank you for your time, and we are ready for any questions!"

---

## Teacher Q&A Cheat Sheet (Common Questions)

**Q: "Why did you use `ValueNotifier` instead of Provider or Riverpod?"**  
> **Answer:** *"For this project's scope, Flutter's built-in `ValueNotifier` gave us instant, reactive cross-screen synchronization without importing heavy third-party state boilerplate."*

**Q: "What are your unit tests verifying?"**  
> **Answer:** *"Our 18 tests cover `PokemonEntry` JSON parsing, height-based proportional sprite bounds, `SharedPreferences` cache integrity, and rapid hold-to-spam timer triggering."*
