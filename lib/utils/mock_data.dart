// lib/utils/mock_data.dart
import '../models/transaction.dart';
import 'dart:math';

final List<Transaction> mockTransactions = _generateMockTransactions();

List<Transaction> _generateMockTransactions() {
  List<Transaction> transactions = [];
  Random random = Random();

  List<String> categories = [
    'Food',
    'Transport',
    'Entertainment',
    'Housing',
    'Health',
    'Education',
    'Shopping',
    'Utilities',
    'Travel',
    'Other'
  ];

  for (int i = 0; i < 100; i++) {
    // สุ่มจำนวนเงิน
    int amount = (random.nextInt(1000) + 100) * (random.nextBool() ? -1 : 1); // สุ่มจำนวนเงินระหว่าง -1000 ถึง 1000

    // สุ่มประเภท (income หรือ expense)
    String type = amount < 0 ? 'expense' : 'income';

    // สุ่มหมวดหมู่
    String category = categories[random.nextInt(categories.length)];

    // สุ่มวันที่ย้อนหลังระหว่าง 0 ถึง 90 วัน
    DateTime date = DateTime.now().subtract(Duration(days: random.nextInt(90)));

    // สร้างธุรกรรม
    transactions.add(
      Transaction(
        amount: amount.abs(), // ใช้ absolute value สำหรับ amount
        type: type,
        category: category,
        description: 'Mock transaction ${i + 1}',
        date: date,
      ),
    );
  }

  return transactions;
}
