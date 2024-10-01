import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_mpe/screens/dashboard_page.dart';
import '../models/transaction.dart';
import '../services/transaction_service.dart';

class AddTransactionPage extends StatefulWidget {
  @override
  _AddTransactionPageState createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedType = 'expense';
  String _selectedCategory = 'Food';
  DateTime _selectedDate = DateTime.now();
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  final Map<String, List<String>> _categories = {
    'expense': ['Food', 'Transport', 'Housing', 'Utilities', 'Entertainment', 'Healthcare', 'Education', 'Shopping', 'Personal', 'Debt', 'Savings', 'Investment', 'Gifts', 'Travel', 'Other'],
    'income': ['Salary', 'Freelance', 'Investments', 'Rental', 'Gifts', 'Refunds', 'Other'],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Transaction'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            _buildTransactionTypeSelector(),
            SizedBox(height: 16),
            _buildAmountField(),
            SizedBox(height: 16),
            _buildCategoryDropdown(),
            SizedBox(height: 16),
            _buildDescriptionField(),
            SizedBox(height: 16),
            _buildDatePicker(),
            SizedBox(height: 32),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTypeSelector() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: Text('Expense'),
                value: 'expense',
                groupValue: _selectedType,
                onChanged: (value) => setState(() {
                  _selectedType = value!;
                  _selectedCategory = _categories[_selectedType]![0];
                }),
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: Text('Income'),
                value: 'income',
                groupValue: _selectedType,
                onChanged: (value) => setState(() {
                  _selectedType = value!;
                  _selectedCategory = _categories[_selectedType]![0];
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      decoration: InputDecoration(
        labelText: 'Amount',
        prefixIcon: Icon(Icons.attach_money),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter an amount';
        }
        if (double.tryParse(value) == null) {
          return 'Please enter a valid number';
        }
        return null;
      },
     
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: InputDecoration(
        labelText: 'Category',
        prefixIcon: Icon(Icons.category),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      items: _categories[_selectedType]!.map((String category) {
        return DropdownMenuItem(
          value: category,
          child: Row(
            children: [
              Icon(_getCategoryIcon(category)),
              SizedBox(width: 8),
              Text(category),
            ],
          ),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedCategory = newValue!;
        });
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: InputDecoration(
        labelText: 'Description',
        prefixIcon: Icon(Icons.description),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      maxLines: 3,
    );
  }

  Widget _buildDatePicker() {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(Icons.calendar_today),
        title: Text('Date'),
        subtitle: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
        onTap: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: _selectedDate,
            firstDate: DateTime(2000),
            lastDate: DateTime.now(),
          );
          if (picked != null && picked != _selectedDate) {
            setState(() {
              _selectedDate = picked;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Selected date: ${DateFormat('dd/MM/yyyy').format(picked)}')),
            );
          }
        },
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      child: Text('Save Transaction'),
      onPressed: _saveTransaction,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }


  // Map category to icon
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.fastfood;
      case 'Transport':
        return Icons.directions_car;
      case 'Housing':
        return Icons.home;
      case 'Utilities':
        return Icons.build;
      case 'Entertainment':
        return Icons.movie;
      default:
        return Icons.category;
    }
  }

  void _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      final transaction = Transaction(
        amount: int.parse(_amountController.text.replaceAll(RegExp(r'[^\d.]'), '')),
        type: _selectedType,
        category: _selectedCategory,
        description: _descriptionController.text,
        date: _selectedDate,
      );

      try {
        await TransactionService().addTransaction(transaction);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Transaction saved successfully')),
        );
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardPage()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save transaction')),
        );
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}