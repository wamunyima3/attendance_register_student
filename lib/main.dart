import 'package:attendance_register_student/location.dart';
import 'package:attendance_register_student/password.dart';
import 'package:attendance_register_student/splash.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
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
  final String email;

  const ScannerScreen({Key? key, required this.email}) : super(key: key);

  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? _controller;
  bool _firstScanDetected = false;

  void _logout() async {
    await Supabase.instance.client
        .from('user')
        .update({'is_logedIn': false}).eq('email', widget.email);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const Password()),
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
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Stack(
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
          );
        },
      ),
    );
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
          final user = await Supabase.instance.client
              .from('user')
              .select('id')
              .eq('email', widget.email)
              .single();

          final student = await Supabase.instance.client
              .from('students')
              .select('id')
              .eq('user_id', user['id'])
              .single();

          final studentLocation = await getLocation(context);

          print(
              'studentLocation: $studentLocation \n lecturerLocation: lat: ${double.parse(keys[3])} long: ${double.parse(keys[4])}\n');

          double distanceInMeters = Geolocator.distanceBetween(
              double.parse(keys[3]),
              double.parse(keys[4]),
              studentLocation['latitude'],
              studentLocation['longitude']);

          print(distanceInMeters);

          double requiredDistance = double.parse(keys[2]);

          if (distanceInMeters > requiredDistance) {
            _showMessageWidget(
                'You are not in class', Icons.face_retouching_off, Colors.red,
                () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ScannerScreen(email: widget.email),
                ),
              );
            });
          } else {
            List<Map<String, dynamic>> attendance = await Supabase
                .instance.client
                .from('attendances')
                .select('*')
                .eq('studentId', student['id'])
                .eq('registerId', keys[1])
                .eq('date', keys[0]);

            if (attendance.isEmpty) {
              await Supabase.instance.client.from('attendances').insert({
                'date': keys[0],
                'studentId': student['id'],
                'registerId': keys[1],
                'status': 'Present',
              });
              _showMessageWidget(
                  'Attendance Present', Icons.check, Colors.green, () {
                //exit app
                SystemNavigator.pop();
              });
            } else {
              _showMessageWidget(
                  'Already marked', Icons.tag_faces, Colors.green, () {
                //exit app
                SystemNavigator.pop();
              });
            }
          }
        } catch (e) {
          _showMessageWidget(
              'Error while marking attendance', Icons.info, Colors.red, () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ScannerScreen(email: widget.email),
              ),
            );
          });
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

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
