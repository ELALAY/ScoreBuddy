import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:scorebuddy/Models/match_model.dart';
import 'package:scorebuddy/Models/game_model.dart';
import '../Models/player_model.dart';
import '../Utils/database.dart';
import 'match_screen.dart';
import 'new_game_screem.dart';
import 'new_match_screen.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  DatabaseHelper databaseHelper = DatabaseHelper.instance;
  List<Game> games = [];
  List<Player> players = [];

  List<Match> allMatches = [];
  Map<int, int> allMatchplayersNumber = {};

  @override
  void initState() {
    super.initState();
    fetchAllGames();
    fetchAllmatches();
  }

  void reload() {
    fetchAllGames();
  }

  void fetchAllmatches() async {
    //get all matches
    List<Match> matches = await databaseHelper.getAllMatches();
    //get all matches count players
    Map<int, int> matchPlayerCounts =
        await databaseHelper.getMatchePlayerCounts();

    setState(() {
      allMatches = matches;
      allMatchplayersNumber = matchPlayerCounts;
    });
  }

  void fetchAllGames() async {
    List<Game> allgames = await databaseHelper.getAllGames();
    setState(() {
      games = allgames;
    });
  }

  void createNewGameScreen() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return const NewGame();
    }));
  }

  void createNewMatchScreen() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return const NewMatch();
    }));
  }

  void deleteGame(Game game) async {
    await databaseHelper.deleteGameById(game.id);
  }

  void deleteMatch(Match match) async {
    await databaseHelper.deleteMatchById(match.id);
  }

  _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void navMatchScreen(Match matchNav) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return MatchScreen(match: matchNav);
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Games Score'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  alignment: Alignment.topLeft,
                  child: const Text(
                    'Matches:',
                    style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    createNewGameScreen();
                  },
                  icon: const Icon(Icons.add),
                  color: Colors.white,
                )
              ],
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 1.2,
                ),
                itemCount: allMatches.length,
                itemBuilder: (BuildContext context, int index) {
                  Match match = allMatches[index];
                  int matchCount = allMatchplayersNumber[match.id] ?? 0;
                  return Slidable(
                    key: const ValueKey(0),
                    // The start action pane is the one at the left or the top side.
                    endActionPane: ActionPane(
                      // A motion is a widget used to control how the pane animates.
                      motion: const StretchMotion(),
                      // A pane can dismiss the Slidable.
                      dismissible: DismissiblePane(onDismissed: () {}),
                      // All actions are defined in the children parameter.
                      children: [
                        // A SlidableAction can have an icon and/or a label.
                        SlidableAction(
                          onPressed: (context) {
                            _showSnackbar(context, 'deleted ${match.name}');
                            deleteMatch(match);
                            reload();
                          },
                          borderRadius: BorderRadius.circular(12),
                          backgroundColor:
                              Theme.of(context).colorScheme.tertiary,
                          foregroundColor: Colors.white,
                          icon: Icons.delete_forever,
                          label: 'Delete',
                        ),
                      ],
                    ),
                    child: Card(
                      color: Theme.of(context).colorScheme.primary,
                      elevation: 2.0,
                      child: InkWell(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    match.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      //createNewMatchScreen();
                                      reload();
                                    },
                                    icon: const Icon(Icons.add),
                                    color: Colors.black,
                                  )
                                ],
                              ),
                              const SizedBox(height: 4.0),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.people,
                                    color: Colors.black,
                                    size: 14,
                                  ),
                                  Text(
                                    ' $matchCount',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              //const Spacer(),
                            ],
                          ),
                        ),
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return MatchScreen(match: match);
                          }));
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            createNewMatchScreen();
          },
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(Icons.add)),
    );
  }
}
