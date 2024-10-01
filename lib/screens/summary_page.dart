import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../models/transaction.dart';
import '../services/transaction_service.dart';

class SummaryPage extends StatefulWidget {
  const SummaryPage({Key? key}) : super(key: key);

  @override
  _SummaryPageState createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  final TransactionService _transactionService = TransactionService(useMockData: true);
  DateTime selectedMonth = DateTime.now();
  List<Transaction> monthlyTransactions = [];
  Map<String, int> categoryTotals = {};
  List<MapEntry<String, int>> sortedCategories = [];
  bool isLocaleInitialized = false;
  bool isLoading = true;
  int totalExpense = 0;
  int totalIncome = 0;

  final List<Color> categoryColors = [
  Colors.blue,
  Colors.red,
  Colors.green,
  Colors.orange,
  Colors.purple,
  Colors.teal,
  Colors.pink,
  Colors.amber,
  Colors.cyan,
  Colors.lime,
  Colors.indigo,
  Colors.brown,
  Colors.grey,
  Colors.lightBlue,
  Colors.deepOrange,
];


  @override
  void initState() {
    super.initState();
    _initializeLocale();
  }

  Future<void> _initializeLocale() async {
    await initializeDateFormatting('th', null);
    setState(() {
      isLocaleInitialized = true;
    });
    await _loadTransactions();
  }

  Future<void> _loadTransactions() async {
  setState(() {
    isLoading = true;
  });

  try {
    // ดึงข้อมูลทั้งหมดจาก TransactionService
    final allTransactions = await _transactionService.getTransactions();
    
    // รีเซ็ตค่าทั้งหมด
    categoryTotals.clear();
    totalExpense = 0;
    totalIncome = 0;

    setState(() {
      // กรองข้อมูลเฉพาะเดือนที่เลือก
      monthlyTransactions = allTransactions.where((t) =>
          t.date.year == selectedMonth.year &&
          t.date.month == selectedMonth.month).toList();

      // คำนวณยอดรวมรายจ่ายตามหมวดหมู่
      for (var transaction in monthlyTransactions) {
        if (transaction.type == 'expense') {
          categoryTotals[transaction.category] = 
              (categoryTotals[transaction.category] ?? 0) + transaction.amount;
          totalExpense += transaction.amount;
        } else if (transaction.type == 'income') {
          totalIncome += transaction.amount;
        }
      }

      // จัดเรียงหมวดหมู่ตามยอดเงิน
      sortedCategories = categoryTotals.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
    });
  } catch (e) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('เกิดข้อผิดพลาด'),
        content: const Text('ไม่สามารถโหลดข้อมูลได้ กรุณาลองใหม่อีกครั้ง'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}


  Widget _buildMonthSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                selectedMonth = DateTime(
                  selectedMonth.year,
                  selectedMonth.month - 1,
                );
              });
              _loadTransactions();
            },
          ),
          TextButton(
            onPressed: _showMonthPicker,
            child: Text(
              DateFormat('MMMM yyyy', 'th').format(selectedMonth),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                selectedMonth = DateTime(
                  selectedMonth.year,
                  selectedMonth.month + 1,
                );
              });
              _loadTransactions();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'รายรับ',
            totalIncome,
            Icons.arrow_upward,
            Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            'รายจ่าย',
            totalExpense,
            Icons.arrow_downward,
            Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, int amount, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              NumberFormat("#,##0").format(amount),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text('บาท', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

 Widget _buildPieChart() {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'สัดส่วนรายรับ-รายจ่าย',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          (totalIncome == 0 && totalExpense == 0)
              ? Center(
                  child: Text(
                    'ไม่มีข้อมูลค่าใช้จ่ายเดือนนี้',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                )
              : Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 18,
                            sections: [
                              PieChartSectionData(
                                color: Colors.green.shade400,
                                value: totalIncome.toDouble(),
                                title: '${((totalIncome / (totalIncome + totalExpense)) * 100).toStringAsFixed(1)}%',
                                radius: 100,
                                titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              PieChartSectionData(
                                color: Colors.red.shade400,
                                value: totalExpense.toDouble(),
                                title: '${((totalExpense / (totalIncome + totalExpense)) * 100).toStringAsFixed(1)}%',
                                radius: 100,
                                titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLegendItem(
                            'รายรับ',
                            Colors.green.shade400,
                            '${NumberFormat("#,##0").format(totalIncome)} บาท',
                          ),
                          const SizedBox(height: 16),
                          _buildLegendItem(
                            'รายจ่าย',
                            Colors.red.shade400,
                            '${NumberFormat("#,##0").format(totalExpense)} บาท',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ],
      ),
    ),
  );
}



  List<PieChartSectionData> _generatePieChartSections() {
  final total = totalIncome + totalExpense;
  return [
    PieChartSectionData(
      color: const Color.fromRGBO(76, 175, 80, 1),
      value: totalIncome.toDouble(),
      title: '${((totalIncome / total) * 100).toStringAsFixed(1)}%',
      radius: 100,
      titleStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    PieChartSectionData(
      color: Colors.red,
      value: totalExpense.toDouble(),
      title: '${((totalExpense / total) * 100).toStringAsFixed(1)}%',
      radius: 100,
      titleStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
  ];
}
Widget _buildLegendItem(String label, Color color, String amount) {
  return Row(
    children: [
      Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Text(
              amount,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    ],
  );
}
List<Widget> _buildLegends() {
  return List.generate(sortedCategories.length, (index) {
    final category = sortedCategories[index];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: categoryColors[index % categoryColors.length].withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: categoryColors[index % categoryColors.length]),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: categoryColors[index % categoryColors.length],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            category.key,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: categoryColors[index % categoryColors.length],
            ),
          ),
        ],
      ),
    );
  });
}
 Widget _buildExpenseChart() {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'รายละเอียดค่าใช้จ่าย',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: sortedCategories.isEmpty
                ? Center(
                    child: Text(
                      'ไม่มีข้อมูลค่าใช้จ่ายเดือนนี้',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  )
                : BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: sortedCategories.first.value.toDouble(),
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (BarChartGroupData group) {
      return Colors.blueGrey.withOpacity(0.8);
                          },
                          tooltipPadding: const EdgeInsets.all(8),
                          tooltipMargin: 8,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              '${sortedCategories[groupIndex].key}\n${NumberFormat("#,##0").format(rod.toY)} บาท',
                              const TextStyle(color: Colors.white),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: false,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              int index = value.toInt();
                              if (index >= 0 && index < sortedCategories.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    sortedCategories[index].key,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                );
                              }
                              return const Text('');
                            },
                            reservedSize: 40,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                NumberFormat.compact().format(value),
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border(
                          bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                          left: BorderSide(color: Colors.grey[300]!, width: 1),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: sortedCategories.first.value.toDouble() / 5,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey[300],
                            strokeWidth: 1,
                          );
                        },
                      ),
                      barGroups: List.generate(
                        sortedCategories.length,
                        (index) => BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: sortedCategories[index].value.toDouble(),
                              color: categoryColors[index % categoryColors.length],
                              width: 16,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _buildLegends(),
          ),
           const SizedBox(height: 24),
          // Add expense summary here
          _buildExpenseSummary(),
        ],
      ),
    ),
  );
}

