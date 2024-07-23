import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

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
}
