import 'package:flutter/material.dart';
import '../Models/match_model.dart';

class MatchScreen extends StatefulWidget {
  final Match match;
  const MatchScreen({super.key, required this.match});

  @override
  State<MatchScreen> createState() => MatchScreenState();
}

class MatchScreenState extends State<MatchScreen> {
  TextEditingController gameNameController = TextEditingController();
  List<int> scores = [100, 51]; // Example scores for players
  List<int> gamesWon = [5, 3]; // Example games won by players
  List<String> players = ['Aymane', 'Sara']; // Example player names

  // Method to calculate the total score
  int getTotalScore() {
    return scores.reduce((a, b) => a + b);
  }

  @override
  void initState() {
    super.initState();
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
              headingTextStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
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
                    DataCell(Text(players[index])),
                    DataCell(Text('${scores[index]}')),
                    DataCell(Text('${gamesWon[index]}')),
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
                itemCount: scores.length,
                itemBuilder: (context, index) {
                  String player = players[index];
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
                                    color: Theme.of(context).colorScheme.primary),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color:
                                          Theme.of(context).colorScheme.primary),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color:
                                          Theme.of(context).colorScheme.primary),
                                ),
                              ),
                              onSubmitted: (value) {
                                setState(() {
                                  scores[index] += int.tryParse(value) ?? 0;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
