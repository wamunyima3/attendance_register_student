import 'dart:async';
import 'package:attendance_register_student/login.dart';
import 'package:attendance_register_student/main.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
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

  _loadWidget() {
    var _duration = Duration(seconds: splashDelay);
    return Timer(_duration, _redirect);
  }

  Future<void> _redirect() async {
    await Future.delayed(Duration.zero);
    if (!mounted) {
      return;
    }

    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: 
      (context)=>ScannerScreen(user: session.user)));
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: 
      (context)=>const LoginPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.4,
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