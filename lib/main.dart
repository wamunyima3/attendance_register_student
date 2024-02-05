import 'package:attendance_register_student/password.dart';
import 'package:attendance_register_student/splash.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  final User user;

  const ScannerScreen({Key? key, required this.user}) : super(key: key);

  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? _controller;
  bool _firstScanDetected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Register'),
        actions: [
          IconButton(
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const Password()),
                );
              }
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: Stack(
        children: <Widget>[
          QRView(
            key: _qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderRadius: 10,
              borderLength: 20,
              borderWidth: 10,
              cutOutSize: MediaQuery.of(context).size.width * 0.8,
            ),
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
                  onPressed: _flipCamera,
                  color: Colors.white,
                ),
                IconButton(
                  icon: const Icon(Icons.flash_on),
                  onPressed: _toggleFlash,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      _controller = controller;
    });

    _controller!.scannedDataStream.listen((scanData) async {
      if (!_firstScanDetected) {
        _firstScanDetected = true;
        _controller?.pauseCamera();

        try {
          List<String> keys = scanData.code!.split('\n');
          final student = await Supabase.instance.client
              .from('students')
              .select('id')
              .eq('email', '${widget.user.email}')
              .single();

          await Supabase.instance.client.from('attendances').insert({
            'date': keys[0],
            'studentId': student['id'],
            'registerId': keys[1],
            'status': 'Present',
          });

          _showSnackbar('Attendance Present');
        } catch (e) {
          print('Error while inserting data: $e');
          _showSnackbar('Error while inserting data: $e');
        }
      }
    });
  }

  void _flipCamera() {
    if (_controller != null) {
      _controller!.flipCamera();
    }
  }

  void _toggleFlash() {
    if (_controller != null) {
      _controller!.toggleFlash();
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
