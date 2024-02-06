import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:attendance_register_student/main.dart';
import 'package:attendance_register_student/password.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final splashDelay = 3;

  @override
  void initState() {
    super.initState();
    _loadWidget();
  }

  _loadWidget() async {
    var duration = Duration(seconds: splashDelay);
    await Future.delayed(duration);
    if (mounted) {
      _checkInternetConnection();
    }
  }

  void _checkInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      // No internet connection
      _showOfflineWidget();
    } else {
      // Internet connection is present
      _redirect();
    }
  }

  void _showOfflineWidget() {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevents dismissing the dialog by tapping outside
      builder: (context) => AlertDialog(
        title: const Icon(
          Icons.wifi_off,
          size: 60,
          color: Colors.red,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'You are offline',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _restartApp();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _redirect() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storedEmail = prefs.getString('user_email') ?? 'No email';

    if (storedEmail != 'No email') {
      final user = await Supabase.instance.client
          .from('user')
          .select('is_logedIn')
          .eq('email', storedEmail)
          .single();

      if (user.isNotEmpty && user['is_logedIn'] == true) {
        if (mounted) {
          _navigateToScannerScreen(storedEmail);
        }
      } else {
        _navigateToPassword();
      }
    } else {
      _navigateToPassword();
    }
  }

  void _navigateToScannerScreen(String email) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ScannerScreen(email: email),
      ),
    );
  }

  void _navigateToPassword() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const Password(),
      ),
    );
  }

  void _restartApp() {
    // Restart the entire app
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      Navigator.of(context).pop(); // Dismiss the previous dialog, if any
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        _showOfflineWidget(); // Show offline dialog if still no internet after retry
      } else {
        _redirect(); // Redirect if internet connection is present
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.1,
                child: const Image(
                  image: AssetImage(
                    'assets/attendance-logo.png',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
