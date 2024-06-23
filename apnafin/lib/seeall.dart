import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'expincdetail.dart';

class SeeAll extends StatefulWidget {
  final List<ExpenseItem> itemList;

  const SeeAll({Key? key, required this.itemList}) : super(key: key);

  @override
  State<SeeAll> createState() => _SeeAllState();
}

class _SeeAllState extends State<SeeAll> {
  late List<ExpenseItem> _filteredItemList;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSelectionMode = false;
  final Set<ExpenseItem> _selectedItems = {};

  @override
  void initState() {
    super.initState();
    _filteredItemList = widget.itemList;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _filteredItemList = widget.itemList.where((item) {
        final title = item.title.toLowerCase();
        return title.contains(_searchQuery);
      }).toList();
    });
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedItems.clear();
      }
    });
  }

  void _deleteSelectedItems() {
    setState(() {
      widget.itemList.removeWhere((item) => _selectedItems.contains(item));
      _filteredItemList = widget.itemList;
      _toggleSelectionMode();
    });
  }

  List<ExpenseItem> _getCategorizedItems(String type) {
    return _filteredItemList.where((item) => item.type == type).toList();
  }

  Future<void> _generatePdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Income and Expense Report',
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 20),
              ..._buildPdfCategoryList('Income', Colors.green),
              ..._buildPdfCategoryList('Expense', Colors.red),
            ],
          );
        },
      ),
    );

    try {
      final status = await Permission.storage.request();
      if (status.isGranted) {
        final directory = await getExternalStorageDirectory();
        final path = '${directory!.path}/report.pdf';
        final file = File(path);
        await file.writeAsBytes(await pdf.save());
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('PDF saved to $path'),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Permission denied'),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error saving PDF: $e'),
      ));
    }
  }

  List<pw.Widget> _buildPdfCategoryList(String type, Color color) {
    List<ExpenseItem> items = _getCategorizedItems(type);
    if (items.isEmpty) return [];

    return [
      pw.Text(
        type,
        style: pw.TextStyle(
          fontSize: 20,
          fontWeight: pw.FontWeight.bold,
          color: PdfColor.fromInt(color.value),
        ),
      ),
      pw.SizedBox(height: 10),
      ...items.map((item) {
        String formattedDate = item.date != null
            ? DateFormat('yyyy-MM-dd').format(item.date!.toDate())
            : 'N/A';
        return pw.Container(
          margin: const pw.EdgeInsets.symmetric(vertical: 4),
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey, width: 0.5),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Date: $formattedDate',
                style: pw.TextStyle(color: PdfColors.grey),
              ),
              pw.Text(
                item.title,
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                item.option,
                style: pw.TextStyle(color: PdfColors.grey),
              ),
              pw.Text(
                '${item.type == 'Income' ? '+ ' : '- '}${item.amount}',
                style: pw.TextStyle(
                  color: PdfColor.fromInt(color.value),
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    ];
  }

  Widget _buildCategoryList(String type, IconData icon, Color color) {
    List<ExpenseItem> items = _getCategorizedItems(type);
    if (items.isEmpty) return Container();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            type,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        ...items.map((item) {
          String formattedDate = item.date != null
              ? DateFormat('yyyy-MM-dd').format(item.date!.toDate())
              : 'N/A';
          bool isSelected = _selectedItems.contains(item);
          return GestureDetector(
            onLongPress: () {
              setState(() {
                _isSelectionMode = true;
                _selectedItems.add(item);
              });
            },
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Date: $formattedDate',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      if (_isSelectionMode) {
                        setState(() {
                          if (isSelected) {
                            _selectedItems.remove(item);
                          } else {
                            _selectedItems.add(item);
                          }
                        });
                      }
                    },
                    leading: _isSelectionMode
                        ? Checkbox(
                            value: isSelected,
                            onChanged: (bool? checked) {
                              setState(() {
                                if (checked!) {
                                  _selectedItems.add(item);
                                } else {
                                  _selectedItems.remove(item);
                                }
                              });
                            },
                          )
                        : Icon(icon, color: color, size: 24),
                    title: RichText(
                      text: TextSpan(
                        text: '',
                        style:
                            const TextStyle(color: Colors.black, fontSize: 18),
                        children:
                            _highlightOccurrences(item.title, _searchQuery),
                      ),
                    ),
                    subtitle: Text(
                      item.option,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: Text(
                      '${item.type == 'Income' ? '+ ' : '- '}${item.amount}',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  List<TextSpan> _highlightOccurrences(String source, String query) {
    if (query.isEmpty) {
      return [TextSpan(text: source)];
    }
    List<TextSpan> spans = [];
    int start = 0;
    int index = source.toLowerCase().indexOf(query.toLowerCase(), start);
    while (index != -1) {
      if (index > start) {
        spans.add(TextSpan(text: source.substring(start, index)));
      }
      spans.add(TextSpan(
        text: source.substring(index, index + query.length),
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
      ));
      start = index + query.length;
      index = source.toLowerCase().indexOf(query.toLowerCase(), start);
    }
    if (start < source.length) {
      spans.add(TextSpan(text: source.substring(start)));
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Income and Expense"),
        centerTitle: true,
        backgroundColor: Colors.teal,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
              ),
            ),
          ),
        ),
        actions: _isSelectionMode
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _deleteSelectedItems,
                ),
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.picture_as_pdf),
                  onPressed: _generatePdf,
                ),
              ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _filteredItemList.isEmpty
                ? const Center(
                    child: Text(
                      'No items found',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView(
                    children: [
                      _buildCategoryList(
                          'Income', Icons.arrow_downward, Colors.green),
                      _buildCategoryList(
                          'Expense', Icons.arrow_upward, Colors.red),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
