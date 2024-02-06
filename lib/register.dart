import 'package:attendance_register_student/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Registration',
          style: TextStyle(color: Colors.blue),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                TextField(
                  controller: _studentIdController,
                  decoration: const InputDecoration(
                    labelText: 'Student ID',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _programController,
                  decoration: const InputDecoration(
                    labelText: 'Program BSE, BIT..',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width:
                      MediaQuery.of(context).size.width * 0.9, // Adjusted width
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _completeProfile,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.all(16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text('Complete Profile'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _completeProfile() async {
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
          .showSnackBar(SnackBar(content: Text('Something went wrong $err')));
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
}
