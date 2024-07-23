import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../../Models/player_model.dart';
import '../../Models/room_model.dart';
import '../../Models/score_model.dart';

class FirebaseDatabaseHelper {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

//--------------------------------------------------------------------------------------
//********  Games Functions**********/
//--------------------------------------------------------------------------------------

  Future<void> createGame(String gameName) async {
    try {
      await _db.collection('games').add({
        'name': gameName,
      });
      debugPrint('Game $gameName created successfully');
    } catch (e) {
      debugPrint('Error creating game: $e');
    }
  }

  // Checking for unique game names
  Future<bool> checkingGameName(String name) async {
    try {
      QuerySnapshot querySnapshot =
          await _db.collection('games').where('name', isEqualTo: name).get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking game name: $e');
      return false;
    }
  }

//--------------------------------------------------------------------------------------
//********  Players Functions**********/
//--------------------------------------------------------------------------------------

  Future<void> createRoom(Room newRoom) async {
    try {
      // Add the map to the Firestore collection
      await FirebaseFirestore.instance.collection('rooms').add(
            newRoom.toMap(),
          );
      debugPrint("Room created successfully");
    } catch (e) {
      debugPrint("Error creating room: $e");
    }
  }

  Future<List<Room>> getAllRooms() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('rooms').get();
      return snapshot.docs.map((doc) => Room.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint("Error fetching: $e");
      return [];
    }
  }

  Future<void> updateScores(
      String matchId, List<PlayerScore> updatedScores) async {
    try {
      await FirebaseFirestore.instance.collection('rooms').doc(matchId).update({
        'playerScores': updatedScores.map((ps) => ps.toMap()).toList(),
      });
      debugPrint("Scores updated successfully");
    } catch (e) {
      debugPrint("Error updating scores: $e");
    }
  }

  Future<void> deleteRoom(String roomName) async {
    try {
      // Query the document with the specified roomName
      QuerySnapshot querySnapshot = await _db.collection('rooms').where('roomName', isEqualTo: roomName).get();

      // Check if a matching document exists
      if (querySnapshot.docs.isNotEmpty) {
        // Get the document ID
        String documentId = querySnapshot.docs.first.id;

        // Delete the document
        await _db.collection('rooms').doc(documentId).delete();
        debugPrint("Room deleted successfully");
      } else {
        debugPrint("No room found with the name: $roomName");
      }
    } catch (e) {
      debugPrint("Error deleting room: $e");
      rethrow;
    }
  }

  Future<Room?> getRoom(String roomName) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('rooms')
          .where('name', isEqualTo: roomName)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        return Room.fromFirestore(querySnapshot.docs.first);
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('Error getting room: $e');
      return null;
    }
  }

  // Checking for unique game names
  Future<bool> checkingRoomName(String name) async {
    try {
      QuerySnapshot querySnapshot =
          await _db.collection('rooms').where('name', isEqualTo: name).get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking game name: $e');
      return false;
    }
  }
//--------------------------------------------------------------------------------------
//********  Players Functions**********/
//--------------------------------------------------------------------------------------

  Future<void> createPlayer(String playerName) async {
    try {
      await _db.collection('players').add({
        'name': playerName,
      });
      debugPrint('player $playerName created successfully');
    } catch (e) {
      debugPrint('Error creating game: $e');
    }
  }

  // Checking for unique game names
  Future<bool> checkingPlayerName(String name) async {
    try {
      QuerySnapshot querySnapshot =
          await _db.collection('players').where('name', isEqualTo: name).get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking game name: $e');
      return false;
    }
  }

  Future<List<Player>> getAllPlayers() async {
    List<Player> players = [];
    try {
      QuerySnapshot snapshot = await _db.collection('players').get();
      players = snapshot.docs.map((doc) => Player.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching players: $e');
    }
    return players;
  }
}
