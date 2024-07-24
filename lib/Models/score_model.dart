import 'package:cloud_firestore/cloud_firestore.dart';

class PlayerScore {
  String gameName;
  String roomName;
  String playerName;
  int score;

  PlayerScore({
    required this.gameName,
    required this.roomName,
    required this.playerName,
    required this.score,
  });

// Convert PlayerScore object to map
  Map<String, dynamic> toMap() {
    return {
      'gameName': gameName,
      'roomName': roomName,
      'playerName': playerName,
      'score': score,
    };
  }

  // Convert map to PlayerScore object
  factory PlayerScore.fromMap(Map<String, dynamic> map) {
    return PlayerScore(
      gameName: map['gameName'] ?? '',
      roomName: map['roomName'] ?? '',
      playerName: map['playerName'] ??
          '', // Assuming playerId should be int, not string
      score: map['score'] ?? 0,
    );
  }

  factory PlayerScore.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return PlayerScore(
      gameName: data['gameName'] ?? '',
      roomName: data['roomName'] ?? '',
      playerName: data['playerName'] ?? '',
      score: data['score'] ?? 0,
    );
  }
}
