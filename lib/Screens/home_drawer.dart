import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth/auth_service.dart';
import '../services/realtime_db/firebase_db.dart';

class MyHomeDrawer extends StatefulWidget {
  const MyHomeDrawer({super.key});

  @override
  State<MyHomeDrawer> createState() => _MyHomeDrawerState();
}

class _MyHomeDrawerState extends State<MyHomeDrawer> {
  
  FirebaseDatabaseHelper fbdatabaseHelper = FirebaseDatabaseHelper();
  final authService = AuthService();
  User? user;
  @override
  void initState() {
    super.initState();
    fetchUser();
  }


  void fetchUser() async {
    user = authService.getCurrenctuser();
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
                user?.displayName ?? 'User Name',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              accountEmail: Text(
                user?.email ?? 'User Email',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  user?.displayName?.substring(0, 1) ?? 'U', // User's initials
                  style: TextStyle(
                    fontSize: 40.0,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Add Friends'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Flush Sqflite DB'),
              onTap: () {
                // Handle Sqflite DB flush here
                Navigator.pop(context);
              },
            ),
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