import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Models/player_model.dart';
import '../Models/room_model.dart';
import '../services/sqflite/database.dart';

class RoomScreen extends StatefulWidget {
  final Room room;
  const RoomScreen({super.key, required this.room});

  @override
  State<RoomScreen> createState() => RoomScreenState();
}

class RoomScreenState extends State<RoomScreen> {
  DatabaseHelper databaseHelper = DatabaseHelper.instance;
  TextEditingController gameNameController = TextEditingController();

  List<Player> players = [];
  Map<int, int> playersWonGames = {};

  @override
  void initState() {
    super.initState();
    fetchAllRoomScores();
  }

  void reload() {
    fetchAllRoomScores();
  }

  void fetchAllRoomScores() async {
    
  }

  void saveScores() async {
    
  }

  void resetScores() async {
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Room: ${widget.room.roomName}'),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
        actions: [
          IconButton(
            onPressed: () {
              reload();
            },
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () {
              resetScores();
              reload();
            },
            icon: const Icon(Icons.reset_tv_sharp),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
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
                    return null;
                  },
                ),
                headingTextStyle: TextStyle(
                    color: Theme.of(context).colorScheme.primary),
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
                      'Wins',
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
                      //DataCell(Text('${scores[index].score}')),
                      //DataCell(Text('${scores[index].won}')),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Players || Target:(${widget.room.targetScore})',
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                itemCount: players.length,
                itemBuilder: (context, index) {
                  String player = players[index].name;
                  
                  TextEditingController scoreController =
                      TextEditingController();
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
                              controller: scoreController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                                labelText: 'Add Score',
                                labelStyle: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary),
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
                                  
                                });
                                scoreController.clear();
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 50,
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                //score.score += 51;
                              });
                              scoreController.clear();
                              saveScores();
                              fetchAllRoomScores();
                              reload();
                            },
                            icon: const Icon(
                              CupertinoIcons.add_circled_solid,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
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
      ),
    );
  }

  // ignore: unused_element
  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
