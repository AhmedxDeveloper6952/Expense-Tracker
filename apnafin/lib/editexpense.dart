import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:apnafin/database.dart';
import 'package:apnafin/expincdetail.dart';

class UpdateExpenseScreen extends StatefulWidget {
  final ExpenseItem expenseItem;

  const UpdateExpenseScreen({Key? key, required this.expenseItem})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _UpdateExpenseScreenState createState() => _UpdateExpenseScreenState();
}

class _UpdateExpenseScreenState extends State<UpdateExpenseScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  int segmentedControlGroupValue = 0; // 0 for Expense, 1 for Income

  @override
  void initState() {
    super.initState();
    titleController.text = widget.expenseItem.title;
    amountController.text = widget.expenseItem.amount.toString();
    selectedDate = widget.expenseItem.date!.toDate();
    segmentedControlGroupValue = widget.expenseItem.type == 'Expense' ? 0 : 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Transaction"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Transaction Type",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            CupertinoSegmentedControl<int>(
              children: const {
                0: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                  child: Text('Expense', style: TextStyle(fontSize: 18)),
                ),
                1: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                  child: Text('Income', style: TextStyle(fontSize: 18)),
                ),
              },
              groupValue: segmentedControlGroupValue,
              onValueChanged: (int value) {
                setState(() {
                  segmentedControlGroupValue = value;
                });
              },
              borderColor: Colors.transparent,
              selectedColor:
                  segmentedControlGroupValue == 1 ? Colors.green : Colors.red,
              unselectedColor: Colors.grey[300],
              pressedColor: segmentedControlGroupValue == 1
                  ? Colors.green[200]
                  : Colors.red[200],
            ),
            const SizedBox(height: 30),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.title),
                labelText: "Title",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.money),
                labelText: "Amount",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            const SizedBox(height: 14),
            MaterialButton(
              color: Theme.of(context).primaryColor,
              onPressed: () async {
                final DateTime? dateTime = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2025),
                );
                if (dateTime != null) {
                  setState(() {
                    selectedDate = dateTime;
                  });
                }
              },
              child: Text(
                "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}",
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: MaterialButton(
                color: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 15),
                onPressed: _updateExpense,
                child: const Text("Update",
                    style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateExpense() {
    String id = widget.expenseItem.id;
    String category = widget.expenseItem.category;
    String option = widget.expenseItem.option;
    String type = segmentedControlGroupValue == 0 ? 'Expense' : 'Income';

    Map<String, dynamic> updatedInfo = {
      "Title": titleController.text,
      "Amount": amountController.text,
      "Category": category,
      "Type": type,
      "Option": option,
      "Date": FieldValue.serverTimestamp(),
    };

    DatabaseMethods().updateEmployeeDetails(id, updatedInfo);

    Navigator.pop(context);
  }
}
