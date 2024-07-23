import 'package:cloud_firestore/cloud_firestore.dart';
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

  factory Player.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Player.withId(doc.id.hashCode, data['name'] ?? ''); // Use hashCode to convert doc.id to int
  }
}
