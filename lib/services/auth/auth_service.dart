import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  //get instance of firebase
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  // get current user
  User? getCurrenctuser() {
    return firebaseAuth.currentUser;
  }

  //sign in
  Future<UserCredential> signInWithEmailAndPassword(
      String email, password) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // sign up
  Future<UserCredential> signUpWithEmailAndPassword(
      String email, password) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  //sing out

  Future<void> signout() async {
    return await firebaseAuth.signOut();
  }
}
