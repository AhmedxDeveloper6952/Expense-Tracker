import 'package:apnafin/database.dart';
import 'package:apnafin/expensepage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:random_string/random_string.dart';
import 'package:intl/intl.dart'; // Import the intl package for date formatting

class ExpenseItem {
  final String id;
  final String title;
  final String amount; // Change the data type to double
  final String category;
  final String type;
  final String option;
  final Timestamp? date;

  ExpenseItem(
    this.title,
    this.amount,
    this.category,
    this.type,
    this.option,
    this.date,
    this.id,
  );
}

class ExpInc extends StatefulWidget {
  const ExpInc({Key? key}) : super(key: key);

  @override
  State<ExpInc> createState() => _ExpIncState();
}

class _ExpIncState extends State<ExpInc> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedCategory = "Income";

  _ExpIncState() {
    selectedvalue = categories[0];
    titlecontroller.text = "";
    amountcontroller.text = "";
    selecteddate = DateTime.now();
  }

  final categories = [
    "Housing",
    "Transport",
    "Food",
    "Medical",
    "Insurance",
    "Rent",
    "Entertainment",
    "Utilities",
    "Education",
    "Shopping",
    "Travel",
    "Miscellaneous",
  ];

  String? selectedvalue = "";
  bool checkValue = false;
  TextEditingController amountcontroller = TextEditingController();
  TextEditingController titlecontroller = TextEditingController();
  DateTime selecteddate = DateTime.now();
  List<ExpenseItem> itemList = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Expense"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: TextField(
                controller: titlecontroller,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.title),
                  labelText: "Title",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: TextField(
                controller: amountcontroller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.money),
                  labelText: "Amount",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
            MaterialButton(
              onPressed: () async {
                final DateTime? dateTime = await showDatePicker(
                  context: context,
                  initialDate:
                      selecteddate, // Use selecteddate as the initial value
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2025),
                );
                if (dateTime != null) {
                  setState(() {
                    selecteddate = dateTime;
                  });
                }
              },
              child: Text(
                DateFormat.yMMMMd().format(selecteddate),
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 25),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.lightBlue,
              ),
              child: MaterialButton(
                onPressed: () {
                  _showBottomSheet(context);
                },
                child: const Text("Add"),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 25),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.lightBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          children: [
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Income'),
                Tab(text: 'Expense'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOptionsTab('Income'),
                  _buildOptionsTab('Expense'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOptionsTab(String category) {
    return ListView(
      children: categories.map((e) {
        return ListTile(
          title: Text(e),
          onTap: () {
            _addToFirestore(category, e, selecteddate);

            Navigator.pop(context); // Close the bottom sheet
          },
        );
      }).toList(),
    );
  }

  void _addToFirestore(String category, String option, DateTime selectedDate) {
    String id = randomAlphaNumeric(10);
    String type = _tabController.index == 0 ? 'Income' : 'Expense';

    double amount = double.tryParse(amountcontroller.text) ?? 0.0;

    Map<String, dynamic> employeeInfoMap = {
      "Title": titlecontroller.text,
      "Amount": amount,
      "Category": category,
      "Type": type,
      "Option": option,
      "Id": id,
      "Date": selectedDate, // Use the selected date here
    };

    DatabaseMethods().addEmployeeDetails(employeeInfoMap, id, category);
    Get.to(
      ExpensePage(
        itemList: itemList,
      ),
    );
  }

  // Other methods...
}
