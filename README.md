# Pokémon Lookup

IT 126 – Module 3, Lesson 4 (Communicating with Services): Application activity.

A simple Flutter application for looking up Pokémon through the public [PokéAPI](https://pokeapi.co/). It extends the previous lesson's Pokémon app: instead of reading a JSON map stored inside the program, it now gets the data from the real API.

## What the app does

1. The user enters a Pokémon name, such as `pikachu`, and taps **Search** (or presses Enter).
2. The app sends an HTTP GET request to `https://pokeapi.co/api/v2/pokemon/{name}` using the `http` package.
3. When the server responds successfully, the app decodes the JSON response with `dart:convert` (`jsonDecode`) and turns it into a `Pokemon` object (`lib/models/pokemon.dart`), the same data-modeling idea as the previous lesson.
4. The app displays the Pokémon's name, ID, height, weight, abilities, types, and front sprite.
5. While the request is running, a loading indicator is shown and the Search button and text field are disabled. This prevents repeated submissions and confusing results.

## How requests are handled

| Situation | What the app does |
| --- | --- |
| Successful request (`200 OK`) with valid data | Decodes the JSON, builds a `Pokemon` object, and displays its details. |
| Pokémon does not exist (`404 Not Found`) | Shows "No Pokémon named ... was found. Check the spelling" and does not try to read the response body. |
| Other unsuccessful HTTP response (e.g. `500`) | Shows the returned status code and asks the user to try again later. |
| Network failure (no internet, server unreachable) | Catches the `ClientException` and asks the user to check their connection and try again. |
| Request takes too long (12 s timeout) | Catches the `TimeoutException` and shows a connection message. |
| `200 OK` but the JSON is invalid or missing fields | `Pokemon.fromJson` throws a `FormatException`; the app shows "could not read the data" instead of crashing or showing wrong values. |

## Offline strategy (proposal only)

This activity does not add a local database or synchronization. In a future version, the app could save each successfully retrieved Pokémon on the device (for example with `shared_preferences` or a small local database), keyed by name. If a later request fails because the device is offline, the app could show the saved details with a clear note that the data may not be current, and offer a **Retry** button to refresh when the connection returns. A `404` response would not use the saved data, because the server did answer and the Pokémon really does not exist.

## Analysis answers

1. **What information did the app receive, and how was it different from the previous lesson's JSON map?** The API returned a large JSON object for the Pokémon (ID, name, height, weight, abilities, types, sprites, stats, moves, and more). In the previous lesson the JSON was copied into the program, so it was fixed. Now the data comes live from a server, so any Pokémon can be looked up without changing the app.
2. **What role did the HTTP GET method play?** GET asks the server to return a representation of a resource. The URL `/pokemon/pikachu` identifies the resource, and GET retrieves its data without changing anything on the server.
3. **Why decode the response body first?** The body arrives as plain text (a JSON string). `jsonDecode()` converts it into a Dart `Map`, which allows reading fields like `pokemon['name']`.
4. **What was different when the Pokémon did not exist?** The server returned status `404 Not Found` and the body was not Pokémon data. Checking the status code first prevents the app from trying to decode and display invalid data.
5. **No internet vs. Pokémon does not exist?** With no internet, there is no HTTP response at all, so the app should say to check the connection and allow a retry. With a 404, the server did answer, so retrying the same name will not help; the app should tell the user to check the spelling.
6. **How can the app stay useful offline?** It could store previously viewed Pokémon locally and show them when offline, marked as possibly outdated, with an option to refresh later.

## Project structure

```
lib/
  main.dart                 App entry point
  models/pokemon.dart       Pokemon data model and fromJson()
  pages/pokemon_page.dart   Search screen, HTTP request, loading/error states
test/
  pokemon_test.dart         Tests for Pokemon.fromJson
assets/
  pokemon_api_168.json      Sample PokeAPI response (from the previous lesson, used by the test)
```

## Run the project

```bash
flutter pub get
flutter run
flutter test
```
