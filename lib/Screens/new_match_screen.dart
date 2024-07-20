import 'package:flutter/material.dart';
import 'package:scorebuddy/Models/match_model.dart';
import 'dart:async';

import '../Models/game_model.dart';
import '../Models/player_model.dart';
import '../Models/score_model.dart';
import '../Utils/database.dart';

class NewMatch extends StatefulWidget {
  const NewMatch({super.key});

  @override
  NewMatchState createState() => NewMatchState();
}

class NewMatchState extends State<NewMatch> {
  // ignore: avoid_init_to_null
  var selectedGame = null;

  List<Player> matchPlayers = [];
  List<Player> selectedPlayers = [];
  List<Player> allPlayers = [];
  List<Game> allGames = [];

  DatabaseHelper databaseHelper = DatabaseHelper.instance;

  bool _selectAll = false;

  @override
  void initState() {
    super.initState();
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
              icon: Icon(Icons.gamepad,
                  color: Theme.of(context).colorScheme.primary),
              value: selectedGame,
              hint: Text(
                'Associated Group',
                selectionColor: Theme.of(context).colorScheme.primary,
              ),
              onChanged: (value) {
                setState(() {
                  selectedGame = value;
                });
              },
              items: allGames.map((game) {
                return DropdownMenuItem<Game>(
                  value: game,
                  child: Text(game.name),
                );
              }).toList(),
              decoration: InputDecoration(
                  labelText: 'Game',
                  labelStyle:
                      TextStyle(color: Theme.of(context).colorScheme.primary)),
            ),
            const SizedBox(height: 16.0),
            // Persons Dropdown
            const SizedBox(height: 16.0),
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
                        color: Theme.of(context).colorScheme.primary)
                        ),
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
                      } else {
                        selectedPlayers.remove(player);
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
                  try {
                    Game game = selectedGame;
                    // Save the match and retrieve the generated match ID
                    Match match = Match(game.id, game.name);
                    createMatch(match);

                    //initialaizing score
                    Score score;
                    // create scores for each player involved in the match
                    for (Player player in selectedPlayers) {
                      score = Score(
                          gameId: game.id,
                          matchId: match.id,
                          playerId: player.id,
                          score: 0);

                      await creatScore(score);
                    }
                    // ignore: use_build_context_synchronously
                    Navigator.pop(context);
                  } catch (e) {
                    _showSnackBar(context,
                        'Error Parsing the Amount! Try adding decimals (100.0)');
                  }
                },
                child: const Text('Save Expense'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to save the expense and return the generated expense ID
  Future<int> createMatch(Match match) async {
    await databaseHelper.insertMatch(match);

    debugPrint(
        'Saving expense: ${match.id}'); // Replace with actual implementation

    return match.id;
  }

  // Function to save the debt
  Future<int> creatScore(Score score) async {
    await databaseHelper.insertScore(score);

    // Show a success message
    _showSnackBar(context, 'match created successfully');

    debugPrint(
        'Saving debt: ${score.id}'); // Replace with actual implementation
    return score.id;
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
