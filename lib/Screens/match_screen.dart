import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Models/player_model.dart';
import '../Utils/database.dart';
import '../Models/match_model.dart';
import '../Models/score_model.dart';

class MatchScreen extends StatefulWidget {
  final Match match;
  const MatchScreen({super.key, required this.match});

  @override
  State<MatchScreen> createState() => MatchScreenState();
}

class MatchScreenState extends State<MatchScreen> {
  DatabaseHelper databaseHelper = DatabaseHelper.instance;
  TextEditingController gameNameController = TextEditingController();

  List<Score> scores = [];
  List<Player> players = [];
  Map<int, int> playersWonGames = {};

  @override
  void initState() {
    super.initState();
    fetchAllMatchScores();
  }

  void reload() {
    fetchAllMatchScores();
  }

  void fetchAllMatchScores() async {
    List<Score> scoresList =
        await databaseHelper.getMatchScores(widget.match.id);
    List<Player> playersList =
        await databaseHelper.getMatchPlayers(widget.match.id);
    setState(() {
      scores = scoresList;
      players = playersList;
    });
  }

  void saveScores() async {
    for (Score score in scores) {
      await databaseHelper.updateScore(score);
    }
    reload();
  
    // ignore: use_build_context_synchronously
    _showSnackBar(context, 'Scores saved successfully!');
  }

  void resetScroes() async {
    // Save all scores to the database
    for (Score score in scores) {
      score.score = 0;
      await databaseHelper.updateScore(score);
    }
    reload();
    // ignore: use_build_context_synchronously
    _showSnackBar(context, 'Scores reset successfully!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Match: ${widget.match.name}'),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
        actions: [
          IconButton(
              onPressed: () {
                reload();
              },
              icon: const Icon(Icons.refresh)),
          IconButton(
              onPressed: () {
                resetScroes();
                reload();
              },
              icon: const Icon(Icons.reset_tv_sharp)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Score table
            DataTable(
              showBottomBorder: true,
              headingRowColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                if (states.contains(MaterialState.hovered)) {
                  return Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity(0.08);
                }
                return null; // Use the default value.
              }),
              headingTextStyle:
                  TextStyle(color: Theme.of(context).colorScheme.primary),
              columns: const [
                DataColumn(
                  label: Text(
                    'Player',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Score',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Games Won',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              rows: List<DataRow>.generate(
                players.length,
                (index) => DataRow(
                  cells: [
                    DataCell(Text(players[index].name)),
                    DataCell(Text('${scores[index].score}')),
                    DataCell(Text('${scores[index].won}')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Display total score
            const Text(
              'Players',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Input area for adding scores
            Expanded(
              child: ListView.builder(
                itemCount: players.length,
                itemBuilder: (context, index) {
                  String player = players[index].name;
                  Score score = scores[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 75.0,
                          child: Text('$player:',
                              style: const TextStyle(fontSize: 18)),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: SizedBox(
                            width: 200.0,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                                labelText: 'Add Score',
                                labelStyle: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                ),
                              ),
                              onSubmitted: (value) {
                                setState(() {
                                  int scoreValue = int.tryParse(value) ?? 0;
                                  score.score += scoreValue;
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 50,
                          child: IconButton(
                              onPressed: () {
                                score.score += 51;
                                saveScores();
                                fetchAllMatchScores();
                                reload();
                              },
                              icon: const Icon(
                                CupertinoIcons.add_circled_solid,
                                color: Colors.white,
                              )),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
            Center(
              child: ElevatedButton(
                child: const Text('Save Scores'),
                onPressed: () {
                  saveScores();
                  reload();
                },
              ),
            ),
            const SizedBox(
              height: 200.0,
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
