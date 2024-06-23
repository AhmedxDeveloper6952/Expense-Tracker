import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartPage extends StatefulWidget {
  const ChartPage({Key? key}) : super(key: key);

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showPieChart = true;
  String _selectedTimeFilter = 'Monthly';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Financial Overview',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Income'),
            Tab(text: 'Expense'),
          ],
          indicatorColor: Colors.white,
        ),
        actions: [
          DropdownButton<String>(
            value: _selectedTimeFilter,
            onChanged: (String? newValue) {
              setState(() {
                _selectedTimeFilter = newValue!;
              });
            },
            items: <String>['Weekly', 'Monthly', 'Yearly']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          IconButton(
            icon: Icon(_showPieChart ? Icons.bar_chart : Icons.pie_chart),
            onPressed: () {
              setState(() {
                _showPieChart = !_showPieChart;
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildChart('Income'),
            _buildChart('Expense'),
          ],
        ),
      ),
      backgroundColor: Colors.grey[200],
    );
  }

  Widget _buildChart(String type) {
    return FutureBuilder(
      future: _getChartData(type),
      builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No data available.'));
        } else {
          Map<String, double> data = snapshot.data?['chartData'] ?? {};
          List<Map<String, dynamic>> transactionList =
              snapshot.data?['transactionList'] ?? [];
          List<Color> colors = _generateColors(data.length);

          transactionList.sort((a, b) => b['amount'].compareTo(a['amount']));

          return Column(
            children: [
              SizedBox(
                height: 250,
                child: _showPieChart
                    ? _buildPieChartWidget(data, colors)
                    : _buildBarChartWidget(data, colors),
              ),
              const SizedBox(height: 16.0),
              Expanded(
                child: _buildTransactionList(transactionList, type),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildPieChartWidget(Map<String, double> data, List<Color> colors) {
    List<ChartData> chartData = _generateChartData(data, colors);

    return Stack(
      children: [
        Center(
          child: SizedBox(
            width: 250,
            height: 250,
            child: SfCircularChart(
              series: <CircularSeries>[
                PieSeries<ChartData, String>(
                  dataSource: chartData,
                  xValueMapper: (ChartData data, _) => data.x,
                  yValueMapper: (ChartData data, _) => data.y,
                  pointColorMapper: (ChartData data, _) => data.color,
                  dataLabelMapper: (ChartData data, _) => data.y.toString(),
                  dataLabelSettings: const DataLabelSettings(isVisible: true),
                  enableTooltip: true,
                )
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _buildIndicators(data, colors),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBarChartWidget(Map<String, double> data, List<Color> colors) {
    List<ChartData> chartData = _generateChartData(data, colors);

    return SfCartesianChart(
      primaryXAxis: const CategoryAxis(),
      primaryYAxis: const NumericAxis(),
      series: <CartesianSeries>[
        ColumnSeries<ChartData, String>(
          dataSource: chartData,
          xValueMapper: (ChartData data, _) => data.x,
          yValueMapper: (ChartData data, _) => data.y,
          pointColorMapper: (ChartData data, _) => data.color,
          dataLabelSettings: const DataLabelSettings(isVisible: true),
        )
      ],
      zoomPanBehavior: ZoomPanBehavior(
        enablePinching: true,
        enablePanning: true,
        enableDoubleTapZooming: true,
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
    );
  }

  List<Widget> _buildIndicators(Map<String, double> data, List<Color> colors) {
    if (data.isEmpty) {
      return [const Text('No data available.')];
    }

    List<Widget> indicators = [];
    double total =
        data.values.isEmpty ? 0 : data.values.reduce((a, b) => a + b);

    data.forEach((option, value) {
      double percentage = (total == 0) ? 0 : (value / total) * 100;
      indicators.add(
        Indicator(
          color: colors[indicators.length % colors.length],
          text: option,
          percentage: percentage,
        ),
      );
      indicators.add(
        const SizedBox(height: 4),
      );
    });

    return indicators;
  }

  Widget _buildTransactionList(
      List<Map<String, dynamic>> transactionList, String type) {
    if (transactionList.isEmpty) {
      return const Center(child: Text('No transactions available.'));
    }

    return ListView.builder(
      itemCount: transactionList.length,
      itemBuilder: (context, index) {
        final transaction = transactionList[index];
        return Card(
          elevation: 5,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      TransactionDetailPage(transaction: transaction),
                ),
              );
            },
            contentPadding: const EdgeInsets.all(16),
            leading: Icon(
              transaction['type'] == 'Income'
                  ? Icons.arrow_downward
                  : Icons.arrow_upward,
              color:
                  transaction['type'] == 'Income' ? Colors.green : Colors.red,
              size: 24,
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${transaction['option']}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat.yMMMd().format(transaction['date']),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            trailing: Text(
              '\$${transaction['amount'].toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                color:
                    transaction['type'] == 'Income' ? Colors.green : Colors.red,
              ),
            ),
          ),
        );
      },
    );
  }

  List<ChartData> _generateChartData(
      Map<String, double> data, List<Color> colors) {
    List<ChartData> chartData = [];
    int index = 0;
    data.forEach((category, value) {
      chartData.add(ChartData(category, value, colors[index % colors.length]));
      index++;
    });
    return chartData;
  }

  Future<Map<String, dynamic>> _getChartData(String type) async {
    Map<String, double> chartData = {};
    Map<String, double> aggregatedData = {};
    List<Map<String, dynamic>> transactionList = [];

    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection("Employee").get();

    for (var doc in querySnapshot.docs) {
      String transactionType = doc['Type'];
      String category = doc['Category'];
      String option = doc['Option'];
      dynamic amount = doc['Amount'];
      String title = doc['Title'];
      DateTime date = doc['Date'].toDate();

      if (transactionType == type) {
        double amountValue =
            amount is int ? amount.toDouble() : double.parse(amount.toString());

        String key = option;
        double currentAmount = amountValue;

        if (_filterByDate(date)) {
          if (aggregatedData.containsKey(key)) {
            aggregatedData[key] = aggregatedData[key]! + currentAmount;
          } else {
            aggregatedData[key] = currentAmount;
          }

          transactionList.add({
            'type': transactionType,
            'category': category,
            'option': option,
            'amount': amountValue,
            'title': title,
            'date': date,
          });
        }
      }
    }

    chartData = aggregatedData;

    return {'chartData': chartData, 'transactionList': transactionList};
  }

  bool _filterByDate(DateTime date) {
    DateTime now = DateTime.now();
    switch (_selectedTimeFilter) {
      case 'Weekly':
        return date.isAfter(now.subtract(const Duration(days: 7)));
      case 'Monthly':
        return date.isAfter(DateTime(now.year, now.month - 1, now.day));
      case 'Yearly':
        return date.isAfter(DateTime(now.year - 1, now.month, now.day));
      default:
        return true;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Color> _generateColors(int count) {
    List<Color> colors = [];
    for (int i = 0; i < count; i++) {
      colors.add(Colors.primaries[i % Colors.primaries.length]);
    }
    return colors;
  }
}

class Indicator extends StatelessWidget {
  final Color color;
  final String text;
  final double percentage;

  const Indicator({
    Key? key,
    required this.color,
    required this.text,
    required this.percentage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
          margin: const EdgeInsets.symmetric(vertical: 4),
        ),
        const SizedBox(width: 4),
        Text(
          '$text (${percentage.toStringAsFixed(2)}%)',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class ChartData {
  final String x;
  final double y;
  final Color color;

  ChartData(this.x, this.y, this.color);
}

class TransactionDetailPage extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const TransactionDetailPage({Key? key, required this.transaction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(transaction['title']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Type: ${transaction['type']}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Category: ${transaction['category']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Option: ${transaction['option']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Amount: \$${transaction['amount'].toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Date: ${DateFormat.yMMMd().format(transaction['date'])}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Title: ${transaction['title']}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
