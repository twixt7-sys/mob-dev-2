import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pokemon_viewer/models/pokemon.dart';

void main() {
  test('Pokemon.fromJson reads a real PokeAPI response', () {
    final json = jsonDecode(
      File('assets/pokemon_api_168.json').readAsStringSync(),
    ) as Map<String, dynamic>;

    final pokemon = Pokemon.fromJson(json);

    expect(pokemon.id, 168);
    expect(pokemon.name, 'ariados');
    expect(pokemon.height, 11);
    expect(pokemon.weight, 335);
    expect(pokemon.abilities, contains('swarm'));
    expect(pokemon.types, contains('bug'));
  });

  test('Pokemon.fromJson rejects data with missing fields', () {
    expect(
      () => Pokemon.fromJson({'name': 'pikachu'}),
      throwsA(isA<FormatException>()),
    );
  });
}
