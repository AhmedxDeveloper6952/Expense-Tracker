import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInHandler {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<User?> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        final UserCredential authResult =
            await FirebaseAuth.instance.signInWithCredential(credential);

        return authResult.user;
      }
    } catch (error) {
      // You can handle errors here, such as showing a snackbar
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //   content: Text('Failed to sign in with Google.'),
      // ));
    }
    return null;
  }
}
