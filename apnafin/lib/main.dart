import 'package:apnafin/homepage.dart';
import 'package:apnafin/loginpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAGlvqPbLusz1xg3vm1Kz8dRss406o7mu0",
      appId: "1:452971235242:android:81e45f8dc16d634e598dd3",
      messagingSenderId: "452971235242",
      projectId: "easyfina-a064a",
    ),
  );

  var auth = FirebaseAuth.instance;
  var user = auth.currentUser;
  String? uid;

  if (user != null) {
    uid = user.uid;
  }

  runApp(MyApp(uid: uid));
}

class MyApp extends StatefulWidget {
  final String? uid;

  const MyApp({Key? key, this.uid}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var auth = FirebaseAuth.instance;
  var isLogin = false;

  checkIfLogin() async {
    auth.authStateChanges().listen((User? user) {
      if (user != null && mounted) {
        setState(() {
          isLogin = true;
        });
      } else {
        setState(() {
          isLogin = false;
        });
      }
    });
  }

  @override
  void initState() {
    checkIfLogin();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 95, 55, 165),
        ),
        useMaterial3: true,
      ),
      home: isLogin ? HomePage(uid: widget.uid) : const LoginPage(),
    );
  }
}
