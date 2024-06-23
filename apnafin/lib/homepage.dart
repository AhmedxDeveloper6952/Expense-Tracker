import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:apnafin/loginpage.dart';
import 'package:apnafin/expensepage.dart';
import 'package:apnafin/expincdetail.dart';
import 'package:apnafin/chartpage.dart';
import 'package:share/share.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  final String? uid;
  const HomePage({Key? key, this.uid}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String appVersion = "1.0.0"; // Replace with your app's current version

  final List<Widget> _pages = [
    const ExpensePage(
      itemList: [],
    ),
    const ChartPage(),
  ];

  Future<String?> _getUserEmail() async {
    final User? user = FirebaseAuth.instance.currentUser;
    return user?.email;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Get.to(() => const LoginPage());
  }

  void _shareApp() {
    Share.share("Check out this amazing expense tracker app!");
  }

  void _checkForUpdate() {
    // Replace this logic with your version checking mechanism
    String latestVersion =
        "1.0.1"; // Replace with the latest version of your app

    if (latestVersion == appVersion) {
      // The app is up-to-date
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            //  title: const Text("Check for Update"),
            content: const Text("You have the latest version."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    } else {
      // There is a new version available
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Check for Update"),
            content: const Text("The app is updated to the latest version."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Add logic to redirect users to the app store for the update
                },
                child: const Text("Update Now"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Later"),
              ),
            ],
          );
        },
      );
    }
  }

  void _rateApp() async {
    const url =
        'https://play.google.com/store/apps/details?id=<YOUR_APP_PACKAGE_NAME>';
    // ignore: deprecated_member_use
    if (await canLaunch(url)) {
      // ignore: deprecated_member_use
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _showAboutUsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("About Us"),
          content: const Text(
            "This app is developed to help you track your expenses and manage your finances more effectively. Version 1.0.0",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text('Expense Tracker'),
        ),
        backgroundColor: const Color.fromARGB(255, 164, 222, 222),
        elevation: 5,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.teal,
              ),
              child: FutureBuilder(
                future: _getUserEmail(),
                builder: (context, AsyncSnapshot<String?> snapshot) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 30,
                        child: Text(
                          "AM",
                          style: TextStyle(fontSize: 20.0),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        snapshot.data ?? "No Email",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  );
                },
              ),
            ),
            ListTile(
              title: const Text(
                "Sign out",
                style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.red),
              ),
              leading: const Icon(
                Icons.exit_to_app,
                size: 24.0,
                color: Colors.red,
              ),
              onTap: _signOut,
            ),
            ListTile(
              title: const Text(
                "About us",
                style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal),
              ),
              leading: const Icon(
                Icons.info,
                size: 24.0,
                color: Colors.teal,
              ),
              onTap: _showAboutUsDialog,
            ),
            ListTile(
              title: const Text(
                "Share App",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              leading: const Icon(
                Icons.share,
                size: 24.0,
                color: Colors.blue,
              ),
              onTap: _shareApp,
            ),
            ListTile(
              title: const Text(
                "Check for Update",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              leading: const Icon(
                Icons.system_update,
                size: 24.0,
                color: Colors.orange,
              ),
              onTap: _checkForUpdate,
            ),
            ListTile(
              title: const Text(
                "Rate App",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              leading: const Icon(
                Icons.star,
                size: 24.0,
                color: Colors.orange,
              ),
              onTap: _rateApp,
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(.1))
        ]),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              tabs: const [
                GButton(
                  icon: Icons.money,
                  text: 'Expense',
                  textStyle: TextStyle(fontSize: 16, color: Colors.teal),
                ),
                GButton(
                  icon: Icons.graphic_eq,
                  text: 'Chart',
                  textStyle: TextStyle(fontSize: 16, color: Colors.teal),
                ),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: _onItemTapped,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        shape: const CircleBorder(eccentricity: 1),
        child: const Icon(Icons.add),
        onPressed: () {
          Get.to(() => const ExpInc());
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
