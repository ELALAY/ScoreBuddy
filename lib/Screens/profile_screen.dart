import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scorebuddy/Screens/Home/home.dart';

class UsernameScreen extends StatefulWidget {
  final User? user;

  const UsernameScreen({Key? key, this.user}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _UsernameScreenState createState() => _UsernameScreenState();
}

class _UsernameScreenState extends State<UsernameScreen> {
  TextEditingController usernameController = TextEditingController();
  String errorMessage = '';

  Future<void> saveUsername() async {
    String username = usernameController.text.trim();
    if (username.isEmpty) {
      setState(() {
        errorMessage = 'Username cannot be empty';
      });
      return;
    }

    // Check if the username is already taken
    bool usernameExists = await checkUsernameAvailability(username);

    if (usernameExists) {
      setState(() {
        errorMessage = 'Username is already taken';
      });
    } else {
      // Save the username to Firestore
      await FirebaseFirestore.instance
          .collection('players')
          .doc(widget.user!.uid)
          .set({
        'username': username,
        'email': widget.user!.email,
      });

      // Navigate to the home page
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const MyHomePage(), // Replace with your home page
        ),
      );
    }
  }

  Future<bool> checkUsernameAvailability(String username) async {
    final result = await FirebaseFirestore.instance
        .collection('players')
        .where('username', isEqualTo: username)
        .get();

    return result.docs.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Username'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                errorText: errorMessage.isEmpty ? null : errorMessage,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveUsername,
              child: const Text('Save Username'),
            ),
          ],
        ),
      ),
    );
  }
}
