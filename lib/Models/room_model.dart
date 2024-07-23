import 'package:cloud_firestore/cloud_firestore.dart';

class Room {
  String gameName;
  String roomName;
  int targetScore;
  bool isActive;

  Room({
    required this.gameName,
    required this.roomName,
    required this.targetScore,
    required this.isActive,
  });

  // Convert Room object to map
  Map<String, dynamic> toMap() {
    return {
      'gameName': gameName,
      'roomName': roomName, // Ensure this matches the field name in Firestore
      'targetScore': targetScore,
      'isActive': isActive,
    };
  }

  // Convert Firestore document to Room object
  factory Room.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // Parsing the data with type checks
    return Room(
      gameName: data['gameName'] ?? '',
      roomName: data['roomName'] ?? '', // Ensure this matches the field name in Firestore
      targetScore: data['targetScore'] is int
          ? data['targetScore']
          : int.tryParse(data['targetScore'].toString()) ?? 0,
      isActive: data['isActive'] is bool
          ? data['isActive']
          : (data['isActive'].toString().toLowerCase() == 'true'),
    );
  }
}
