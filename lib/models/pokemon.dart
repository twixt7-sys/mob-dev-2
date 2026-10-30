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
    final frontSprite = sprites is Map ? sprites['front_default'] : null;

    if (frontSprite != null && frontSprite is! String) {
      throw const FormatException('The Pokémon sprite has an invalid format.');
    }

    return Pokemon(
      id: _requiredInt(json, 'id'),
      name: _requiredString(json, 'name'),
      height: _requiredInt(json, 'height'),
      weight: _requiredInt(json, 'weight'),
      abilities: _namesFromList(json['abilities'], 'ability'),
      types: _namesFromList(json['types'], 'type'),
      spriteUrl: frontSprite as String?,
    );
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
