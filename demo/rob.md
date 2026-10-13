# Member 3 Presentation Guide — Rob

> **Role:** Member 3 — Models, JSON Parsing, and Data Handling  
> **Presenter:** Rob  
> **Relevant Code Files:**  
> - Pokémon Model: [`../lib/core/services/pokemon_service.dart`](../lib/core/services/pokemon_service.dart#L6-L102)  
> - Caught Pokémon Model: [`../lib/features/battle/data/caught_pokemon.dart`](../lib/features/battle/data/caught_pokemon.dart)  
> - Detail Sheet UI: [`../lib/features/dashboard/home/widgets/pokemon_detail_sheet.dart`](../lib/features/dashboard/home/widgets/pokemon_detail_sheet.dart)  

---

## Tools to Open Before You Speak

1. **Window 1 (VS Code):** Open [`../lib/core/services/pokemon_service.dart`](../lib/core/services/pokemon_service.dart) and highlight lines 6 through 93.
2. **Window 2 (Terminal):** Have terminal ready in the project directory.

---

## Step-by-Step Presentation Script

### Step 1: The Raw JSON Payload
- **What to show:** Terminal window.
- **What to say:**
  > "Thank you, Royette. Good day everyone, I am Rob. I will explain how we parse raw JSON from PokéAPI into Dart objects.
  > 
  > A full Pokémon response from PokéAPI is huge—often over 300 kilobytes with hundreds of unnecessary fields. To keep our app lightweight and fast, we extract only the key properties: ID, name, types, height, and weight."

- **Command to run in terminal:**
```bash
curl -s "https://pokeapi.co/api/v2/pokemon/charizard" | jq '{id: .id, name: .name, types: [.types[].type.name], height: .height, weight: .weight}'
```
- **What to say after running:**
  > "Here you can see the cleaned JSON structure returned for Charizard: ID 6, types fire and flying, height 17, and weight 905."

---

### Step 2: The `PokemonEntry` Class in Dart
- **What to show:** Switch to VS Code at [`../lib/core/services/pokemon_service.dart#L6-L20`](../lib/core/services/pokemon_service.dart).
- **What to say:**
  > "In `pokemon_service.dart`, we define our `PokemonEntry` model with five core properties:
  > - `id`: an integer for the Pokédex number.
  > - `name`: a string.
  > - `types`: a list of strings representing the elemental types.
  > - `height`: an integer in decimeters.
  > - `weight`: an integer in hectograms."

---

### Step 3: JSON Deserialization (`fromApi` vs `fromMap`)
- **What to show:** Highlight lines 79–93 (`fromApi`) and lines 50–77 (`fromMap`).
- **What to say:**
  > "We created two factory constructors:
  > 
  > `fromApi()` handles fresh responses coming over the network. In PokéAPI, types are nested inside objects like `[{'slot': 1, 'type': {'name': 'fire'}}]`. Our factory maps that nested list directly into a clean `List<String>`.
  > 
  > `fromMap()` and `toMap()` handle reading and writing to our local offline `SharedPreferences` cache as plain JSON maps."

---

### Step 4: Computed Properties for the UI
- **What to show:** Highlight lines 21–48 of `pokemon_service.dart`.
- **What to say:**
  > "Instead of cluttering our UI widgets with formatting code, our model provides computed getters:
  > - `formattedId`: converts `25` into `#025` using `.padLeft(3, '0')`.
  > - `displayName`: capitalizes the name and cleans up hyphens.
  > - `formattedHeight` and `formattedWeight`: convert raw numbers into `'1.7 m'` and `'90.5 kg'`.
  > - `spriteSize`: mathematically scales the image between 72 pixels and 125 pixels based on actual Pokémon height."

---

## Hand-Off Cue (Passing the Mic)

- **Say this exact sentence to pass the mic to Kent:**
  > "I will now pass the floor to Kent, who will demonstrate our state management, automated tests, and walk you through the live app demonstration!"

---

## Teacher Q&A Cheat Sheet (Common Questions)

**Q: "Why did you use `factory` constructors instead of regular constructors?"**  
> **Answer:** *"Factory constructors in Dart allow us to process, validate, and transform the incoming JSON map before returning an instantiated `PokemonEntry` object."*

**Q: "How do you handle missing or null data from the API?"**  
> **Answer:** *"We use null-aware operators like `(data['height'] as num?)?.toInt()` and fallback defaults to ensure the app never crashes on missing fields."*
