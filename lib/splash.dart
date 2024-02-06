import 'dart:async';
import 'package:attendance_register_student/main.dart';
import 'package:attendance_register_student/password.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

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
      _redirect();
    }
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
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ScannerScreen(email: email),
      ),
    );
  }

  void _navigateToPassword() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const Password(),
      ),
    );
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
