import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scorebuddy/Models/room_model.dart';
import 'package:scorebuddy/Models/score_model.dart';
import 'dart:async';

import '../Models/game_model.dart';
import '../Models/player_model.dart';
import '../services/auth/auth_service.dart';
import '../services/realtime_db/firebase_db.dart';
import '../services/sqflite/database.dart';
import 'QrCodeMger/scan_qr_code.dart';

class NewMatch extends StatefulWidget {
  const NewMatch({super.key});

  @override
  NewMatchState createState() => NewMatchState();
}

class NewMatchState extends State<NewMatch>
    with SingleTickerProviderStateMixin {
  DatabaseHelper databaseHelper = DatabaseHelper.instance;
  FirebaseFirestore fbdatabaseHelper = FirebaseFirestore.instance;
  FirebaseDatabaseHelper firebaseDatabaseHelper = FirebaseDatabaseHelper();
  final authService = AuthService();

  TextEditingController targetScoreController = TextEditingController();
  TextEditingController roomNameController = TextEditingController();
  late TabController _newRoomTabController;
  // ignore: avoid_init_to_null
  var selectedGame = null;
  String genratedMatchName = "";
  String scannedQrCode = '';

  User? user;
  Map<String, dynamic>? playerProfile;
  Map<String, dynamic>? invitedFriendPlayerProfile;
  String invitedFriendname = '';

  List<Player> selectedPlayers = [];
  List<Player> allPlayers = [];
  List<Game> allGames = [];

  void joinRoom() async {
    if (user != null && playerProfile != null) {
      bool joined = firebaseDatabaseHelper.joinRoom(
          scannedQrCode, playerProfile!['username']) as bool;
      if (joined) {
        _showSnackBar(context, 'joined Room $scannedQrCode Successfully');
      } else {
        _showSnackBar(context, 'Error joining Room!');
      }
    } else {
      _showSnackBar(context, 'Error joining Room!');
    }
  }

  void inviteFriend() async {
    List<String> friendsList =  await firebaseDatabaseHelper.getFriends(playerProfile!['username']);
  }

  void fetchUserProfile(String name) async {
    invitedFriendPlayerProfile =
        await firebaseDatabaseHelper.getPlayerProfile(name);
  }

  void fetchUser() async {
    user = authService.getCurrenctuser();
    if (user != null) {
      playerProfile = await firebaseDatabaseHelper.getPlayerProfile(user!.uid);
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    fetchGames();
    fetchAllPlayers();
    _newRoomTabController = TabController(length: 2, vsync: this);
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
      _showSnackBar(
          context, 'Error inserting score of ${playerScore.playerName}: $e');
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
        bottom: TabBar(
          controller: _newRoomTabController,
          tabs: const [
            Tab(text: 'Add by Name'),
            Tab(text: 'My QrCode'),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: TabBarView(controller: _newRoomTabController, children: [
        SingleChildScrollView(
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
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary),
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
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary),
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
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary),
                  ),
                  errorBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(height: 12.0),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
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
                  },
                  child: const Text('Create Match'),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  const Text('Join Room'),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(color: Colors.grey.shade700),
                      height: 300,
                      width: 300,
                      child: QRScannerScreen(
                        onQRCodeScanned: (qrCode) {
                          setState(() {
                            if (qrCode.isNotEmpty) {
                              scannedQrCode = qrCode;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('joined Room $scannedQrCode')),
                              );
                              joinRoom();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Couldn't add friend")),
                              );
                            }
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                  onPressed: inviteFriend,
                  child: const Text('Invite Friends!')),
            ],
          ),
        ),
      ]),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
