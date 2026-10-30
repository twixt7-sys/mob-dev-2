# Pokémon Lookup

A simple Flutter application for looking up Pokémon through the public [PokéAPI](https://pokeapi.co/).

## What the app does

1. The user enters a Pokémon name, such as `pikachu`, and selects **Search**.
2. The app sends an HTTP GET request to `https://pokeapi.co/api/v2/pokemon/{name}`.
3. When the server responds successfully, the app decodes the JSON response and displays the Pokémon's name, ID, height, weight, abilities, types, and front sprite.
4. The Search button and text field are disabled while a request is running, and a loading indicator is shown. This prevents duplicate requests and confusing results.

## Handling problems

- A `404 Not Found` response shows a message that the Pokémon was not found and suggests checking the spelling.
- Other unsuccessful HTTP responses show the returned status code without trying to decode invalid data.
- Timeouts and network/client errors tell the user to check their connection and retry.
- If a successful response has invalid or unexpected JSON, the app shows a safe error message instead of crashing.

## Offline idea

This activity does not add a local database or synchronization. In a future version, the app could save each successfully retrieved Pokémon locally. If a later request fails while offline, it could show the saved details with a clear message that the data may not be current and offer a refresh button when a connection returns.

## Run the project

```bash
flutter pub get
flutter run
```
