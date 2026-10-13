# Member 2 Presentation Guide — Royette

> **Role:** Member 2 — Packages and API Integration  
> **Presenter:** Royette  
> **Relevant Code Files:**  
> - Dependencies: [`../pubspec.yaml`](../pubspec.yaml)  
> - Dio Client: [`../lib/core/services/poke_api_client.dart`](../lib/core/services/poke_api_client.dart)  
> - API Service & Pagination: [`../lib/core/services/pokemon_service.dart`](../lib/core/services/pokemon_service.dart)  
> - Offline Cache: [`../lib/core/services/cache_service.dart`](../lib/core/services/cache_service.dart)  

---

## Tools to Open Before You Speak

1. **Window 1 (VS Code):** Open [`../pubspec.yaml`](../pubspec.yaml) and keep [`../lib/core/services/poke_api_client.dart`](../lib/core/services/poke_api_client.dart) ready in a second tab.
2. **Window 2 (Terminal):** Have terminal ready in the project directory.

---

## Step-by-Step Presentation Script

### Step 1: Presenting Packages in `pubspec.yaml`
- **What to show:** Highlight lines 30–50 of [`../pubspec.yaml`](../pubspec.yaml).
- **What to say:**
  > "Thank you, Jehlia. I will now explain the packages we integrated and how we communicate with PokéAPI using Dio.
  > 
  > In `pubspec.yaml`, we added:
  > - `dio`: our HTTP client for REST requests, timeouts, and headers.
  > - `cached_network_image`: to cache sprite images so we don't re-download artwork repeatedly.
  > - `connectivity_plus`: to check network availability before firing requests.
  > - `shared_preferences`: for saving downloaded Pokémon, favourites, and inventory locally.
  > - `neopop`: for 3D retro neo-brutalist buttons.
  > - `audioplayers`: to loop our 8-bit chiptune background music.
  > - `pedometer` and `permission_handler`: to track physical device steps."

---

### Step 2: The Dio Client Singleton
- **What to show:** Switch to [`../lib/core/services/poke_api_client.dart`](../lib/core/services/poke_api_client.dart).
- **What to say:**
  > "Instead of creating a new client every time, we configure a single shared Dio instance. We set a base URL of `https://pokeapi.co/api/v2`, connection and receive timeouts of 8 seconds to prevent freezing on bad signals, and a custom User-Agent header."

---

### Step 3: Demonstrating GET Requests & HTTP Status Codes
- **What to show:** Switch to your terminal window.
- **What to say:**
  > "Now I will demonstrate how our GET requests behave under both successful and error scenarios.
  > 
  > First, a valid GET request to fetch Pikachu. We expect an HTTP 200 OK status code."

- **Command to run for HTTP 200 OK:**
```bash
curl -i -s "https://pokeapi.co/api/v2/pokemon/pikachu" | head -n 12
```
- **What to say after running:**
  > "Notice the status line: `HTTP/2 200`. The server returns JSON headers and body, which our app deserializes.
  > 
  > Now, what happens if a user searches for an invalid Pokémon? The server returns HTTP 404 Not Found."

- **Command to run for HTTP 404 Not Found:**
```bash
curl -i -s "https://pokeapi.co/api/v2/pokemon/fakemon999" | head -n 12
```
- **What to say after running:**
  > "Notice `HTTP/2 404 Not Found`. In `PokemonService.dart`, our code catches this with a `try-catch` block so the app never crashes; instead, it presents an error notice to the user."

---

### Step 4: Batch Pagination
- **What to show:** In VS Code, open [`../lib/core/services/pokemon_service.dart#L228`](../lib/core/services/pokemon_service.dart).
- **What to say:**
  > "When the user taps the '+ 10 MORE POKÉMON' button, we fetch 10 Pokémon in parallel using `Future.wait()`. We merge the new entries into our list and immediately save them to local storage."

- **Command to run batch query:**
```bash
for id in 1 2 3; do curl -s "https://pokeapi.co/api/v2/pokemon/$id" | jq -r '"#\(.id) \(.name | ascii_upcase) - Height: \(.height*10)cm, Weight: \(.weight/10)kg"'; done
```

---

## Hand-Off Cue (Passing the Mic)

- **Say this exact sentence to pass the mic to Rob:**
  > "I will now pass the floor to Rob, who will explain how raw JSON responses are converted into our Dart data models."

---

## Teacher Q&A Cheat Sheet (Common Questions)

**Q: "Why did you use Dio instead of the default `http` package?"**  
> **Answer:** *"Dio gives us built-in timeouts, default base URL configuration, and cleaner error handling out of the box, whereas the basic http package requires manual wrapper code."*

**Q: "What happens if the device is offline?"**  
> **Answer:** *"Our app uses `connectivity_plus` to detect offline mode and immediately falls back to our local seed data and cached records in `SharedPreferences`, so the Pokédex remains fully functional without crashing."*
