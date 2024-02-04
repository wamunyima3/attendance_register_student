import 'package:attendance_register_student/main.dart';
import 'package:attendance_register_student/register.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VerifyOtpScreen extends StatefulWidget {
  VerifyOtpScreen({Key? key, required this.email}) : super(key: key);

  final String email;

  @override
  _VerifyOtpScreenState createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final _otpController = TextEditingController();
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
                    vertical: 16.0, horizontal: 24.0),
                child: TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter the 6-digit code',
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
                            final response =
                                await Supabase.instance.client.auth.verifyOTP(
                              email: widget.email,
                              token: _otpController.text,
                              type: OtpType.email,
                            );

                            final studentResponse = await Supabase.instance.client
                                .from('students')
                                .select('email')
                                .eq('email', widget.email);

                            if (studentResponse.isEmpty) {
                              navigator.pushReplacement(MaterialPageRoute(
                                  builder: (context) => RegistrationPage()));
                            } else {
                              final route = MaterialPageRoute(
                                  builder: (_) =>
                                      ScannerScreen(user: response.user!));
                              navigator.pushReplacement(route);
                            }
                          } catch (err) {
                            scaffoldMessenger.showSnackBar(SnackBar(
                                content: Text('Something went wrong $err')));
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
                      : const Text('Verify OTP'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}