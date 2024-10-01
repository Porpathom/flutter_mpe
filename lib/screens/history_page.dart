import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../services/transaction_service.dart';

class HistoryPage extends StatefulWidget {
  final bool useMockData;

  HistoryPage({this.useMockData = true});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late TransactionService _transactionService;
  List<Transaction> _transactions = [];
  List<Transaction> _filteredTransactions = [];
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedType;
  List<String> _selectedCategories = [];
  bool _isFilterExpanded = false;

  final List<String> _types = ['All', 'Expense', 'Income'];
  final Map<String, List<String>> _categories = {
    'Expense': ['Food', 'Transport', 'Housing', 'Utilities', 'Entertainment', 'Healthcare', 'Education', 'Shopping', 'Personal', 'Debt', 'Savings', 'Investment', 'Gifts', 'Travel', 'Other'],
    'Income': ['Salary', 'Freelance', 'Investments', 'Rental', 'Gifts', 'Refunds', 'Other'],
  };

  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '฿', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _transactionService = TransactionService(useMockData: widget.useMockData);
    _loadTransactions();
  }

  void _loadTransactions() async {
    final transactions = await _transactionService.getTransactions();
    setState(() {
      _transactions = transactions..sort((a, b) => b.date.compareTo(a.date));
      _filteredTransactions = List.from(_transactions);
    });
  }

  void _filterTransactions() {
    setState(() {
      _filteredTransactions = _transactions.where((transaction) {
        bool dateFilter = true;
        if (_startDate != null) {
          dateFilter = dateFilter && !transaction.date.isBefore(_startDate!);
        }
        if (_endDate != null) {
          dateFilter = dateFilter && transaction.date.isBefore(_endDate!.add(Duration(days: 1)));
        }

        bool typeFilter = _selectedType == null || _selectedType == 'All' || transaction.type == _selectedType;
        bool categoryFilter = _selectedCategories.isEmpty || _selectedCategories.contains(transaction.category);

        return dateFilter && typeFilter && categoryFilter;
      }).toList();
    });
  }

  void _resetFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _selectedType = null;
      _selectedCategories = [];
      _filteredTransactions = List.from(_transactions);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction History'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              setState(() {
                _isFilterExpanded = !_isFilterExpanded;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: _isFilterExpanded ? null : 0,
            child: _buildFilterSection(),
          ),
          Expanded(
            child: _buildTransactionList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFilterSection() {
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildDateButton(label: 'Start Date', date: _startDate, onPressed: () => _selectDate(isStartDate: true))),
                SizedBox(width: 8),
                Expanded(child: _buildDateButton(label: 'End Date', date: _endDate, onPressed: () => _selectDate(isStartDate: false))),
              ],
            ),
            SizedBox(height: 8),
            _buildDropdown<String>(
              value: _selectedType,
              items: _types,
              hint: 'Select Type',
              onChanged: (value) {
                setState(() {
                  _selectedType = value;
                  _selectedCategories = [];
                });
              },
            ),
            SizedBox(height: 8),
            _buildMultiSelectChip(),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: ElevatedButton(onPressed: _filterTransactions, child: Text('Apply Filter'))),
                SizedBox(width: 8),
                Expanded(child: ElevatedButton.icon(onPressed: _resetFilters, icon: Icon(Icons.refresh), label: Text('Reset'))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMultiSelectChip() {
    List<String> categories = (_selectedType == null || _selectedType == 'All') 
        ? [..._categories['Expense']!, ..._categories['Income']!].toSet().toList()
        : _categories[_selectedType]!;

    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: categories.map((String category) {
        return FilterChip(
          label: Text(category),
          selected: _selectedCategories.contains(category),
          onSelected: (bool selected) {
            setState(() {
              if (selected) {
                _selectedCategories.add(category);
              } else {
                _selectedCategories.remove(category);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildDropdown<T>({
    T? value,
    required List<T> items,
    required String hint,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      hint: Text(hint),
      isExpanded: true,
      items: items.map((item) => DropdownMenuItem<T>(value: item, child: Text(item.toString()))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      ),
    );
  }

  Widget _buildTransactionList() {
    return ListView.builder(
      itemCount: _filteredTransactions.length,
      itemBuilder: (context, index) {
        final transaction = _filteredTransactions[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: transaction.type.toLowerCase() == 'income' ? Colors.green : Colors.red,
              child: Icon(transaction.type.toLowerCase() == 'income' ? Icons.arrow_upward : Icons.arrow_downward, color: Colors.white),
            ),
            title: Text(_currencyFormat.format(transaction.amount),
              style: TextStyle(fontWeight: FontWeight.bold, color: transaction.type.toLowerCase() == 'income' ? Colors.green : Colors.red),
            ),
            subtitle: Text('${transaction.category} - ${transaction.description}'),
            trailing: Text(DateFormat('dd/MM/yyyy').format(transaction.date)),
            onTap: () => _showTransactionDetails(transaction),
          ),
        );
      },
    );
  }

  Widget _buildDateButton({required String label, DateTime? date, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(date == null ? label : DateFormat('dd/MM/yyyy').format(date)),
      style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 40)),
    );
  }

  Future<void> _selectDate({required bool isStartDate}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _showTransactionDetails(Transaction transaction) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Transaction Details'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Amount: ${_currencyFormat.format(transaction.amount)}'),
              Text('Type: ${transaction.type}'),
              Text('Category: ${transaction.category}'),
              Text('Description: ${transaction.description}'),
              Text('Date: ${DateFormat('dd/MM/yyyy').format(transaction.date)}'),
            ],
          ),
          actions: [
            
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteTransaction(transaction);
              },
            ),
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _editTransaction(Transaction transaction) {
    // TODO: Implement edit transaction functionality
    // This could open a new page or dialog to edit the transaction
    // After editing, call _transactionService.updateTransaction() and _loadTransactions()
  }

  void _deleteTransaction(Transaction transaction) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Transaction'),
          content: Text('Are you sure you want to delete this transaction?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _transactionService.deleteTransaction(transaction);
                _loadTransactions();
              },
            ),
          ],
        );
      },
    );
  }
}