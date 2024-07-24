import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scorebuddy/Models/room_model.dart';
import 'package:scorebuddy/Models/score_model.dart';
import 'dart:async';

import '../Models/game_model.dart';
import '../Models/player_model.dart';
import '../services/realtime_db/firebase_db.dart';
import '../services/sqflite/database.dart';
import 'new_player_screen.dart';

class NewMatch extends StatefulWidget {
  const NewMatch({super.key});

  @override
  NewMatchState createState() => NewMatchState();
}

class NewMatchState extends State<NewMatch> {
  DatabaseHelper databaseHelper = DatabaseHelper.instance;
  FirebaseFirestore fbdatabaseHelper = FirebaseFirestore.instance;
  FirebaseDatabaseHelper firebaseDatabaseHelper = FirebaseDatabaseHelper();

  TextEditingController targetScoreController = TextEditingController();
  TextEditingController roomNameController = TextEditingController();
  // ignore: avoid_init_to_null
  var selectedGame = null;
  String genratedMatchName = "";
  bool _selectAll = false;

  List<Player> selectedPlayers = [];
  List<Player> allPlayers = [];
  List<Game> allGames = [];

  @override
  void initState() {
    super.initState();
    fetchGames();
    fetchAllPlayers();
  }

  void reload() {
    fetchGames();
    fetchAllPlayers();
  }

  Future<void> fetchAllPlayers() async {
    try {
      QuerySnapshot snapshot =
          await fbdatabaseHelper.collection('players').get();
      List<Player> players =
          snapshot.docs.map((doc) => Player.fromFirestore(doc)).toList();
      setState(() {
        allPlayers = players;
      });
    } catch (e) {
      debugPrint('Error fetching games: $e');
    }
  }

  Future<void> fetchGames() async {
    try {
      QuerySnapshot snapshot = await fbdatabaseHelper.collection('games').get();
      List<Game> games =
          snapshot.docs.map((doc) => Game.fromFirestore(doc)).toList();
      setState(() {
        allGames = games;
      });
    } catch (e) {
      debugPrint('Error fetching games: $e');
    }
  }

  Future<void> createRoom(Room newRoom) async {
    try {
      // Add the map to the Firestore collection
      await fbdatabaseHelper.collection('rooms').add(
            newRoom.toMap(),
          );
      debugPrint("Room created successfully");
    } catch (e) {
      debugPrint("Error creating room: $e");
    }
  }

  Future<bool> fbcheckingName(String name) async {
    try {
      return await firebaseDatabaseHelper.checkingRoomName(name);
    } catch (e) {
      _showSnackBar(context, 'Error checking game name: $e');
      return false;
    }
  }

  Future<String> fetchGameId(String name) async {
    try {
      return await firebaseDatabaseHelper.getRoomId(name);
    } catch (e) {
      _showSnackBar(context, 'Error checking game name: $e');
      return '';
    }
  }

  Future<void> createPlayerScore(PlayerScore playerScore) async {
    try {
       await firebaseDatabaseHelper.insertPlayerScore(playerScore);
    } catch (e) {
      _showSnackBar(context, 'Error inserting score of ${playerScore.playerName}: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Match'),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16.0),
            // Groups Dropdown
            DropdownButtonFormField<Game>(
              icon: const Icon(Icons.gamepad, color: Colors.white),
              value: selectedGame,
              hint: const Text(
                'Choose a Game',
                style: TextStyle(color: Colors.white),
              ),
              onChanged: (value) async {
                setState(() {
                  selectedGame = value;
                });
              },
              items: allGames.map((game) {
                return DropdownMenuItem<Game>(
                  value: game,
                  child: Text(
                    game.name,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Game',
                labelStyle: const TextStyle(color: Colors.white),
                hintText: 'Choose Game',
                enabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
                border: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: roomNameController,
              keyboardType: const TextInputType.numberWithOptions(
                  decimal: false, signed: false),
              decoration: InputDecoration(
                suffixIcon: const Icon(CupertinoIcons.tray_arrow_up_fill),
                labelText: selectedGame == null ? "Name" : genratedMatchName,
                labelStyle: const TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
                border: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
                errorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: targetScoreController,
              keyboardType: const TextInputType.numberWithOptions(
                  decimal: false, signed: false),
              decoration: InputDecoration(
                suffixIcon: const Icon(CupertinoIcons.tray_arrow_up_fill),
                labelText: 'Target',
                labelStyle: const TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
                border: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
                errorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
              ),
            ),
            // Persons Dropdown
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: _selectAll,
                      onChanged: (value) {
                        setState(() {
                          _selectAll = value!;
                          if (_selectAll) {
                            selectedPlayers = List.from(allPlayers);
                          } else {
                            selectedPlayers.clear();
                          }
                        });
                      },
                    ),
                    Text('Select All',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary)),
                  ],
                ),
                IconButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return const NewPlayer();
                      }));
                    },
                    icon: const Icon(
                      Icons.person_add,
                      color: Colors.white,
                    )),
              ],
            ),
            Text(
              'Players selection',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 8.0),
            Wrap(
              spacing: 8.0,
              children: allPlayers.map((Player player) {
                return ChoiceChip(
                  label: Text(player.name),
                  selected: selectedPlayers.contains(player),
                  selectedColor: Theme.of(context).colorScheme.primary,
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        selectedPlayers.add(player);
                        if (selectedPlayers.length == allPlayers.length) {
                          _selectAll = true;
                        }
                      } else {
                        selectedPlayers.remove(player);
                        _selectAll = false;
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16.0),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (selectedPlayers.length >= 2) {
                    if (roomNameController.text.trim().isNotEmpty ||
                        targetScoreController.text.isNotEmpty) {
                      Future<bool> exists =
                          fbcheckingName(roomNameController.text.trim());
                      // ignore: unrelated_type_equality_checks
                      if (exists != false) {
                        try {
                          //get match name
                          String roomName = roomNameController.text.trim();
                          int target = int.parse(targetScoreController.text);

                          Room roomTemp = Room(
                              gameName: selectedGame.name,
                              roomName: roomName,
                              targetScore: target,
                              isActive: true);
                          createRoom(roomTemp);

                          for (Player player in allPlayers) {
                            PlayerScore playerScore = PlayerScore(
                                gameName: selectedGame.name,
                                roomName: roomName,
                                playerName: player.name,
                                score: 0);
                            createPlayerScore(playerScore);
                          }

                          // ignore: use_build_context_synchronously
                          Navigator.pop(context);
                        } catch (e) {
                          _showSnackBar(context, 'Error');
                        }
                      } else {
                        _showSnackBar(context, 'Room name already exits!');
                      }
                    } else {
                      _showSnackBar(context, 'all fileds should be filled');
                    }
                  } else {
                    _showSnackBar(
                        context, 'At least 2 players should be selected');
                  }
                },
                child: const Text('Create Match'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
