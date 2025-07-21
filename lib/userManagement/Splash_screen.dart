import 'dart:async';
import 'package:flutter/material.dart';
import 'login_page.dart'; // Import file login_page.dart

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();

    // Initialize the AnimationController and Animation
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    // Start the animation
    _controller.forward();

    // Simulate network request
    _simulateNetworkRequest();
  }

  // Simulate network request with progress updates
  void _simulateNetworkRequest() {
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_progress < 1.0) {
        setState(() {
          _progress += 0.05; // Increase the progress incrementally
        });
      } else {
        timer.cancel();
        // Navigate to the LoginPage after the "network request" is complete
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => LoginPage()),
              (route) => false,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Clean up the controller when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea( // Prevent content overflow by respecting safe areas
        child: Center(
          child: SingleChildScrollView( // Enable scrolling for smaller screens
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: "logo",
                  child: Image.asset(
                    'image/logofull.png', // Pastikan file ini ada di folder assets
                    height: 200, // Limit the size to prevent overflow
                  ),
                ),
                const SizedBox(height: 20), // Space between the logo and the progress bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50.0), // Adjust the left and right space
                  child: LinearProgressIndicator(
                    value: _progress, // Update the progress value
                    minHeight: 4, // Reduce the height of the progress bar
                    backgroundColor: Colors.white, // Background color of the progress bar
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue), // Color of the progress bar
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
