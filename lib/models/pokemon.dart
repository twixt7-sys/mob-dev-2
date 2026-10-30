//Data Model
class Pokemon {
  final int id;
  final String name;
  final int baseExperience;
  final int height;
  final int weight; // the API gives this in hectograms (335 = 33.5 kg)
  final String spriteUrl;
  final List<String> types;
  final List<String> abilities;
  final List<String> heldItems;
  final List<String> moves;
  final Map<String, int> stats;

  Pokemon({
    required this.id,
    required this.name,
    required this.baseExperience,
    required this.height,
    required this.weight,
    required this.spriteUrl,
    required this.types,
    required this.abilities,
    required this.heldItems,
    required this.moves,
    required this.stats,
  });

  // Turns the decoded JSON map into a Pokemon object.
  factory Pokemon.fromJson(Map<String, dynamic> json) {
    List<String> abilityList = [];
    for (var item in json['abilities']) {
      String abilityName = item['ability']['name'];
      if (item['is_hidden'] == true) {
        abilityName = '$abilityName (hidden)';
      }
      abilityList.add(abilityName);
    }

    // held_items: each one looks like {"item": {"name": "oran-berry"}}
    // (for Ariados this list is empty)
    List<String> heldItemList = [];
    for (var item in json['held_items']) {
      heldItemList.add(item['item']['name']);
    }

    // moves: each one looks like {"move": {"name": "swords-dance"}}
    List<String> moveList = [];
    for (var item in json['moves']) {
      moveList.add(item['move']['name']);
    }

    // types: each one looks like {"type": {"name": "bug"}}
    List<String> typeList = [];
    for (var item in json['types']) {
      typeList.add(item['type']['name']);
    }

    // stats: each one looks like {"base_stat": 70, "stat": {"name": "hp"}}
    Map<String, int> statMap = {};
    for (var item in json['stats']) {
      statMap[item['stat']['name']] = item['base_stat'];
    }

    return Pokemon(
      id: json['id'] as int,
      name: json['name'] as String,
      baseExperience: json['base_experience'] as int,
      height: json['height'] as int,
      weight: json['weight'] as int,
      spriteUrl: json['sprites']['front_default'] as String,
      types: typeList,
      abilities: abilityList,
      heldItems: heldItemList,
      moves: moveList,
      stats: statMap,
    );
  }
}
