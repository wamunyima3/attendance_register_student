import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:attendance_register_student/main.dart';
import 'package:attendance_register_student/login.dart';

class RegistrationPage extends StatefulWidget {
  final int lecturerId;

  const RegistrationPage({Key? key, required this.lecturerId})
      : super(key: key);

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _programController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool isLoading = false;

  // Define FocusNodes for each text field
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _programFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _studentIdFocusNode = FocusNode();

  @override
  void dispose() {
    // Dispose the FocusNodes when they're no longer needed
    _emailFocusNode.dispose();
    _programFocusNode.dispose();
    _phoneFocusNode.dispose();
    _nameFocusNode.dispose();
    _studentIdFocusNode.dispose();
    super.dispose();
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
                    _header(),
                    const SizedBox(height: 16),
                    _inputField(context),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _completeProfile,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.blue,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text(
                          'Register',
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text(
                          "Already have an account?",
                          style: TextStyle(color: Colors.blue),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => LoginPage(
                                  lecturerId: widget.lecturerId,
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            "Login",
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
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
                  color: Colors.white,
                  size: 80.0,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _header() {
    return const Column(
      children: [
        Text(
          "Register",
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _inputField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          focusNode: _emailFocusNode,
          decoration: InputDecoration(
            hintText: "Email",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            errorText: _emailFocusNode.hasFocus &&
                    !_isValidEmail(_emailController.text)
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
            setState(() {}); // Rebuild to show/hide error message
          },
          onSubmitted: (_) {
            FocusScope.of(context).requestFocus(_programFocusNode);
          },
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _programController,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          focusNode: _programFocusNode,
          decoration: InputDecoration(
            hintText: "Program",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.blue.withOpacity(0.1),
            errorText:
                _programFocusNode.hasFocus && _programController.text.isEmpty
                    ? 'Program cannot be empty'
                    : null,
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red),
              borderRadius: BorderRadius.circular(18),
            ),
            prefixIcon: const Icon(
              Icons.school,
              color: Colors.blue,
            ),
          ),
          textInputAction: TextInputAction.next,
          onChanged: (_) {
            setState(() {});
          },
          onSubmitted: (_) {
            FocusScope.of(context).requestFocus(_phoneFocusNode);
          },
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          focusNode: _phoneFocusNode,
          decoration: InputDecoration(
            hintText: "Phone",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.blue.withOpacity(0.1),
            errorText: _phoneFocusNode.hasFocus &&
                    !_isValidPhoneNumber(_phoneController.text)
                ? 'Invalid phone number'
                : null,
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red),
              borderRadius: BorderRadius.circular(18),
            ),
            prefixIcon: const Icon(
              Icons.phone,
              color: Colors.blue,
            ),
          ),
          textInputAction: TextInputAction.next,
          onChanged: (_) {
            setState(() {});
          },
          onSubmitted: (_) {
            FocusScope.of(context).requestFocus(_nameFocusNode);
          },
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _nameController,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          focusNode: _nameFocusNode,
          decoration: InputDecoration(
            hintText: "Name",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.blue.withOpacity(0.1),
            errorText: _nameFocusNode.hasFocus && _nameController.text.isEmpty
                ? 'Name cannot be empty'
                : null,
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red),
              borderRadius: BorderRadius.circular(18),
            ),
            prefixIcon: const Icon(
              Icons.person_outline,
              color: Colors.blue,
            ),
          ),
          textInputAction: TextInputAction.next,
          onChanged: (_) {
            setState(() {});
          },
          onSubmitted: (_) {
            FocusScope.of(context).requestFocus(_studentIdFocusNode);
          },
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _studentIdController,
          focusNode: _studentIdFocusNode,
          decoration: InputDecoration(
            hintText: "Student ID",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.blue.withOpacity(0.1),
            errorText: _studentIdFocusNode.hasFocus &&
                    _studentIdController.text.isEmpty
                ? 'Student ID cannot be empty'
                : null,
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red),
              borderRadius: BorderRadius.circular(18),
            ),
            prefixIcon: const Icon(
              Icons.person,
              color: Colors.blue,
            ),
          ),
          textInputAction: TextInputAction.done,
          onChanged: (_) {
            setState(() {});
          },
          onSubmitted: (_) {
            _completeProfile();
          },
        ),
      ],
    );
  }

  void _completeProfile() async {
    FocusScope.of(context).unfocus();

    // Validate all fields
    if (!_isValidEmail(_emailController.text) ||
        _programController.text.isEmpty ||
        !_isValidPhoneNumber(_phoneController.text) ||
        _nameController.text.isEmpty ||
        _studentIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill in all fields correctly',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    setState(() {
      isLoading = true;
    });

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final response = await Supabase.instance.client
          .from('programs')
          .select('id')
          .eq('name', _programController.text);

      int programId = 0;

      final courseId = await Supabase.instance.client
          .from('courses')
          .select('id')
          .eq('lecturerId', widget.lecturerId)
          .single();

      if (response.isEmpty) {
        var newProgram =
            await Supabase.instance.client.from('programs').insert({
          'name': _programController.text,
          'course_id': courseId['id'],
        }).select();

        programId = newProgram[0]['id'];
      } else {
        programId = response[0]['id'];
      }

      _storeUserEmail();
      await _insertIntoStudents(programId);

      if (mounted) {
        _navigateToScannerScreen(_emailController.text);
      }
    } catch (err) {
      scaffoldMessenger
          .showSnackBar(const SnackBar(content: Text('Registration Failed')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _storeUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('user_email', _emailController.text);
  }

  Future<void> _insertIntoStudents(int programId) async {
    final user = await Supabase.instance.client
        .from('user')
        .insert({
          'is_logedIn': true,
          'email': _emailController.text,
        })
        .select()
        .single();

    await Supabase.instance.client.from('students').insert({
      'studentId': _studentIdController.text,
      'name': _nameController.text,
      'user_id': user['id'],
      'phone': _phoneController.text,
      'program_id': programId,
    });
  }

  void _navigateToScannerScreen(String email) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ScannerScreen(email: email),
      ),
    );
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  bool _isValidPhoneNumber(String phoneNumber) {
    // Perform phone number validation as needed
    return phoneNumber.length == 10; // Just an example validation
  }
}
