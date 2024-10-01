class Transaction {
  int amount;          // จำนวนเงิน (เปลี่ยนจาก double เป็น int)
  String type;         // ประเภท (income/expense)
  String category;     // หมวดหมู่
  String description;  // คำอธิบาย
  DateTime date;       // วันที่

  Transaction({
    required this.amount,
    required this.type,
    required this.category,
    required this.description,
    required this.date,
  });

  // แปลงจาก JSON ไปเป็น Transaction object
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      amount: json['amount'],  // เปลี่ยนเป็น int โดยไม่ต้องแปลง
      type: json['type'],
      category: json['category'],
      description: json['description'],
      date: DateTime.parse(json['date']),  // แปลงจาก string ไปเป็น DateTime
    );
  }

  // แปลงจาก Transaction object ไปเป็น JSON
  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'type': type,
      'category': category,
      'description': description,
      'date': date.toIso8601String(),  // แปลง DateTime เป็น string ในรูปแบบ ISO
    };
  }

  // ฟังก์ชัน toString() สำหรับการตรวจสอบข้อมูล
  @override
  String toString() {
    return 'Transaction(amount: $amount, type: $type, category: $category, description: $description, date: $date)';
  }
}
