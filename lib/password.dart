import 'package:attendance_register_student/login.dart';
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 24.0,
                ),
                child: TextField(
                  controller: _lecturerPassword,
                  obscureText: true, // Mask the password for security
                  decoration: const InputDecoration(
                    labelText: 'Lecturer\'s OTP',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 24.0,
                ),
                child: TextField(
                  controller: _lecturerEmail,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Lecturer\'s email',
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.87,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
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
                      : const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() async {
    setState(() {
      isLoading = true;
    });

    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final lecturerId = await Supabase.instance.client
          .from('lecturers')
          .select('id')
          .eq('email', _lecturerEmail.text)
          .single();
      final response = await Supabase.instance.client
          .from('password')
          .select('password')
          .eq('lecturer_id', lecturerId['id']);

      if (response.isEmpty) {
        scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text('Request for password from your lecturer'),
        ));
      } else if (response[0]['password'] == _lecturerPassword.text) {
        navigator.pushReplacement(
          MaterialPageRoute(
            builder: (context) => LoginPage(lecturerId: lecturerId['id']),
          ),
        );
      } else {
        scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text('Incorrect password'),
        ));
      }
    } catch (err) {
      scaffoldMessenger.showSnackBar(SnackBar(
        content: Text('Something went wrong $err'),
      ));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
