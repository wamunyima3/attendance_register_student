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
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Lecturer\'s OTP',
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
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          setState(() {
                            isLoading = true;
                          });

                          final navigator = Navigator.of(context);
                          final scaffoldMessenger =
                              ScaffoldMessenger.of(context);

                          try {
                            // Get the lecturer's password

                            final lecturerId = await Supabase.instance.client
                                .from('lecturers')
                                .select('id')
                                .eq('email', _lecturerEmail.text)
                                .single();

                            final response = await Supabase.instance.client
                                .from('password')
                                .select('password')
                                .eq('lecturer_id', lecturerId['id']);

                            print(response[0]['password']);

                            // If it's correct, open the login page
                            if (response.isEmpty) {
                              scaffoldMessenger.showSnackBar(const SnackBar(
                                content: Text(
                                    'Request for password from your lecturer'),
                              ));
                            } else if (response[0]['password'] == _lecturerPassword.text) {
                              navigator.pushReplacement(MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ));
                            } else {
                              scaffoldMessenger.showSnackBar(const SnackBar(
                                content: Text('Incorrect password'),
                              ));
                            }
                          } catch (err) {
                            print('Error: $err');
                            scaffoldMessenger.showSnackBar(SnackBar(
                              content: Text('Something went wrong $err'),
                            ));
                          } finally {
                            setState(() {
                              isLoading = false;
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16.0),
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
}
