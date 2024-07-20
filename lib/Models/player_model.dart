class Player {
  int id = 0;
  String name;

  Player(this.name);
  Player.withId(this.id, this.name);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map['name'] = name;

    return map;
  }

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player.withId(map['id'], map['name']);
  }
}
