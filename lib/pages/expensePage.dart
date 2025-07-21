import 'package:flutter/material.dart';
import 'package:expense_monitoring_v1/api_service.dart';
import 'package:input_quantity/input_quantity.dart';

class ExpenseScreen extends StatefulWidget {
  final String userId;
  ExpenseScreen({required this.userId});

  @override
  _ExpenseScreenState createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final ApiService apiService = ApiService();
  List<Map<String, dynamic>> expenseHistory = [];
  List<Map<String, dynamic>> expenseTypes = [];
  String selectedExpenseType = '';
  int quantity = 1;
  TextEditingController priceController = TextEditingController();
  TextEditingController expenseNameController = TextEditingController();
  List<Map<String, dynamic>> expenseData = [];
  bool isLoading = true;

  @override
  void initState() {
    print('User ID di ExpenseScreen: ${widget.userId}');

    super.initState();
    _fetchExpenseTypes();
    _fetchExpense();
  }

  Future<void> _fetchExpense() async {
    print('User ID di ExpenseScreen: ${widget.userId}');

    setState(() {
      isLoading = true;
    });
    final result = await apiService.fetchExpense(userId: widget.userId);
    setState(() {
      expenseData = [];
      for (var item in result) {
        if (item.length >= 2) {
          expenseData.add({
            'expenseName': item[2],
            'quantity': item[3],
            'expenseAmount': item[4],
          });
        }
      }
      expenseData.sort((a, b) =>
          b['expenseName'].compareTo(a['expenseName'])); // Sort descending
      isLoading = false;
    });
  }

  Future<void> _fetchExpenseTypes() async {
    try {
      final expenseTypesData = await apiService.getExpenseType();
      setState(() {
        expenseTypes = expenseTypesData
            .map((type) => {
                  'expenseTypeName': type['expenseTypeName'],
                  'icon': Icons.money_off
                })
            .toList();
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil tipe pengeluaran')),
      );
    }
  }

  Future<void> _saveExpense() async {
    print('User ID before send: ${widget.userId}');

    if (selectedExpenseType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pilih tipe pengeluaran!')),
      );
      return;
    }

    final expenseAmount = int.tryParse(priceController.text) ?? 0;
    if (expenseAmount == 0 || quantity == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Masukkan harga dan kuantitas yang valid')),
      );
      return;
    }
    print('Payload yang dikirim:');
    print({
      'action': 'addExpense',
      'dateTime': DateTime.now().toIso8601String(),
      'transactionId': DateTime.now().millisecondsSinceEpoch.toString(),
      'expenseName': expenseNameController.text,
      'qtyProducts': quantity.toString(),
      'expenseAmounts': expenseAmount,
      'userId': widget.userId,
      'expenseId': selectedExpenseType,
    });

    try {
      await apiService.addExpense(
        action: 'addExpense',
        dateTime: DateTime.now().toIso8601String(),
        transactionId: DateTime.now().millisecondsSinceEpoch.toString(),
        expenseName: expenseNameController.text,
        qtyProducts: quantity.toString(),
        expenseAmounts: expenseAmount,
        userId: widget.userId,
        expenseId: selectedExpenseType,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pengeluaran berhasil disimpan!')),
      );
      _fetchExpense();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan pengeluaran')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Expense Type Icons (similar to Expense)
                  Text('Pilih Tipe Pengeluaran',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 35),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: expenseTypes
                          .skip(
                              1) // Menghilangkan elemen pertama ("ExpenseTypeName")
                          .toList() // Mengonversi Iterable ke List
                          .asMap()
                          .entries
                          .map((entry) {
                        int index = entry.key;
                        var type = entry.value;

                        // Menentukan ikon menggunakan ternary operator
                        IconData icon = index == 0
                            ? Icons.fastfood // Makan
                            : index == 1
                                ? Icons.directions_car // Transportasi
                                : index == 2
                                    ? Icons.grass // Bahan Mentah
                                    : index == 3
                                        ? Icons.inventory // Kemasan
                                        : index == 4
                                            ? Icons.build // Biaya Pengolahan
                                            : index == 5
                                                ? Icons.person // Gaji
                                                : Icons
                                                    .money_off; // Ikon default

                        final isSelected =
                            selectedExpenseType == type['expenseTypeName'];

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedExpenseType = type['expenseTypeName'];
                              });
                            },
                            child: Column(
                              children: [
                                CircleAvatar(
                                  backgroundColor: isSelected
                                      ? Colors.blue
                                      : Colors.grey[200],
                                  child: Icon(icon,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  type['expenseTypeName'] ?? '',
                                  style: TextStyle(
                                    color:
                                        isSelected ? Colors.blue : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  SizedBox(height: 35),

                  // Expense Name Input
                  Text('Nama Pengeluaran (Opsional)',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextField(
                    controller: expenseNameController,
                    decoration: InputDecoration(
                      hintText: 'Masukkan nama pengeluaran',
                    ),
                  ),
                  SizedBox(height: 35),

                  // Price and Quantity Inputs
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Harga',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            TextField(
                              controller: priceController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'Masukan harga dalam Rupiah',
                                prefixText: 'Rp ',
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Jumlah',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            InputQty(
                              initVal: 1,
                              minVal: 1,
                              steps: 1,
                              onQtyChanged: (val) {
                                quantity = val;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 35),
                  ElevatedButton(
                    onPressed: _saveExpense,
                    child: Text('Simpan'),
                  ),
                  SizedBox(height: 24),

                  // Expense History
                  Text('Riwayat Pengeluaran',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: ListView.builder(
                      itemCount: expenseData.length,
                      itemBuilder: (context, index) {
                        final expense = expenseData[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(expense['expenseName']),
                            subtitle: Text(
                                'Harga: Rp ${expense['expenseAmount']}, Jumlah: ${expense['quantity']}'),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
