class Pokemon {
  const Pokemon({
    required this.id,
    required this.name,
    required this.height,
    required this.weight,
    required this.abilities,
    required this.types,
    required this.spriteUrl,
  });

  final int id;
  final String name;
  final int height;
  final int weight;
  final List<String> abilities;
  final List<String> types;
  final String? spriteUrl;

  /// Creates a Pokemon object from the JSON returned by PokeAPI.
  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final sprites = json['sprites'];

    // Prefer an animated GIF. The Black/White GIFs only exist up to Gen 5,
    // so newer Pokémon use the Showdown GIF. Otherwise use the still image.
    final frontSprite = _stringAt(sprites, [
          'versions',
          'generation-v',
          'black-white',
          'animated',
          'front_default',
        ]) ??
        _stringAt(sprites, ['other', 'showdown', 'front_default']) ??
        _stringAt(sprites, ['front_default']);

    return Pokemon(
      id: _requiredInt(json, 'id'),
      name: _requiredString(json, 'name'),
      height: _requiredInt(json, 'height'),
      weight: _requiredInt(json, 'weight'),
      abilities: _namesFromList(json['abilities'], 'ability'),
      types: _namesFromList(json['types'], 'type'),
      spriteUrl: frontSprite,
    );
  }

  /// Follows a list of keys into nested maps and returns the String found
  /// there, or null if any step is missing or has the wrong type.
  static String? _stringAt(dynamic value, List<String> keys) {
    for (final key in keys) {
      if (value is! Map) return null;
      value = value[key];
    }
    return value is String ? value : null;
  }

  static int _requiredInt(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! int) {
      throw FormatException('Missing or invalid "$key" value.');
    }
    return value;
  }

  static String _requiredString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String) {
      throw FormatException('Missing or invalid "$key" value.');
    }
    return value;
  }

  static List<String> _namesFromList(dynamic value, String nestedKey) {
    if (value is! List) {
      throw FormatException('Missing or invalid "$nestedKey" list.');
    }

    return value.map((item) {
      if (item is! Map || item[nestedKey] is! Map) {
        throw FormatException('Invalid "$nestedKey" item.');
      }

      final name = item[nestedKey]['name'];
      if (name is! String) {
        throw FormatException('Invalid "$nestedKey" name.');
      }
      return name;
    }).toList();
  }
}
