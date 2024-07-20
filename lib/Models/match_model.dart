class Match {
  int id = 0;
  int gameId;
  String name;

  Match(this.gameId, this.name);
  Match.withId(this.id, this.gameId, this.name);

  // Convert a Match instance to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'gameId': gameId,
      'name': name,
    };
  }

  factory Match.fromMap(Map<String, dynamic> map) {
    return Match.withId(map['id'] ?? 0, map['gameId'] ?? 0, map['name'] ?? "N/A");
  }
}
