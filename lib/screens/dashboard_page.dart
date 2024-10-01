import 'package:flutter/material.dart';
import 'add_transaction_page.dart';
import 'history_page.dart';
import 'summary_page.dart';
import 'login_page.dart';
import 'profile_page.dart';
import '../services/auth_service.dart';
import '../services/transaction_service.dart';
import '../models/transaction.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  final AuthService _auth = AuthService();
  List<Transaction> _transactions = [];
  int _balance = 0;
  int _income = 0;
  int _expense = 0;

  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '฿', decimalDigits: 0);

  static List<Widget> _otherPages = <Widget>[
    AddTransactionPage(),
    HistoryPage(),
    SummaryPage(),
    ProfilePage()
  ];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final transactions = await TransactionService(useMockData: false).getTransactions(); // Use false to load user-added transactions
    if (transactions.isNotEmpty) {
      setState(() {
        _transactions = transactions..sort((a, b) => b.date.compareTo(a.date));
        _calculateBalance();
      });
    }
  }

  void _calculateBalance() {
    int incomeTotal = 0;
    int expenseTotal = 0;

    for (var transaction in _transactions) {
      if (transaction.type.toLowerCase() == 'income') {
        incomeTotal += transaction.amount;
      } else if (transaction.type.toLowerCase() == 'expense') {
        expenseTotal += transaction.amount;
      }
    }

    setState(() {
      _income = incomeTotal;
      _expense = expenseTotal;
      _balance = incomeTotal - expenseTotal;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() async {
    await _auth.logout();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  Widget _buildBalanceSection() {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Balance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              _currencyFormat.format(_balance),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _balance >= 0 ? Colors.green : Colors.red,
              ),
            ),
            SizedBox(height: 16),
            Divider(color: Colors.grey[300], thickness: 1),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBalanceItem('Income', _income, Colors.green),
                _buildBalanceItem('Expense', _expense, Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceItem(String title, int amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        SizedBox(height: 4),
        Text(
          _currencyFormat.format(amount),
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildRecentTransactions() {
    return _transactions.isEmpty
        ? Center(child: Text('No transactions available'))
        : Card(
            elevation: 4,
            margin: EdgeInsets.all(16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Transactions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  ..._transactions.take(5).map((transaction) => _buildTransactionItem(transaction)),
                ],
              ),
            ),
          );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                transaction.category,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                DateFormat('dd/MM/yyyy').format(transaction.date),
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          Text(
            _currencyFormat.format(transaction.amount),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: transaction.type.toLowerCase() == 'income' ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'MEP',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              TextSpan(
                text: '   Expense Manager personal',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _logout,
          ),
        ],
      ),
      body: _selectedIndex == 0
          ? RefreshIndicator(
              onRefresh: _loadTransactions,
              child: ListView(
                children: [
                  _buildBalanceSection(),
                  _buildRecentTransactions(),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: ElevatedButton(
                      child: Text('View All Transactions'),
                      onPressed: () {
                        _onItemTapped(2); // Switch to History page
                      },
                    ),
                  ),
                ],
              ),
            )
          : _otherPages.elementAt(_selectedIndex - 1),
       bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: 'Summary',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
