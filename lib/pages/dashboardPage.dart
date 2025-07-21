import 'dart:io';
import 'dart:html' as html; // Import untuk Web
import 'dart:convert'; // Untuk encoding string ke byte
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import '../api_service.dart';
import 'dart:typed_data'; // For Uint8List
import 'package:flutter/foundation.dart' show kIsWeb; // For kIsWeb

class DashboardWidget extends StatefulWidget {
  final String userId;

  const DashboardWidget({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  _DashboardWidgetState createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  final ApiService _apiService = ApiService();
  double totalIncome = 0;
  double totalExpense = 0;
  bool isLoading = true;
  List<double> incomeHistory = [];
  List<double> expenseHistory = [];
  List<double> profitHistory = [];
  String activeLine =
      "all"; // Filter untuk menentukan garis mana yang akan ditampilkan

  // Variabel untuk menyimpan rentang tanggal yang dipilih
  String selectedDateRange = 'Hari Ini'; // Default ke "Semua"
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  // Fungsi untuk mengubah rentang tanggal berdasarkan pilihan
  void _updateDateRange(String range) {
  setState(() {
    selectedDateRange = range;
    if (range == '1 Minggu') {
      startDate = DateTime.now().subtract(Duration(days: 7));
      endDate = DateTime.now();
    } else if (range == '1 Bulan') {
      startDate = DateTime.now().subtract(Duration(days: 31));
      endDate = DateTime.now();
    } else if (range == 'Hari Ini') {
      startDate = DateTime.now();
      endDate = DateTime.now();
    } else {
      // Semua data
      startDate = DateTime(2024, 01, 01);
      endDate = DateTime.now();
    }
  });
}

  // Fungsi untuk mendownload CSV
  Future<void> downloadCSV(String csvData, String fileName) async {
    try {
      if (kIsWeb) {
        // For Web
        final blob = html.Blob([Uint8List.fromList(csvData.codeUnits)]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..target = 'blank'
          ..download = fileName;
        anchor.click();
        html.Url.revokeObjectUrl(url);
      } else {
        // For Mobile (Android/iOS)
        final directory = await getExternalStorageDirectory();
        final filePath = '${directory?.path}/$fileName';

        final file = File(filePath);
        await file.writeAsString(csvData);

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("File CSV berhasil diunduh!")));
        OpenFile.open(filePath);
      }
    } catch (e) {
      print('Error saving CSV file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Terjadi kesalahan saat menyimpan file.")));
    }
  }

  // Fungsi untuk mengunduh data (CSV atau Excel)
  Future<void> downloadData() async {
    try {
      final result = await _apiService.generateReport(
        userId: widget.userId,
        startDate: DateFormat('yyyy-MM-dd').format(startDate),
        endDate: DateFormat('yyyy-MM-dd').format(endDate),
        includeIncome: true,
        includeExpense: true,
        format: 'CSV', // Atau 'Excel'
      );

      print('API Response: $result');

      if (result['status'] == 'SUCCESS') {
        String csvData = result['csvData'];
        print('CSV Data: $csvData');
        await downloadCSV(csvData, 'report.csv');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to generate the report.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error downloading data: $e')));
    }
  }

  Future<void> loadDashboardData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final incomeData = await _apiService.fetchIncome(userId: widget.userId);
      final expenseData = await _apiService.fetchExpense(userId: widget.userId);

      if (incomeData is List && expenseData is List) {
        double incomeSum = 0;
        double expenseSum = 0;
        List<double> tempIncomeHistory = [];
        List<double> tempExpenseHistory = [];
        List<double> tempProfitHistory = [];

        if (incomeData.isNotEmpty) {
          for (var income in incomeData) {
            double amount = double.parse(income[5].toString());
            incomeSum += amount;
            tempIncomeHistory.add(amount);
          }
        }

        if (expenseData.isNotEmpty) {
          for (var expense in expenseData) {
            double amount = double.parse(expense[5].toString());
            expenseSum += amount;
            tempExpenseHistory.add(amount);
          }
        }

        for (int i = 0; i < tempIncomeHistory.length; i++) {
          double profit = (i < tempExpenseHistory.length
              ? tempIncomeHistory[i] - tempExpenseHistory[i]
              : tempIncomeHistory[i]);
          tempProfitHistory.add(profit);
        }

        setState(() {
          totalIncome = incomeSum;
          totalExpense = expenseSum;
          incomeHistory = tempIncomeHistory;
          expenseHistory = tempExpenseHistory;
          profitHistory = tempProfitHistory;
          isLoading = false;
        });
      } else {
        print(
            'Unexpected data format: incomeData: $incomeData, expenseData: $expenseData');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading dashboard data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      backgroundColor: Color(0xFFF0F4F8),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary View
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn(
                      icon: Icons.money_off,
                      iconColor: Colors.red,
                      label: 'Pengeluaran',
                      amount: totalExpense,
                      amountColor: Colors.red,
                      isSmallScreen: isSmallScreen,
                    ),
                    _buildStatColumn(
                      icon: Icons.attach_money,
                      iconColor: Colors.green,
                      label: 'Pendapatan',
                      amount: totalIncome,
                      amountColor: Colors.green,
                      isSmallScreen: isSmallScreen,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Keuntungan',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rp ${(totalIncome - totalExpense).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 22 : 24,
                          fontWeight: FontWeight.bold,
                          color: (totalIncome - totalExpense) >= 0
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Icon Row above Line Chart
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 24, color: Colors.blueGrey),
                    const SizedBox(height: 4),
                    Text('Tanggal',
                        style: TextStyle(
                            fontSize: 12, color: Colors.black54)),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      activeLine = "profit";
                    });
                  },
                  child: Column(
                    children: [
                      Icon(Icons.trending_up,
                          size: 24,
                          color: activeLine == "profit"
                              ? Colors.blue
                              : Colors.blueGrey),
                      const SizedBox(height: 4),
                      Text('Keuntungan',
                          style: TextStyle(
                              fontSize: 12, color: Colors.black54)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      activeLine = "income";
                    });
                  },
                  child: Column(
                    children: [
                      Icon(Icons.attach_money,
                          size: 24,
                          color: activeLine == "income"
                              ? Colors.green
                              : Colors.blueGrey),
                      const SizedBox(height: 4),
                      Text('Pendapatan',
                          style: TextStyle(
                              fontSize: 12, color: Colors.black54)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      activeLine = "expense";
                    });
                  },
                  child: Column(
                    children: [
                      Icon(Icons.money_off,
                          size: 24,
                          color: activeLine == "expense"
                              ? Colors.red
                              : Colors.blueGrey),
                      const SizedBox(height: 4),
                      Text('Pengeluaran',
                          style: TextStyle(
                              fontSize: 12, color: Colors.black54)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      activeLine = "all"; // Reset to show all lines
                    });
                  },
                  child: Column(
                    children: [
                      Icon(Icons.refresh,
                          size: 24,
                          color: activeLine == "all"
                              ? Colors.blue
                              : Colors.blueGrey),
                      const SizedBox(height: 4),
                      Text('Semua',
                          style: TextStyle(
                              fontSize: 12, color: Colors.black54)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Line Chart View
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: LineChart(
                  LineChartData(
                    minY: _calculateMinY(),
                    maxY: _calculateMaxY(),
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                            showTitles: true, reservedSize: 40),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            int dayIndex = value.toInt();
                            if (dayIndex >= 0 &&
                                dayIndex < incomeHistory.length) {
                              return Text('Hari ${dayIndex + 1}',
                                  style: TextStyle(fontSize: 12));
                            }
                            return Text('');
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.grey, width: 1)),
                    lineBarsData: [
                      if (activeLine == "income" || activeLine == "all")
                        LineChartBarData(
                          spots: incomeHistory
                              .asMap()
                              .entries
                              .map((e) =>
                              FlSpot(e.key.toDouble(), e.value))
                              .toList(),
                          isCurved: true,
                          color: Colors.green,
                          barWidth: 5,
                          belowBarData: BarAreaData(
                              show: true,
                              color: Colors.green.withOpacity(0.1)),
                          dotData: FlDotData(show: true),
                        ),
                      if (activeLine == "expense" || activeLine == "all")
                        LineChartBarData(
                          spots: expenseHistory
                              .asMap()
                              .entries
                              .map((e) =>
                              FlSpot(e.key.toDouble(), e.value))
                              .toList(),
                          isCurved: true,
                          color: Colors.red,
                          barWidth: 5,
                          belowBarData: BarAreaData(
                              show: true,
                              color: Colors.red.withOpacity(0.1)),
                          dotData: FlDotData(show: true),
                        ),
                      if (activeLine == "profit" || activeLine == "all")
                        LineChartBarData(
                          spots: profitHistory
                              .asMap()
                              .entries
                              .map((e) =>
                              FlSpot(e.key.toDouble(), e.value))
                              .toList(),
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 5,
                          belowBarData: BarAreaData(
                              show: true,
                              color: Colors.blue.withOpacity(0.1)),
                          dotData: FlDotData(show: true),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Rentang Tanggal di bawah tombol Unduh Data
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDateRangeButton('Hari Ini'),
                _buildDateRangeButton('1 Minggu'),
                _buildDateRangeButton('1 Bulan'),
                _buildDateRangeButton('Semua'),
              ],
            ),
            const SizedBox(height: 16),

            // Unduh Button
            Center(
              child: ElevatedButton(
                onPressed: downloadData,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 12),
                  backgroundColor: Color(0xFF007BFF),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text(
                  'Unduh Data',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Membuat tombol rentang tanggal
  Widget _buildDateRangeButton(String label) {
    return ElevatedButton(
      onPressed: () => _updateDateRange(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedDateRange == label ? Colors.blue : Colors.grey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(
        label,
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildStatColumn({
    required IconData icon,
    required Color iconColor,
    required String label,
    required double amount,
    required Color amountColor,
    required bool isSmallScreen,
  }) {
    return Column(
      children: [
        Icon(icon, size: isSmallScreen ? 28 : 32, color: iconColor),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
              fontSize: isSmallScreen ? 12 : 14, color: Colors.black54),
        ),
        const SizedBox(height: 4),
        Text(
          'Rp ${amount.toStringAsFixed(2)}',
          style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.bold,
              color: amountColor),
        ),
      ],
    );
  }

  double _calculateMinY() {
    double minProfit = profitHistory.isNotEmpty
        ? profitHistory.reduce((a, b) => a < b ? a : b)
        : 0;
    double minY = minProfit < 0
        ? minProfit - 10
        : 0; // Tambahkan padding jika ada nilai negatif
    return minY;
  }

  double _calculateMaxY() {
    double maxIncome = incomeHistory.isNotEmpty
        ? incomeHistory.reduce((a, b) => a > b ? a : b)
        : 100;
    double maxExpense = expenseHistory.isNotEmpty
        ? expenseHistory.reduce((a, b) => a > b ? a : b)
        : 100;
    double maxCombined =
    [maxIncome, maxExpense].reduce((a, b) => a > b ? a : b);
    double maxY = maxCombined + 10; // Tambahkan padding
    return maxY;
  }
}