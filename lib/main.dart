import 'dart:convert';

import 'package:attendance_register_student/location.dart';
import 'package:attendance_register_student/login.dart';
import 'package:attendance_register_student/splash.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://zirchqxedoeibjhntomb.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InppcmNocXhlZG9laWJqaG50b21iIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDU5NTMwMjAsImV4cCI6MjAyMTUyOTAyMH0.-GeclxYt7ikR-2-baUXEj9cVktVmYtMQk76aJY-GW0Y',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
    );
  }
}

class ScannerScreen extends StatefulWidget {
  final int sid;

  const ScannerScreen({Key? key, required this.sid}) : super(key: key);

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  MobileScannerController _controller = MobileScannerController();
  bool _firstScanDetected = false;

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'About',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.blue, // Match the color
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: 'Attendance Register\n',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  children: <TextSpan>[
                    const TextSpan(
                      text: 'Version: 1.0.0\n\n',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const TextSpan(
                      text: 'Developed By:\n',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const TextSpan(
                      text: 'Dr. Siva Asani\n',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    TextSpan(
                      text: 'Wamunyima Mukelabai',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          _launchURL('https://portfolio-wamunyima.vercel.app');
                        },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Mark your attendance by just scanning',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14, // Adjust the font size as needed
                  color: Colors.black, // Adjust the text color as needed
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Close',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue, // Match the color
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _launchURL(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Attendance Register',
          style: TextStyle(color: Colors.blue),
        ),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(
              Icons.logout,
              color: Colors.blue,
            ),
          ),
          IconButton(
            onPressed: () {
              _showAboutDialog(context);
            },
            icon: const Icon(Icons.info, color: Colors.blue),
          )
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          Positioned(
            top: 40.0,
            left: 16.0,
            right: 16.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.flip_camera_android),
                  onPressed: () => _controller.switchCamera(),
                  color: Colors.white,
                ),
                IconButton(
                  icon: const Icon(Icons.flash_on),
                  onPressed: () => _controller.toggleTorch(),
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) async {
    if (!_firstScanDetected) {
      _firstScanDetected = true;
      final List<Barcode> barcodes = capture.barcodes;
      for (final barcode in barcodes) {
        if (barcode.rawValue != null) {
          await _processQRCode(barcode.rawValue!);
        }
      }
    }
  }

  Future<void> _processQRCode(String qrData) async {
    _controller.stop();

    try {
      // Parse the JSON string
      Map<String, dynamic> jsonMap = jsonDecode(qrData);

        var date = await Supabase.instance.client
          .from('ClassDate')
          .select('*')
          .eq('date', jsonMap['date'])
          .eq('cid', jsonMap['classId']);

        if(date.isEmpty){
          date = await Supabase.instance.client.from('ClassDate').insert({
            'date': jsonMap['date'],
            'cid': jsonMap['classId'],
          }).select();
        }

        final attendance = await Supabase.instance.client
          .from('Attendance')
          .select('sid,Student(name)')
          .eq('sid', widget.sid)
          .eq('did', date[0]['id'])
          .eq('cid', jsonMap['classId']);

      if (attendance.isEmpty) {
        await Supabase.instance.client.from('Attendance').insert({
          'did': date[0]['id'],
          'sid': widget.sid,
          'cid': jsonMap['classId'],
          'status': 'present',
          'comment':'Marked from phone'
        });
        _showMessageWidget('Attendance Present', Icons.check, Colors.green, () {
          SystemNavigator.pop();
        });
      } else {
        _showMessageWidget('Already marked', Icons.tag_faces, Colors.green, () {
          SystemNavigator.pop();
        });
      }
    } catch (e) {
      print("Error while marking attendance $e");
      _showMessageWidget(
          'Error while marking attendance', Icons.info, Colors.red, () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ScannerScreen(sid: widget.sid),
          ),
        );
      });
    }
  }

  void _showMessageWidget(
    String message,
    var messageIcon,
    var messageIconColor,
    Function action,
  ) {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevents dismissing the dialog by tapping outside
      builder: (context) => AlertDialog(
        title: Icon(
          messageIcon,
          size: 60,
          color: messageIconColor,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                action(); // Invoke the function here
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
                'Done',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
