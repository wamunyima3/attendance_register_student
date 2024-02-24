import 'package:attendance_register_student/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Password extends StatefulWidget {
  const Password({Key? key}) : super(key: key);

  @override
  State<Password> createState() => _PasswordState();
}

class _PasswordState extends State<Password> {
  final _lecturerPassword = TextEditingController();
  final _lecturerEmail = TextEditingController();
  bool isLoading = false;
  bool _obscurePassword = true;
  bool _emailFieldFocused = false;
  bool _passwordFieldFocused = false;

  // Define a FocusNode for the password field
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    // Dispose the FocusNode when it's no longer needed
    _passwordFocusNode.dispose();
    super.dispose();
  }

  // Function to request focus on the password field
  void _requestFocusOnPassword() {
    FocusScope.of(context).requestFocus(_passwordFocusNode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _header(context),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: _inputField(context),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : () => _submit(context),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.blue,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text(
                          'Submit',
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: SpinKitChasingDots(
                  color: Colors.white, // Customize spinner color
                  size: 80.0, // Customize spinner size
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _header(context) {
    return const Column(
      children: [
        Text(
          "Welcome Back",
          style: TextStyle(
              fontSize: 40, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        Text("Request email and OTP from your lecturer",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            )),
      ],
    );
  }

  Widget _inputField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _lecturerEmail,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: "Email",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            errorText: _emailFieldFocused && !_isValidEmail(_lecturerEmail.text)
                ? 'Invalid email'
                : null,
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red),
              borderRadius: BorderRadius.circular(18),
            ),
            filled: true,
            fillColor: Colors.blue.withOpacity(0.1),
            prefixIcon: const Icon(
              Icons.email,
              color: Colors.blue,
            ),
          ),
          textInputAction: TextInputAction.next,
          onChanged: (_) {
            setState(() {
              _emailFieldFocused = true;
            });
          },
          onSubmitted: (_) {
            _requestFocusOnPassword(); // Request focus on password field
          },
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _lecturerPassword,
          focusNode:
              _passwordFocusNode, // Assign focus node to the password field
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            hintText: "OTP",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            errorText: _passwordFieldFocused &&
                    !_isValidPassword(_lecturerPassword.text)
                ? 'Invalid password'
                : null,
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red),
              borderRadius: BorderRadius.circular(18),
            ),
            fillColor: Colors.blue.withOpacity(0.1),
            filled: true,
            prefixIcon: const Icon(
              Icons.password,
              color: Colors.blue,
            ),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  color: _obscurePassword ? Colors.blue : Colors.green),
            ),
          ),
          textInputAction: TextInputAction.done,
          onChanged: (_) {
            setState(() {
              _passwordFieldFocused = true;
            });
          },
          onSubmitted: (_) {
            _submit(context); // Submit form
          },
        ),
      ],
    );
  }

  void _submit(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    FocusScope.of(context).unfocus();

    if (_lecturerEmail.text.isEmpty || _lecturerPassword.text.isEmpty) {
      scaffoldMessenger.showSnackBar(const SnackBar(
        content: Text(
          'Please fill in all fields',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ));
      return;
    }

    if (!_isValidEmail(_lecturerEmail.text)) {
      scaffoldMessenger.showSnackBar(const SnackBar(
        content: Text(
          'Please enter a valid email',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ));
      return;
    }

    if (!_isValidPassword(_lecturerPassword.text)) {
      scaffoldMessenger.showSnackBar(const SnackBar(
        content: Text(
          'Password must be at least 6 characters long',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ));
      return;
    }

    setState(() {
      isLoading = true;
    });

    final navigator = Navigator.of(context);

    try {
      final userId = await Supabase.instance.client
          .from('user')
          .select('id')
          .eq('email', _lecturerEmail.text)
          .single();

      final lecturerId = await Supabase.instance.client
          .from('lecturers')
          .select('id')
          .eq('user_id', userId['id'])
          .single();

      final response = await Supabase.instance.client
          .from('password')
          .select('password')
          .eq('lecturer_id', lecturerId['id']);

      if (response.isEmpty) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Request for password from your lecturer',
                style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
          ),
        );
      } else if (response[0]['password'] == _lecturerPassword.text) {
        navigator.pushReplacement(
          MaterialPageRoute(
            builder: (context) => LoginPage(lecturerId: lecturerId['id']),
          ),
        );
      } else {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Incorrect password',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (err) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Error fetching data',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  bool _isValidEmail(String email) {
    // Regular expression for email validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  bool _isValidPassword(String password) {
    // Password length validation
    return password.length >= 5;
  }
}
