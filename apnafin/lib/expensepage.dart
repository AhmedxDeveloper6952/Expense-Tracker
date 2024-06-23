import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'database.dart';
import 'editexpense.dart';
import 'seeall.dart';
import 'expincdetail.dart';

class ExpensePage extends StatefulWidget {
  const ExpensePage({
    Key? key,
    required List itemList,
  }) : super(key: key);

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  late List<ExpenseItem> _itemList;
  late Map<String, List<ExpenseItem>> _groupedExpenses;
  late final List<ExpenseItem> _filteredExpenses = [];

  @override
  void initState() {
    super.initState();
    _itemList = [];
    _groupedExpenses = {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: DatabaseMethods().getEmployeeDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            _itemList.clear();
            _groupedExpenses.clear();
            _filteredExpenses.clear();

            for (var doc in snapshot.data!.docs) {
              ExpenseItem item = ExpenseItem(
                doc["Title"],
                doc["Amount"].toString(),
                doc["Category"],
                doc["Type"],
                doc["Option"],
                doc["Date"],
                doc["Id"],
              );

              _itemList.add(item);

              String formattedDate = item.date != null
                  ? DateFormat('yyyy-MM-dd').format(item.date!.toDate())
                  : '';

              _groupedExpenses.putIfAbsent(formattedDate, () => []).add(item);
            }

            _filteredExpenses.addAll(_itemList);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TransactionOverview(
                    balance: _calculateBalance(),
                    totalIncome: _calculateTotalAmount('Income'),
                    totalExpense: _calculateTotalAmount('Expense'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 18.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Transaction",
                        style: TextStyle(fontSize: 17),
                      ),
                      MaterialButton(
                        onPressed: () {
                          Get.to(SeeAll(itemList: _itemList));
                        },
                        child: const Text("See all"),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _groupedExpenses.length,
                    itemBuilder: (context, index) {
                      String date = _groupedExpenses.keys.elementAt(index);
                      List<ExpenseItem> expenses = _groupedExpenses[date] ?? [];
                      return _buildDateList(date, expenses);
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildDateList(String date, List<ExpenseItem> expenses) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date: $date',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Column(
              children: expenses.map((expense) {
                return _buildExpenseItem(expense);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseItem(ExpenseItem item) {
    IconData itemIcon =
        item.type == 'Income' ? Icons.arrow_downward : Icons.arrow_upward;
    Color iconColor = item.type == 'Income' ? Colors.green : Colors.red;

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Confirm Deletion"),
              content: const Text("Are you sure you want to delete this item?"),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("CANCEL"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("DELETE"),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        _deleteFromFirestore(item.title);
      },
      child: ListTile(
        onTap: () {
          _navigateToUpdateScreen(item);
        },
        leading: Icon(itemIcon, color: iconColor),
        title: Text(
          item.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(item.option),
        trailing: Text(
          '${item.type == 'Income' ? '+ ' : '- '}${item.amount}',
          style: TextStyle(
              color: item.type == 'Income' ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 16),
        ),
      ),
    );
  }

  double _calculateTotalAmount(String type) {
    return _itemList
        .where((item) => item.type == type)
        .map((item) => double.parse(item.amount))
        .fold(0, (prev, amount) => prev + amount);
  }

  double _calculateBalance() {
    double totalIncome = _calculateTotalAmount('Income');
    double totalExpense = _calculateTotalAmount('Expense');
    return totalIncome - totalExpense;
  }

  void _navigateToUpdateScreen(ExpenseItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateExpenseScreen(expenseItem: item),
      ),
    );
  }

  void _deleteFromFirestore(String title) {
    DatabaseMethods().deleteEmployeeDetails(
      title,
    );
  }
}

class TransactionOverview extends StatefulWidget {
  final double balance;
  final double totalIncome;
  final double totalExpense;

  const TransactionOverview({
    Key? key,
    required this.balance,
    required this.totalIncome,
    required this.totalExpense,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _TransactionOverviewState createState() => _TransactionOverviewState();
}

class _TransactionOverviewState extends State<TransactionOverview> {
  bool _showBalance = true;

  @override
  Widget build(BuildContext context) {
    Color balanceColor = widget.balance >= 0 ? Colors.green : Colors.red;

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Balance',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: balanceColor,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _showBalance ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _showBalance = !_showBalance;
                    });
                  },
                ),
              ],
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _showBalance
                  ? Text(
                      'Rs ${widget.balance.toStringAsFixed(2)}',
                      key: ValueKey<bool>(_showBalance),
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: balanceColor,
                      ),
                    )
                  : Text(
                      'Rs ****',
                      key: ValueKey<bool>(_showBalance),
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: balanceColor,
                      ),
                    ),
            ),
            const SizedBox(height: 20),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _showBalance
                  ? Column(
                      key: ValueKey<bool>(_showBalance),
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Income:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Rs ${widget.totalIncome.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Text(
                              'Expense:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Rs ${widget.totalExpense.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Column(
                      key: ValueKey<bool>(_showBalance),
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Income: Rs ****',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          'Expense: Rs ****',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
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
