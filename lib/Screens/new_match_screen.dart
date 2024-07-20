import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scorebuddy/Models/match_model.dart';
import 'dart:async';

import '../Models/game_model.dart';
import '../Models/player_model.dart';
import '../Models/score_model.dart';
import '../Utils/database.dart';
import 'new_player_screen.dart';

class NewMatch extends StatefulWidget {
  const NewMatch({super.key});

  @override
  NewMatchState createState() => NewMatchState();
}

class NewMatchState extends State<NewMatch> {
  DatabaseHelper databaseHelper = DatabaseHelper.instance;  
  TextEditingController targetScoreController = TextEditingController();
  // ignore: avoid_init_to_null
  var selectedGame = null;
  bool _selectAll = false;

  List<Player> matchPlayers = [];
  List<Player> selectedPlayers = [];
  List<Player> allPlayers = [];
  List<Game> allGames = [];

  //initialaizing score
  List<Score> scoresToAdd = [];

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
    List<Player> players = await databaseHelper.getAllPlayers();
    setState(() {
      allPlayers = players;
    });
  }

  Future<void> fetchGames() async {
    try {
      List<Game> groupsList = await databaseHelper.getAllGames();
      setState(() {
        allGames = groupsList;
        debugPrint('Fetched Games: $allGames');
      });
    } catch (e) {
      debugPrint('Error fetching Games: $e');
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
      body: Padding(
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
              onChanged: (value) {
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
              decoration:  InputDecoration(
                labelText: 'Game',
                labelStyle: const TextStyle(color: Colors.white),
                hintText: 'winning',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: targetScoreController,
              keyboardType: const TextInputType.numberWithOptions(decimal: false, signed: false),
              decoration: InputDecoration(
                suffixIcon: const Icon(CupertinoIcons.tray_arrow_up_fill),
                labelText: 'Target',
                labelStyle: const TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
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
                    try {
                      Game game = selectedGame;
                      int target = int.parse(targetScoreController.text);
                      // Save the match and retrieve the generated match ID
                      Match match = Match(game.id, game.name, target);
                      int matchId = await databaseHelper.insertMatch(match);

                      // create scores for each player involved in the match
                      for (Player player in selectedPlayers) {
                        Score score = Score(
                            gameId: game.id,
                            matchId: matchId,
                            playerId: player.id,
                            score: 0,
                            won: 0);
                        scoresToAdd.add(score);
                        await databaseHelper.insertScore(score);
                      }
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                    } catch (e) {
                      _showSnackBar(context, 'Error');
                    }
                  } else {
                    _showSnackBar(
                        context, 'at least 2 players should be selected');
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
