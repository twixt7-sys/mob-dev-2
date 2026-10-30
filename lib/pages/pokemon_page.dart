import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../models/pokemon.dart';

class PokemonPage extends StatefulWidget {
  const PokemonPage({super.key});

  @override
  State<PokemonPage> createState() => _PokemonPageState();
}

class _PokemonPageState extends State<PokemonPage> {
  Pokemon? pokemon;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    loadPokemon();
  }

  Future<void> loadPokemon() async {
    try {
      final text = await rootBundle.loadString('assets/pokemon_api_168.json');
      final decoded = jsonDecode(text) as Map<String, dynamic>;
      setState(() {
        pokemon = Pokemon.fromJson(decoded);
        isLoading = false;
      });
    } catch (e) {
      debugPrint('ERROR: $e');
      setState(() {
        errorMessage = 'Could not load data:\n$e';
        isLoading = false;
      });
    }
  }

  String capitalize(String text) {
    return text[0].toUpperCase() + text.substring(1);
  }

  Widget sectionCard(String title, Widget content) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            content,
          ],
        ),
      ),
    );
  }

  Widget infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = pokemon;

    Widget body;

    if (isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (p == null) {
      body = Center(child: Text(errorMessage));
    } else {
      body = buildDetails(p);
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Pokemon Viewer'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: body,
    );
  }

  Widget buildDetails(Pokemon p) {
    // Abilities: one text line each
    List<Widget> abilityTexts = [];
    for (String ability in p.abilities) {
      abilityTexts.add(Text(ability.replaceAll('-', ' ')));
    }

    // Held items: show "None" if the list is empty
    Widget heldItemsContent;
    if (p.heldItems.isEmpty) {
      heldItemsContent = const Text('None');
    } else {
      heldItemsContent = Text(p.heldItems.join(', '));
    }

    // Types: small chips
    List<Widget> typeChips = [];
    for (String type in p.types) {
      typeChips.add(Chip(label: Text(type)));
    }

    // Stats: one row each
    List<Widget> statRows = [];
    p.stats.forEach((statName, value) {
      statRows.add(infoRow(statName, value.toString()));
    });

    // Moves: one chip each
    List<Widget> moveChips = [];
    for (String move in p.moves) {
      moveChips.add(Chip(label: Text(move.replaceAll('-', ' '))));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Sprite, name and id
          Image.network(
            p.spriteUrl,
            width: 160,
            height: 160,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.none,
          ),
          Text(
            capitalize(p.name),
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          Text('#${p.id}', style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: typeChips),
          const SizedBox(height: 16),

          // Basic info
          sectionCard(
            'Basic Info',
            Column(
              children: [
                infoRow('ID', p.id.toString()),
                infoRow('Base experience', p.baseExperience.toString()),
                infoRow('Height', '${p.height / 10} m'),
                infoRow('Weight', '${p.weight / 10} kg'),
              ],
            ),
          ),

          // Stats
          sectionCard('Stats', Column(children: statRows)),

          // Abilities
          sectionCard(
            'Abilities',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: abilityTexts,
            ),
          ),

          // Held items
          sectionCard('Held Items', heldItemsContent),

          // Moves
          sectionCard(
            'Moves (${p.moves.length})',
            Wrap(spacing: 6, runSpacing: 6, children: moveChips),
          ),
        ],
      ),
    );
  }
}
