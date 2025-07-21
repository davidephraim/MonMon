import 'package:flutter/material.dart';
import 'package:expense_monitoring_v1/api_service.dart';
import 'package:input_quantity/input_quantity.dart';

class IncomeScreen extends StatefulWidget {
  final String userId;
  IncomeScreen({required this.userId});

  @override
  _IncomeScreenState createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  final ApiService apiService = ApiService();
  List<Map<String, dynamic>> incomeHistory = [];
  List<Map<String, dynamic>> incomeTypes = [];
  String selectedIncomeType = '';
  int quantity = 1;
  TextEditingController priceController = TextEditingController();
  TextEditingController incomeNameController = TextEditingController();
  List<Map<String, dynamic>> incomeData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchIncomeTypes();
    _fetchIncome();
  }

  Future<void> _fetchIncome() async {
    setState(() {
      isLoading = true;
    });
    final result = await apiService.fetchIncome(userId: widget.userId);
    setState(() {
      incomeData = [];
      for (var item in result) {
        if (item.length >= 2) {
          incomeData.add({
            'productsName': item[2],
            'quantity': item[3],
            'revenue': item[4],
          });
        }
      }
      // Urutkan berdasarkan item terakhir (index descending)
      incomeData.sort((a, b) => b['productsName'].compareTo(a['productsName']));
      isLoading = false;
    });
  }

  Future<void> _fetchIncomeTypes() async {
    try {
      final incomeTypesData = await apiService.getIncomeType();
      setState(() {
        incomeTypes = incomeTypesData
            .where((type) => type['incomeTypeName'] != 'IncomeTypeName')
            .map((type) => {
                  'incomeTypeName': type['incomeTypeName'],
                  'icon':
                      Icons.attach_money // Ganti dengan ikon sesuai kebutuhan
                })
            .toList();
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil tipe pemasukan')),
      );
    }
  }

  Future<void> _saveIncome() async {
    if (selectedIncomeType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pilih tipe pemasukan!')),
      );
      return;
    }

    final revenue = int.tryParse(priceController.text) ?? 0;
    if (revenue == 0 || quantity == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Masukkan harga dan kuantitas yang valid')),
      );
      return;
    }

    try {
      await apiService.addIncome(
        action: 'addIncome',
        dateTime: DateTime.now().toIso8601String(),
        transactionId: DateTime.now().millisecondsSinceEpoch.toString(),
        productsName: incomeNameController.text,
        qtyProducts: quantity.toString(),
        revenue: revenue,
        userId: widget.userId,
        incomeId: selectedIncomeType,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pemasukan berhasil disimpan!')),
      );
      _fetchIncome();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan pemasukan')),
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
                  // Income Type Icons
                  Text('Pilih Tipe Pemasukan',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 35),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment
                          .spaceBetween, // Tambahkan jarak antar ikon
                      children: incomeTypes.asMap().entries.map((entry) {
                        int index = entry.key;
                        var type = entry.value;

                        // Ganti ikon kedua menjadi makanan
                        IconData icon =
                            index == 1 ? Icons.fastfood : Icons.attach_money;

                        final isSelected =
                            selectedIncomeType == type['incomeTypeName'];

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedIncomeType = type['incomeTypeName'];
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
                                  type['incomeTypeName'],
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

                  // Income Name Input
                  Text('Nama Pemasukan (Opsional)',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextField(
                    controller: incomeNameController,
                    decoration: InputDecoration(
                      hintText: 'Masukkan nama pemasukan',
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
                            Text(
                              'Harga',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
                            Text(
                              'Jumlah',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
                    onPressed: _saveIncome,
                    child: Text('Simpan'),
                  ),
                  SizedBox(height: 24),

                  // Income History
                  Text('Riwayat Pemasukan',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: ListView.builder(
                      itemCount: incomeData.length,
                      itemBuilder: (context, index) {
                        final income = incomeData[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(income['productsName']),
                            subtitle: Text(
                                'Harga: Rp ${income['revenue']}, Jumlah: ${income['quantity']}'),
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
