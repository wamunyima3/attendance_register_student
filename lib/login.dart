import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:attendance_register_student/main.dart';
import 'package:attendance_register_student/register.dart';

class LoginPage extends StatefulWidget {
  final int lecturerId;
  const LoginPage({Key? key, required this.lecturerId}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  bool isLoading = false;
  bool _emailFieldFocused = false;

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
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Email',
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
                          Icons.email,
                          color: Colors.blue, // Icon color
                        ),
                        errorText: _emailFieldFocused &&
                                !_isValidEmail(_emailController.text)
                            ? 'Invalid email'
                            : null,
                      ),
                      onSubmitted: (_) => _login(),
                      onChanged: (_) {
                        setState(() {
                          _emailFieldFocused = true;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _login,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? ",
                          style: TextStyle(color: Colors.blue)), // Text color
                      TextButton(
                        onPressed: _navigateToRegistration,
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(color: Colors.blue),
                        ),
                      )
                    ],
                  ),
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
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter an email',
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

    final email = _emailController.text;

    try {
      final user = await Supabase.instance.client
          .from('user')
          .select('*')
          .eq('email', email)
          .single();

      if (user.isEmpty) {
        _showErrorSnackBar('Invalid Email');
        throw 'Invalid Email or Register';
      } else {
        _storeEmailInPreferences(email);
        _navigateToScannerScreen(email);
      }
    } catch (e) {
      _showErrorSnackBar('Error Signing in Check Credentials');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _storeEmailInPreferences(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('user_email', email);

    //update is logged in
    await Supabase.instance.client
        .from('user')
        .update({'is_loggedIn': true}).eq('email', email);
  }

  void _navigateToScannerScreen(String email) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ScannerScreen(email: email),
      ),
    );
  }

  void _navigateToRegistration() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => RegistrationPage(lecturerId: widget.lecturerId),
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

  bool _isValidEmail(String email) {
    // Regular expression for email validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
}
