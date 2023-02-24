import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:notes_app/home_screen.dart';

GoogleSignIn googleSignIn = GoogleSignIn();
final FirebaseAuth auth = FirebaseAuth.instance;
CollectionReference users = FirebaseFirestore.instance.collection('Users');

// changing return type to void
// as bool was not needed here
void signInWithGoogle(BuildContext context) async {
  try {
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken);

      final UserCredential authResult =
          await auth.signInWithCredential(credential);

      final User? user = authResult.user;

      var userData = {
        'Name': googleSignInAccount.displayName,
        'Provider': 'Google',
        'PhotoUrl': googleSignInAccount.photoUrl,
        'Email': googleSignInAccount.email,
      };

      users.doc(user?.uid).get().then((doc) {
        if (doc.exists) {
          // old user
          doc.reference.update(userData);

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => HomeScreen(),
            ),
          );
        } else {
          // new user

          users.doc(user?.uid).set(userData);

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => HomeScreen(),
            ),
          );
        }
      });
    }
  } catch (PlatformException) {
    print(PlatformException);
    print("Sign in not Successful!");
    // better show an alert here
  }
}
