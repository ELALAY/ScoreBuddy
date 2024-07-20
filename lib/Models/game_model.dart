class Game {
  int id;
  String name;

  Game(this.id, this.name);
  Game.withId(this.id, this.name);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};

    map['id'] = id;
    map['name'] = name;

    return map;
  }

  factory Game.fromMap(Map<String, dynamic> map) {
    return Game.withId(map['id'], map['name']);
  }
}
