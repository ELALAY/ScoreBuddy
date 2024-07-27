import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../Models/player_model.dart';
import '../../Models/room_model.dart';
import '../../Models/score_model.dart';
import '../../services/realtime_db/firebase_db.dart';
import '../QrCodeMger/generate_qr_code.dart';

class RoomScreen extends StatefulWidget {
  final Room room;
  const RoomScreen({super.key, required this.room});

  @override
  State<RoomScreen> createState() => RoomScreenState();
}

class RoomScreenState extends State<RoomScreen>
    with SingleTickerProviderStateMixin {
  FirebaseFirestore fbdatabaseHelper = FirebaseFirestore.instance;
  FirebaseDatabaseHelper firebaseDatabaseHelper = FirebaseDatabaseHelper();
  TextEditingController gameNameController = TextEditingController();
  TextEditingController friendController = TextEditingController();
  late TabController _roomTabController;
  List<Player> players = [];
  List<PlayerScore> scores = [];
  Map<int, int> playersWonGames = {};

  List<Player> friends = [];
  List<Player> selectedFriends = [];

  @override
  void initState() {
    super.initState();
    fetchUserFriends();
    fetchAllRoomScores();
    _roomTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _roomTabController.dispose();
    super.dispose();
  }

  void reload() {
    fetchUserFriends();
    fetchAllRoomScores();
  }

  Future<void> fetchUserFriends() async {
    try {
      List<Player> friendList = await firebaseDatabaseHelper.getAllPlayers();
      setState(() {
        friends = friendList;
      });
    } catch (e) {
      debugPrint('Error fetching friends: $e');
    }
  }

  Future<void> inviteFriends() async {
    _showSnackBar(context, 'invite friends');
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Player'),
              content: TextField(
                controller: friendController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  labelText: 'Username',
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
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Add'),
                  onPressed: () async {
                    if (friendController.text.isNotEmpty) {
                      PlayerScore playerScore = PlayerScore(
                          gameName: widget.room.gameName,
                          roomName: widget.room.roomName,
                          playerName: friendController.text,
                          score: 0);
                      bool exists = await firebaseDatabaseHelper
                          .checkPlayerinRoom(playerScore);

                      if (exists) {
                        bool inserted = await firebaseDatabaseHelper
                            .insertPlayerScore(playerScore);
                        if (inserted) {
                          // ignore: use_build_context_synchronously
                          _showSnackBar(context, "user Doesn't exists");
                        } else {
                          // ignore: use_build_context_synchronously
                          _showSnackBar(context, "user Doesn't exists");
                        }
                      } else {
                        // ignore: use_build_context_synchronously
                        _showSnackBar(context, "user Doesn't exists");
                      }
                      friendController.clear();
                    } else {
                      _showSnackBar(context, 'invalid input');
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void fetchAllRoomScores() async {
    try {
      QuerySnapshot playerScoresQuerySnapshot = await fbdatabaseHelper
          .collection('playerScores')
          .where('roomName', isEqualTo: widget.room.roomName)
          .get();

      if (playerScoresQuerySnapshot.docs.isNotEmpty) {
        List<PlayerScore> allScores = playerScoresQuerySnapshot.docs
            .map((doc) => PlayerScore.fromFirestore(doc))
            .toList();

        setState(() {
          scores = allScores;
          debugPrint('Scores fetched successfully: ${allScores.length}');
          for (PlayerScore score in allScores) {
            debugPrint(score.playerName);
          }
        });
      } else {
        setState(() {
          scores = [];
          debugPrint('No scores found for room: ${widget.room.roomName}');
        });
      }
    } catch (e) {
      debugPrint('Error fetching player scores: $e');
    }
  }

  void updateScore(PlayerScore score, int newScore) async {
    try {
      await firebaseDatabaseHelper.updatePlayerScore(
          widget.room.roomName, score.playerName, newScore);
      debugPrint('updated score of ${score.playerName}');
    } catch (e) {
      _showSnackBar(context, 'Failed to create game: $e');
    }
  }

  void resetScores() async {
    for (PlayerScore score in scores) {
      updateScore(score, 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Room: ${widget.room.gameName}'),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
        bottom: TabBar(
          controller: _roomTabController,
          tabs: [
            Tab(text: widget.room.roomName),
            const Tab(text: 'Join Room'),
          ],
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
        child: TabBarView(controller: _roomTabController, children: [
          SingleChildScrollView(
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
                  ],
                  rows: List<DataRow>.generate(
                    scores.length,
                    (index) => DataRow(
                      cells: [
                        DataCell(Text(scores[index].playerName)),
                        DataCell(Text(scores[index].score.toString())),
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
                  itemCount: scores.length,
                  itemBuilder: (context, index) {
                    PlayerScore score = scores[index];
                    String player = scores[index].playerName;
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
                                    updateScore(
                                        score,
                                        score.score +
                                            int.parse(scoreController.text));
                                    score.score +=
                                        int.parse(scoreController.text);
                                    scoreController.clear();
                                  });
                                },
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 50,
                            child: IconButton(
                              onPressed: () {
                                showDialog(context: context, builder: (context){
                                  return AlertDialog(
                                    title: Text(
                                      'Remove ${score.playerName}'
                                    ),
                                    actions: [
                                      ElevatedButton(onPressed: (){
                                        firebaseDatabaseHelper.removePlayerFromRoom(score.roomName, score.playerName);
                                      }, child: const Text('Remove'))
                                    ],
                                  );
                                });
                              },
                              icon: const Icon(
                                CupertinoIcons.minus_circle,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          /*SizedBox(
                            width: 50,
                            child: IconButton(
                              onPressed: () {
                                setState(() {});
                                updateScore(score, score.score + 51);
                                reload();
                              },
                              icon: const Icon(
                                CupertinoIcons.add_circled_solid,
                                color: Colors.white,
                              ),
                            ),
                          ),*/
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(
                  height: 200.0,
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(
                    height: 20.0,
                  ),
                  Text('Room Name: ${widget.room.roomName}'),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(color: Colors.grey.shade700),
                      height: 300,
                      width: 300,
                      child: GenerateQRCodeScreen(
                          dataToEncode: widget.room.roomName),
                    ),
                  ),
                  const SizedBox(
                    height: 100.0,
                  ),
                  ElevatedButton(
                      onPressed: inviteFriends,
                      child: const Text('Invite Friends!')),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  // ignore: unused_element
  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
