import 'package:cloud_firestore/cloud_firestore.dart';

class Game {
  String id;
  String name;

  Game(this.name) : id = ''; // Default id to 0 if not provided
  Game.withId(this.id, this.name);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map['name'] = name;
    map['id'] = id; // Include id only if it is not 0
    return map;
  }

  factory Game.fromMap(Map<String, dynamic> map) {
    return Game.withId(map['id'], map['name']);
  }

  factory Game.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Game.withId(doc.id, data['name'] ?? ''); // Use hashCode to convert doc.id to int
  }
}
