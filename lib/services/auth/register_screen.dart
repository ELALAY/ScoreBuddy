import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../Screens/Home/home.dart';
import '../realtime_db/firebase_db.dart';
import 'auth_service.dart';
import 'login_register_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  FirebaseDatabaseHelper fbdatabaseHelper = FirebaseDatabaseHelper();
  final authService = AuthService();

  String errorMessage = '';

  User? user;
  Map<String, dynamic>? playerProfile;  

  void fetchUser() async {
    user = authService.getCurrenctuser();
    if (user != null) {
      playerProfile = await fbdatabaseHelper.getPlayerProfile(user!.uid);
    }
    setState(() {});
  }


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
          .doc(user!.uid)
          .set({
        'username': username,
        'email': user!.email,
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

  Future<void> register() async {
    if (passwordController.text != confirmPasswordController.text) {
      setState(() {
        errorMessage = 'Passwords do not match';
      });
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text(errorMessage),
              ));
      return;
    }
    if (!emailController.text.contains('@') ||
        !emailController.text.contains('.')) {
      setState(() {
        errorMessage = 'invalid email';
      });
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text(errorMessage),
              ));
      return;
    }

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      user = authService.getCurrenctuser();
      saveUsername();
      // ignore: use_build_context_synchronously
      /*Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => UsernameScreen(user: userCredential.user),
        ),
      );*/
      // Navigate to another screen or show success message
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'weak-password':
            errorMessage = 'The password provided is too weak.';
            break;
          case 'email-already-in-use':
            errorMessage = 'The account already exists for that email.';
            break;
          case 'invalid-email':
            errorMessage = 'The email address is not valid.';
            break;
          default:
            errorMessage = 'An error occurred. Please try again.';
        }
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text(errorMessage),
                ));
      });
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred. Please try again.';
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text(errorMessage),
                ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_open_rounded,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
            const Text(
              'Register to ScoreBuddy',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
            ),
            const SizedBox(
              height: 40,
            ),
            TextField(
              controller: usernameController,
              obscureText: false,
              decoration: InputDecoration(
                  label: const Text('Username'),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary),
                  )),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: emailController,
              obscureText: false,
              decoration: InputDecoration(
                  label: const Text('Email'),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary),
                  )),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                  label: const Text('Password'),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary),
                  )),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                  label: const Text('Confirm Password'),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary),
                  )),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: register,
              child: const Text(
                'Register',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: navLogin,
              child: const Row(
                children: [
                  Text('Already a member?'),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    'Login Now!',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void navLogin() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return const loginOrRegister();
    }));
  }
}
