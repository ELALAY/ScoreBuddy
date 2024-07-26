import 'package:flutter/material.dart';
import '../services/sqflite/database.dart';
import '../services/realtime_db/firebase_db.dart';

class NewGame extends StatefulWidget {
  const NewGame({super.key});

  @override
  State<NewGame> createState() => _NewGameState();
}

class _NewGameState extends State<NewGame> {
  FirebaseDatabaseHelper firebaseDatabaseHelper = FirebaseDatabaseHelper();

  TextEditingController gameNameController = TextEditingController();


  void fbcreateGame(String gameName) async {
    try {
      await firebaseDatabaseHelper.createGame(gameName);
      debugPrint('Game Created: $gameName');
    } catch (e) {
      _showSnackBar(context, 'Failed to create game: $e');
    }
  }

  Future<bool> fbcheckingName(String name) async {
    try {
      return await firebaseDatabaseHelper.checkingGameName(name);
    } catch (e) {
      _showSnackBar(context, 'Error checking game name: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Game'),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
                controller: gameNameController,
                decoration: InputDecoration(
                  icon: Icon(
                    Icons.gamepad_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  labelText: 'Game name',
                  labelStyle:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 16.0,
            ),
            ElevatedButton(
                onPressed: () async {
                  //bool exists = await checkingName(gameNameController.text);
                  bool fbexists = await fbcheckingName(gameNameController.text);
                  if (!fbexists) {
                    //createGame(gameNameController.text);
                    fbcreateGame(gameNameController.text);
                    // ignore: use_build_context_synchronously
                    Navigator.pop(context);
                  } else {
                    // ignore: use_build_context_synchronously
                    _showSnackBar(context, 'Game Name Already Exists!');
                  }
                },
                child: const Text('Create')),
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
