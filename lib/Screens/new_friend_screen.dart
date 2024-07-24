import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth/auth_service.dart';
import '../services/realtime_db/firebase_db.dart'; // Make sure to import your friend service

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({super.key});

  @override
  AddFriendScreenState createState() => AddFriendScreenState();
}

class AddFriendScreenState extends State<AddFriendScreen> {
  final TextEditingController friendIdController = TextEditingController();
  FirebaseDatabaseHelper firebaseDatabaseHelper = FirebaseDatabaseHelper();
  final authService = AuthService();
  final String currentName = ''; // Replace with actual current user ID
  User? user;
  
  void fetchUser() async {
    user = authService.getCurrenctuser();
    setState(() {});
  }

  void addFriend() async {
    String friendName = friendIdController.text.trim();
    if (friendName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a friend UserName')),
      );
      return;
    }

    try {
      await firebaseDatabaseHelper.addFriend('Aymane', friendName);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Friend added successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding friend: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: friendIdController,
              decoration: const InputDecoration(
                labelText: 'Friend ID',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: addFriend,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: const Text('Add Friend'),
            ),
          ],
        ),
      ),
    );
  }
}
