import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:scorebuddy/Models/room_model.dart';
import 'package:scorebuddy/Screens/match_screen.dart';
import 'package:scorebuddy/services/realtime_db/firebase_db.dart';
import '../../services/auth/auth_service.dart';
import '../new_game_screem.dart';
import '../new_match_screen.dart';
import 'home_drawer.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  FirebaseDatabaseHelper fbdatabaseHelper = FirebaseDatabaseHelper();
  final authService = AuthService();

  List allMatches = [];
  Map<int, int> allMatchplayersNumber = {};
  User? user;

  @override
  void initState() {
    super.initState();
    fetchAllRooms();
  }

  void fetchAllRooms() async {
    try {
      List<Room> matches = await fbdatabaseHelper.getAllRooms();
      debugPrint('${matches.length}');
      setState(() {
        allMatches = matches;
      });
    } catch (e) {
      debugPrint("Error fetching matches: $e");
      _showSnackbar(context, 'Failed to fetch matches');
    }
  }

  void deleteRoom(Room room) async {
    try {
      await fbdatabaseHelper.deleteRoom(room.roomName);
      setState(() {
        allMatches.remove(room);
      });
      // ignore: use_build_context_synchronously
      _showSnackbar(context, 'Room deleted successfully');
    } catch (e) {
      debugPrint("Error deleting room: $e");
      _showSnackbar(context, 'Failed to delete room');
    }
  }

  void logout() async {
    try {
      await authService.signout();
    } catch (e) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text(e.toString()),
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Games Score'),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh),
              color: Colors.white,
              onPressed: () {
                fetchAllRooms();
              }),
          IconButton(
              icon: const Icon(Icons.logout_outlined),
              color: Colors.white,
              onPressed: logout),
        ],
      ),
      drawer: const MyHomeDrawer(),
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
                  Room room = allMatches[index];
                  return Slidable(
                    key: ValueKey(room.roomName),
                    endActionPane: ActionPane(
                      motion: const StretchMotion(),
                      dismissible: DismissiblePane(
                        onDismissed: () {
                          _showSnackbar(context, 'Deleted ${room.roomName}');
                          deleteRoom(room);
                        },
                      ),
                      children: [
                        SlidableAction(
                          onPressed: (context) {
                            _showSnackbar(context, 'Deleted ${room.roomName}');
                            deleteRoom(room);
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
                                    room.roomName,
                                    style: const TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          navMatchScreen(room);
                        },
                      ),
                    ),
                  );
                },
              ),
            )
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

  void navMatchScreen(Room room) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return RoomScreen(room: room);
    }));
  }

  void createNewGameScreen() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return const NewGame();
    }));
  }

  void createNewMatchScreen() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return const NewMatch();
    })).then(
        (_) => fetchAllRooms()); // Refresh the list after creating a new match
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
