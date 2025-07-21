import 'package:expense_monitoring_v1/userManagement/Splash_screen.dart';
import 'package:flutter/material.dart';
// import 'package:expense_monitoring_v1/userManagement/login_page.dart';
void main() {
  runApp(ExpenseMonitoringApp());
}

class ExpenseMonitoringApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Monitoring',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
      // home: AuthedPage(userId: 'userId')
    );
  }
}
