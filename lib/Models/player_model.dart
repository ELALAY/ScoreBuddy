import 'package:cloud_firestore/cloud_firestore.dart';
class Player {
  String id = '';
  String name;

  Player(this.name);
  Player.withId(this.id, this.name);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map['username'] = name;

    return map;
  }

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player.withId(map['id'], map['username']);
  }

  factory Player.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Player.withId(doc.id, data['username'] ?? ''); // Use hashCode to convert doc.id to int
  }
}
