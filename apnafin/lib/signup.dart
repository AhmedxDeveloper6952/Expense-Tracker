import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:apnafin/loginpage.dart';
import 'package:apnafin/googlesignin.dart';
import 'package:apnafin/database.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GoogleSignInHandler _googleSignInHandler = GoogleSignInHandler();
  final DatabaseMethods databaseMethods = DatabaseMethods();

  Future<void> signUp(String email, String password) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      )
          .then((userCredential) async {
        String uid = userCredential.user!.uid;

        // Use the UID as the document ID in Firestore
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'email': email,
          // Add more fields as needed
        });

        Get.to(() => const LoginPage());
      });
    } on FirebaseAuthException catch (ex) {
      String errorMessage = "An error occurred";
      if (ex.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (ex.code == 'email-already-in-use') {
        errorMessage = 'The account already exists for that email.';
      } else if (ex.code == 'invalid-email') {
        errorMessage = 'Invalid email address.';
      }

      showDialog(
        context: Get.context!,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error"),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _signUpWithGoogle(BuildContext context) async {
    User? user = await _googleSignInHandler.signInWithGoogle(context);
    if (user != null) {
      Get.to(() => const LoginPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Sign Up",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email_outlined),
                    hintText: "Enter your Email",
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  controller: passwordController,
                  obscureText: true, // Password is hidden
                  decoration: const InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                    hintText: 'Password',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 25),
                child: ElevatedButton(
                  onPressed: () {
                    signUp(
                      usernameController.text.trim(),
                      passwordController.text.trim(),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _signUpWithGoogle(context);
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/google.png', // Replace with your Google logo image path
                      height: 24.0,
                    ),
                    const SizedBox(width: 12.0),
                    const Text(
                      'Sign up with Google',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                  );
                },
                child: const Text(
                  "Already have an account? Log in",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
