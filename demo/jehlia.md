# Member 1 Presentation Guide — Jehlia

> **Role:** Member 1 — Project Introduction, Documentation, and UI Architecture  
> **Presenter:** Jehlia  
> **Relevant Code Files:**  
> - App Root: [`../lib/main.dart`](../lib/main.dart)  
> - Splash Screen: [`../lib/core/widgets/loadingscreen.dart`](../lib/core/widgets/loadingscreen.dart)  
> - Home Pokédex: [`../lib/features/dashboard/home/home_screen.dart`](../lib/features/dashboard/home/home_screen.dart)  
> - Detail Sheet: [`../lib/features/dashboard/home/widgets/pokemon_detail_sheet.dart`](../lib/features/dashboard/home/widgets/pokemon_detail_sheet.dart)  

---

## Tools to Open Before You Speak

1. **Window 1 (Browser):** Open [https://pokeapi.co/docs/v2](https://pokeapi.co/docs/v2) in a tab.
2. **Window 2 (Emulator):** Have the PokéPoke app running on the Home Screen.
3. **Window 3 (VS Code):** Have [`../lib/features/dashboard/home/home_screen.dart`](../lib/features/dashboard/home/home_screen.dart) open.
4. **Window 4 (Terminal):** Have terminal ready in the project root directory.

---

## Step-by-Step Presentation Script

### Step 1: Greeting & App Purpose
- **What to show:** Show the app running on the emulator.
- **What to say:**
  > "Good day everyone. Our group created PokéPoke, a retro-styled Pokémon companion mobile app built in Flutter. It communicates with the official public PokéAPI to fetch Pokémon data, displays sprites with real proportional height scaling, and features an interactive evolution tree and step-based exploration."

---

### Step 2: Presenting the PokéAPI & Endpoints
- **What to show:** Switch to the browser tab showing the PokéAPI documentation.
- **What to say:**
  > "We selected PokéAPI version 2. It is a free, public REST API that requires no authentication keys. Our app consumes three main endpoints:
  > 
  > First, `/pokemon/{id_or_name}` to fetch the Pokémon's name, elemental types, height, weight, and sprite image.
  > 
  > Second, `/pokemon-species/{id}` to fetch lore descriptions and discover the evolution chain link.
  > 
  > Third, `/evolution-chain/{id}` to retrieve complete multi-stage evolution paths."

- **Command to run in terminal:**
```bash
curl -s "https://pokeapi.co/api/v2/pokemon/pikachu" | jq '{id: .id, name: .name, height: .height, weight: .weight}'
```
- **What to explain after running:**
  > "As you can see in the terminal, PokéAPI returned Pikachu with ID 25, height 4 decimeters, and weight 60 hectograms in JSON format."

---

### Step 3: Screen Layouts & Navigation
- **What to show:** Switch to the emulator and point out the screens.
- **What to say:**
  > "Our app has six main screen modules:
  > 
  > 1. The Splash Screen which initializes offline data and plays retro 8-bit music.
  > 2. The Home Feed which displays cards with proportional height sizing and elemental type filters.
  > 3. The Detail Sheet which slides up when a Pokémon is tapped to show stats, abilities, weaknesses, and clickable evolution nodes.
  > 4. The Favourites Screen for bookmarked Pokémon.
  > 5. The PokéWalk Arena for motion-sensor walking exploration.
  > 6. The Safari Meadow Sanctuary where caught Pokémon roam around."

---

### Step 4: Reusable Widgets
- **What to show:** In VS Code, open [`../lib/core/widgets/hold_to_spam_button.dart`](../lib/core/widgets/hold_to_spam_button.dart).
- **What to say:**
  > "We created reusable components including our custom `HoldToSpamButton` which auto-fires continuous actions when held down, `ShimmerBox` for loading animations, and 3D tactile buttons powered by NeoPoP."

---

## Hand-Off Cue (Passing the Mic)

- **Say this exact sentence to pass the mic to Royette:**
  > "I will now pass the floor to Royette, who will explain the packages we used and demonstrate our API requests and Dio integration."

---

## Teacher Q&A Cheat Sheet (Common Questions)

**Q: "Why did you choose PokéAPI instead of a movie or weather API?"**  
> **Answer:** *"PokéAPI provides rich nested relationships like multi-stage evolution chains, elemental types, and height-to-weight dimensions, which let us demonstrate complex JSON parsing and responsive UI layouts."*

**Q: "Does PokéAPI require an API key?"**  
> **Answer:** *"No, PokéAPI is completely open and public, which makes it reliable and free from token expiration during demos."*
