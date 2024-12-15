import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:attendance_register_student/main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _sidController = TextEditingController();
  bool isLoading = false;
  bool _sidFieldFocused = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    "Login",
                    style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: TextField(
                      controller: _sidController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Student ID',
                        hintStyle: const TextStyle(
                            color: Colors.black), // Hint text color
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(18), // Adjust radius
                          borderSide: BorderSide.none, // Remove border
                        ),
                        filled: true,
                        fillColor: Colors.blue.withOpacity(0.1),
                        labelStyle:
                            const TextStyle(color: Colors.blue), // Text color
                        prefixIcon: const Icon(
                          Icons.person,
                          color: Colors.blue, // Icon color
                        ),
                        errorText: _sidFieldFocused &&
                                !_isValidSid(_sidController.text)
                            ? 'Invalid id'
                            : null,
                      ),
                      onSubmitted: (_) => _login(),
                      onChanged: (_) {
                        setState(() {
                          _sidFieldFocused = true;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: ElevatedButton(
                      onPressed: !_isValidSid(_sidController.text)
                          ? null
                          : isLoading
                              ? null
                              : _login,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Login',
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.white)), // Text color and size
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: SpinKitChasingDots(
                  color: Colors.white,
                  size: 80.0,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _login() async {
    if (_sidController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enteryour student ID',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Dismiss the keyboard
    FocusScope.of(context).unfocus();

    setState(() {
      isLoading = true;
    });

    final sid = int.parse(_sidController.text);

    try {
      final user = await Supabase.instance.client
          .from('Student')
          .select('*')
          .eq('sid', sid);

      if (user.isEmpty) {
        _showErrorSnackBar('Not registered');
        throw 'You are not registered in any class, see you lecturer';
      } else {
        _storeSidInPreferences(sid);
        _navigateToScannerScreen(sid);
      }
    } catch (e) {
      _showErrorSnackBar('Error Signing in Check Credentials');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _storeSidInPreferences(int sid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('user_sid', sid);
  }

  void _navigateToScannerScreen(int sid) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ScannerScreen(sid: sid),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  bool _isValidSid(String sid) {
    final emailRegex = RegExp(r'^\d{7}$');
    return emailRegex.hasMatch(sid);
  }
}
