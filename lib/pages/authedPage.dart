import 'package:flutter/material.dart';
import 'package:expense_monitoring_v1/pages/expensePage.dart';
import 'package:expense_monitoring_v1/pages/dashboardPage.dart';
import 'package:expense_monitoring_v1/pages/incomePage.dart';
import 'package:expense_monitoring_v1/pages/profilePage.dart';

class AuthedPage extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> userData;

  AuthedPage({required this.userId, required this.userData});

  @override
  _AuthedPageState createState() => _AuthedPageState();
}

class _AuthedPageState extends State<AuthedPage> {
  int _selectedIndex = 1; // Default to Dashboard

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      ExpenseScreen(userId: widget.userId),
      DashboardWidget(userId: widget.userId), // Ensure the constructor matches the definition
      IncomeScreen(userId: widget.userId),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Define app bar titles and colors for each page
    final appBarTitles = ['Pengeluaran', 'Dasbor', 'Pendapatan'];
    final appBarColors = [
      Colors.redAccent,
      Colors.blueAccent,
      Color(0xFF3DD598)
    ];

    // Define center titles for each page
    final centerTitles = ['Pengeluaran', '', 'Pendapatan'];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${appBarTitles[_selectedIndex]}${appBarTitles[_selectedIndex] != 'Dasbor' ? ' ${widget.userId}' : ''}',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: appBarColors[_selectedIndex],
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              // Navigate to ProfilePage when the button is pressed
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(
                    userId: widget.userId,
                    userData: widget.userData,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Conditionally display center title based on selected page
          if (_selectedIndex == 0 || _selectedIndex == 2)
            Container(
              color: appBarColors[_selectedIndex],
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  centerTitles[_selectedIndex],
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(
                        blurRadius: 3.0,
                        color: Colors.black54,
                        offset: Offset(1.5, 1.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: _pages[_selectedIndex],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.money_off),
            label: 'Pengeluaran',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Dasbor',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Pendapatan',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        selectedFontSize: 16,
        unselectedFontSize: 14,
      ),
    );
  }
}