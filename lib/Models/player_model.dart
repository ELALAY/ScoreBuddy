class Player {
  int id;
  String name;

  Player(this.id, this.name);
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
