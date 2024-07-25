import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scorebuddy/Screens/new_friend_screen.dart';

import '../../Models/player_model.dart';
import '../../services/auth/auth_service.dart';
import '../../services/realtime_db/firebase_db.dart';

class MyHomeDrawer extends StatefulWidget {
  const MyHomeDrawer({super.key});

  @override
  State<MyHomeDrawer> createState() => _MyHomeDrawerState();
}

class _MyHomeDrawerState extends State<MyHomeDrawer> {
  FirebaseDatabaseHelper fbdatabaseHelper = FirebaseDatabaseHelper();
  final authService = AuthService();
  User? user;
  Map<String, dynamic>? playerProfile;

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  void navFriendsScreen() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return const AddFriendScreen();
    }));
  }

  void fetchUser() async {
    user = authService.getCurrenctuser();
    if (user != null) {
      playerProfile = await fbdatabaseHelper.getPlayerProfile(user!.uid);
    }
    setState(() {});
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
    return Drawer(
      child: Column(
        children: <Widget>[
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            accountName: Text(
              '${playerProfile?['username'] ?? 'No username'} ',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            accountEmail: Text(
              '${playerProfile?['email'] ?? 'No email'}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                '${playerProfile?['username'][0] ?? 'No username'} ', // User's initials
                style: TextStyle(
                  fontSize: 40.0,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text('Friends'),
            onTap: navFriendsScreen,
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              logout();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
