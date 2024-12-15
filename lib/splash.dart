import 'package:attendance_register_student/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:attendance_register_student/main.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _restartApp();
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _redirect() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int storedSid = prefs.getInt('user_sid') ?? 0;

    if (storedSid != 0) {

      if (mounted) {
          _navigateToScannerScreen(storedSid);
        }
      } else {
        _navigateToLogin();
      }
  }

  void _navigateToScannerScreen(int sid) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ScannerScreen(sid: sid),
      ),
    );
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }

  void _restartApp() {
    // Restart the entire app
    WidgetsBinding.instance.addPostFrameCallback((_) async {
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
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.2,
                  child: const Image(
                    image: AssetImage(
                      'assets/attendance-logo.png',
                    ),
                  ),
                ),
              ),
              const SpinKitChasingDots(
                color: Colors.white,
                size: 80.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
