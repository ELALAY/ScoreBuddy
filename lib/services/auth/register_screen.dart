import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scorebuddy/services/auth/auth_service.dart';

import '../../Components/my_textfield.dart';
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

  String errorMessage = '';

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
              height: 10,
            ),
            myTextField(
                controller: confirmPasswordController,
                hintText: 'Confirm Password',
                obscureText: true),
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
