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

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: ScannerScreen(),
    );
  }
}

class ScannerScreen extends StatefulWidget {
  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? _controller;
  TextEditingController studentIdController = TextEditingController();
  bool _firstScanDetected = false;
  bool _showTextField = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance Register'),
      ),
      body: Column(
        children: [
          if (_showTextField)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: studentIdController,
                decoration: InputDecoration(labelText: 'Student ID'),
              ),
            ),
          Expanded(
            child: Stack(
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
                        icon: Icon(Icons.flip_camera_android),
                        onPressed: _flipCamera,
                        color: Colors.white,
                      ),
                      IconButton(
                        icon: Icon(Icons.flash_on),
                        onPressed: _toggleFlash,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_showTextField)
            ElevatedButton(
              onPressed: _submitAttendance,
              child: Text('Submit'),
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
              .eq('studentId', studentIdController.text);

          print(student[0]['id']);

          await Supabase.instance.client.from('attendances').insert({
            'date': keys[0],
            'studentId': student[0]['id'],
            'courseId': keys[1],
            'registerId': keys[2],
            'status': 'Present'
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

  void _submitAttendance() {
    setState(() {
      _showTextField = false;
    });
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
