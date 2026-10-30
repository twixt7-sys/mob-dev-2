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
    expect(pokemon.spriteUrl, endsWith('/black-white/animated/168.gif'));
  });

  test('Pokemon.fromJson falls back to the still sprite', () {
    final pokemon = Pokemon.fromJson({
      'id': 25,
      'name': 'pikachu',
      'height': 4,
      'weight': 60,
      'abilities': [],
      'types': [],
      'sprites': {'front_default': 'https://example.com/25.png'},
    });

    expect(pokemon.spriteUrl, 'https://example.com/25.png');
  });

  test('Pokemon.fromJson rejects data with missing fields', () {
    expect(
      () => Pokemon.fromJson({'name': 'pikachu'}),
      throwsA(isA<FormatException>()),
    );
  });
}
