import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';
import '../utils/mock_data.dart';

class TransactionService {
  String _storageKey = 'transactions';
  final bool _useMockData;

  TransactionService({bool useMockData = false}) : _useMockData = useMockData {
    print("TransactionService initialized with useMockData: $_useMockData");
  }

  Future<List<Transaction>> getTransactions() async {
    if (_useMockData) {
      print("Using mock data");
      await Future.delayed(Duration(milliseconds: 500)); // Simulate network delay
      return [...mockTransactions];
    } else {
      final prefs = await SharedPreferences.getInstance();
      final String? transactionsJson = prefs.getString(_storageKey);
      if (transactionsJson == null) {
        print("No transactions found in SharedPreferences");
        return [];
      }
      final List<dynamic> decodedList = json.decode(transactionsJson);
      return decodedList.map((item) => Transaction.fromJson(item)).toList();
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    if (_useMockData) {
      mockTransactions.add(transaction);
      await Future.delayed(Duration(milliseconds: 500)); // Simulate network delay
    } else {
      List<Transaction> transactions = await getTransactions();
      transactions.add(transaction);
      await _saveTransactions(transactions);
    }
  }

  Future<void> updateTransaction(Transaction updatedTransaction) async {
    if (_useMockData) {
      final index = mockTransactions.indexWhere((t) =>
          t.amount == updatedTransaction.amount &&
          t.description == updatedTransaction.description &&
          t.date == updatedTransaction.date);
      if (index != -1) {
        mockTransactions[index] = updatedTransaction;
      }
      await Future.delayed(Duration(milliseconds: 500)); // Simulate network delay
    } else {
      List<Transaction> transactions = await getTransactions();
      final index = transactions.indexWhere((t) =>
          t.amount == updatedTransaction.amount &&
          t.description == updatedTransaction.description &&
          t.date == updatedTransaction.date);
      if (index != -1) {
        transactions[index] = updatedTransaction;
        await _saveTransactions(transactions);
      }
    }
  }

  Future<void> deleteTransaction(Transaction transaction) async {
    if (_useMockData) {
      mockTransactions.removeWhere((t) =>
          t.amount == transaction.amount &&
          t.description == transaction.description &&
          t.date == transaction.date);
      await Future.delayed(Duration(milliseconds: 500)); // Simulate network delay
    } else {
      List<Transaction> transactions = await getTransactions();
      transactions.removeWhere((t) =>
          t.amount == transaction.amount &&
          t.description == transaction.description &&
          t.date == transaction.date);
      await _saveTransactions(transactions);
    }
  }

  Future<void> _saveTransactions(List<Transaction> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final encodedList = transactions.map((t) => t.toJson()).toList();
    await prefs.setString(_storageKey, json.encode(encodedList));
  }
}
