import 'package:flutter/material.dart';

import '../Models/game_model.dart';
import '../Utils/database.dart';

class NewGame extends StatefulWidget {
  const NewGame({super.key});

  @override
  State<NewGame> createState() => _NewGameState();
}

class _NewGameState extends State<NewGame> {
  DatabaseHelper databaseHelper = DatabaseHelper.instance;
  TextEditingController gameNameController = TextEditingController();

  void createGame(String gameName) async {
    await databaseHelper.insertGame(gameName);
    debugPrint(gameName);
  }

  //checking for uniaue game names
  Future<bool> checkingName(String name) async {
    bool exists = false;

    Game game = await databaseHelper.getGameByName(name);

    if (game == null) {
      exists = true;
    } else {
      exists = false;
    }

    return exists;
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
                onPressed: () {
                  Future<bool> exists = checkingName(gameNameController.text);
                  // ignore: unrelated_type_equality_checks
                  if (exists == true) {
                    createGame(gameNameController.text);
                  } else {
                    _showSnackBar(context, 'Game Name Already Exists!');
                  }
                  Navigator.pop(context);
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