Widget _buildExpenseSummary() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'สรุปค่าใช้จ่าย',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 16),  // เพิ่มระยะห่างระหว่างหัวข้อและรายการ
      ...sortedCategories.map((category) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),  // เพิ่มระยะห่างระหว่างรายการ
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(category.key, style: TextStyle(fontSize: 14)),
            Text(
              '${NumberFormat("#,##0").format(category.value)} บาท',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      )).toList(),
      const Divider(height: 24, thickness: 1),  // เพิ่มความหนาและระยะห่างของเส้นแบ่ง
      Padding(
        padding: const EdgeInsets.only(top: 8),  // เพิ่มระยะห่างด้านบนของยอดรวม
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('รวมทั้งหมด', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(
              '${NumberFormat("#,##0").format(sortedCategories.fold(0, (sum, item) => sum + item.value))} บาท',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    ],
  );
}
  void _showMonthPicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return MonthYearPicker(
          selectedDate: selectedMonth,
          onChanged: (DateTime newDate) {
            setState(() {
              selectedMonth = newDate;
            });
            _loadTransactions();
            Navigator.pop(context);
          },
        );
      },
    );
  }

  @override
Widget build(BuildContext context) {
  if (!isLocaleInitialized) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  return Scaffold(
    appBar: AppBar(
      title: const Text('Summary report'
      ),
    ),
    body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMonthSelector(),
                const SizedBox(height: 16),
                _buildSummaryCards(),
                const SizedBox(height: 16),
                _buildPieChart(),
                const SizedBox(height: 16),
                if (sortedCategories.isNotEmpty)
                  _buildExpenseChart()
                else
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: Text('ไม่มีข้อมูลค่าใช้จ่ายในเดือนนี้'),
                      ),
                    ),
                  ),
              ],
            ),
          ),
  );
}
}

class MonthYearPicker extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onChanged;

  const MonthYearPicker({
    Key? key,
    required this.selectedDate,
    required this.onChanged,
  }) : super(key: key);

  @override
  _MonthYearPickerState createState() => _MonthYearPickerState();
}

class _MonthYearPickerState extends State<MonthYearPicker> {
  late int _selectedYear;
  late int _selectedMonth;

  final List<String> _monthsInThai = [
    'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
    'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม'
  ];

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.selectedDate.year;
    _selectedMonth = widget.selectedDate.month;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() {
                    _selectedYear--;
                  });
                },
              ),
              Text(
                '$_selectedYear',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() {
                    _selectedYear++;
                  });
                },
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.5,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                final month = index + 1;
                final isSelected = month == _selectedMonth;
                
                return InkWell(
                  onTap: () {
                    widget.onChanged(DateTime(_selectedYear, month));
                  },
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isSelected ? Theme.of(context).primaryColor : null,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? Theme.of(context).primaryColor: Colors.grey,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _monthsInThai[index],
                        style: TextStyle(
                          color: isSelected ? Colors.white : null,
                          fontWeight: isSelected ? FontWeight.bold : null,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final now = DateTime.now();
              widget.onChanged(DateTime(now.year, now.month));
            },
            child: const Text('กลับไปเดือนปัจจุบัน'),
          ),
        ],
      ),
    );
  }
}