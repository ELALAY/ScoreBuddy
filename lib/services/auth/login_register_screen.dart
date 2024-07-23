import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scorebuddy/Components/my_button.dart';
import 'package:scorebuddy/Components/my_textfield.dart';
import 'package:scorebuddy/services/auth/register_screen.dart';

import 'auth_service.dart';

// ignore: camel_case_types
class loginOrRegister extends StatefulWidget {
  const loginOrRegister({super.key});

  @override
  State<loginOrRegister> createState() => loginOrRegisterState();
}

// ignore: camel_case_types
class loginOrRegisterState extends State<loginOrRegister> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void navRegister() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return const RegisterScreen();
    }));
  }

  void login() async {
  final authService = AuthService();
  if (emailController.text.trim().isNotEmpty &&
      passwordController.text.trim().isNotEmpty) {
    try {
      await authService.signInWithEmailAndPassword(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
      // Navigate to another screen or show success message
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found for that email.';
          break;
        case 'wrong-password':
          errorMessage = 'Wrong password provided.';
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
          title: const Text('Login Error'),
          content: Text(errorMessage),
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text('Login Error'),
          content: Text('Invalid Credentials'),
        ),
      );
    }
  } else {
    showDialog(
      context: context,
      builder: (context) => const AlertDialog(
        title: Text('Input Error'),
        content: Text('Both fields should be filled!'),
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.black,
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
              'Login to ScoreBuddy',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
            ),
            const SizedBox(
              height: 40,
            ),
            myTextField(
                controller: emailController,
                hintText: 'Email',
                obscureText: false),
            const SizedBox(
              height: 10,
            ),
            myTextField(
                controller: passwordController,
                hintText: 'Password',
                obscureText: true),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: login,
              child: const Text(
                'Login',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: navRegister,
              child: const Row(
                children: [
                  Text('Not a member?'),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    'Register Now!',
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
}
