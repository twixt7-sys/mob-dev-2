import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/pokemon.dart';

class PokemonPage extends StatefulWidget {
  const PokemonPage({super.key});

  @override
  State<PokemonPage> createState() => _PokemonPageState();
}

class _PokemonPageState extends State<PokemonPage> {
  final TextEditingController _nameController =
      TextEditingController(text: 'pikachu');

  Pokemon? _pokemon;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _lookupPokemon();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _lookupPokemon() async {
    if (_isLoading) return;

    final name = _nameController.text.trim().toLowerCase();
    if (name.isEmpty) {
      setState(() {
        _pokemon = null;
        _errorMessage = 'Enter a Pokémon name to start a search.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _pokemon = null;
      _errorMessage = null;
    });

    try {
      final response = await http
          .get(
            Uri.parse(
              'https://pokeapi.co/api/v2/pokemon/${Uri.encodeComponent(name)}',
            ),
          )
          .timeout(const Duration(seconds: 12));

      if (!mounted) return;

      if (response.statusCode == 404) {
        _showError(
            'No Pokémon named "$name" was found. Check the spelling and try again.');
        return;
      }

      if (response.statusCode != 200) {
        _showError(
            'The Pokémon service returned error ${response.statusCode}. Try again later.');
        return;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('The response is not a Pokémon object.');
      }

      final pokemon = Pokemon.fromJson(decoded);
      if (!mounted) return;

      setState(() {
        _pokemon = pokemon;
        _isLoading = false;
      });
    } on TimeoutException {
      _showError(
          'The request took too long. Check your connection and try again.');
    } on http.ClientException {
      _showError(
          'Could not reach the Pokémon service. Check your internet connection and try again.');
    } on FormatException {
      _showError(
          'The Pokémon service returned data the app could not read. Try again later.');
    } catch (_) {
      _showError(
          'Could not load this Pokémon. Check your connection and try again.');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    setState(() {
      _pokemon = null;
      _errorMessage = message;
      _isLoading = false;
    });
  }

  String _displayName(String name) {
    return name
        .split('-')
        .map((part) => part.isEmpty
            ? part
            : '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F5F1),
      appBar: AppBar(
        title: const Text('Pokémon Lookup'),
        centerTitle: true,
        backgroundColor: const Color(0xFFC72D3B),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildSearchPanel(),
          Expanded(child: _buildResult()),
        ],
      ),
    );
  }

  Widget _buildSearchPanel() {
    return Container(
      color: const Color(0xFFC72D3B),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _nameController,
              enabled: !_isLoading,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _lookupPokemon(),
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Enter a Pokémon name',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          FilledButton(
            onPressed: _isLoading ? null : _lookupPokemon,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A5F),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 16),
            ),
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  Widget _buildResult() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Looking up Pokémon...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.info_outline,
                  size: 48, color: Color(0xFFC72D3B)),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    if (_pokemon == null) {
      return const Center(
          child: Text('Search for a Pokémon to see its details.'));
    }

    return _buildDetails(_pokemon!);
  }

  Widget _buildDetails(Pokemon pokemon) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPokemonHeader(pokemon),
          const SizedBox(height: 16),
          _sectionCard(
            title: 'Details',
            child: Column(
              children: [
                _infoRow('ID', '#${pokemon.id}'),
                _infoRow('Height', '${pokemon.height / 10} m'),
                _infoRow('Weight', '${pokemon.weight / 10} kg'),
              ],
            ),
          ),
          _sectionCard(
            title: 'Abilities',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: pokemon.abilities
                  .map((ability) => Chip(label: Text(_displayName(ability))))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPokemonHeader(Pokemon pokemon) {
    return Column(
      children: [
        SizedBox(
          width: 180,
          height: 180,
          child: pokemon.spriteUrl == null
              ? const Icon(Icons.catching_pokemon,
                  size: 110, color: Color(0xFFC72D3B))
              : Image.network(
                  pokemon.spriteUrl!,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.catching_pokemon,
                    size: 110,
                    color: Color(0xFFC72D3B),
                  ),
                ),
        ),
        Text(
          _displayName(pokemon.name),
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E3A5F),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: pokemon.types
              .map(
                (type) => Chip(
                  label: Text(_displayName(type)),
                  backgroundColor: const Color(0xFFFFD76A),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 0,
        color: Colors.white,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE5E1D8)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A5F),
                ),
              ),
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
