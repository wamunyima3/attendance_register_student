import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:attendance_register_student/main.dart';
import 'package:attendance_register_student/register.dart';

class VerifyOtpScreen extends StatefulWidget {
  final int lecturerId;
  final String email;

  const VerifyOtpScreen({
    Key? key,
    required this.email,
    required this.lecturerId,
  }) : super(key: key);

  @override
  _VerifyOtpScreenState createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final _otpController = TextEditingController();
  bool isLoading = false;
  int countdown = 86400;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    startCountdownTimer();
  }

  void startCountdownTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        if (countdown > 0) {
          countdown--;
        } else {
          // If the countdown reaches zero, stop the timer
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter the 6-digit code',
                ),
              ),
              const SizedBox(height: 16.0),
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

                            final studentResponse = await Supabase
                                .instance.client
                                .from('students')
                                .select('email')
                                .eq('email', widget.email);

                            if (studentResponse.isEmpty) {
                              navigator.pushReplacement(MaterialPageRoute(
                                  builder: (context) => RegistrationPage(
                                      lecturerId: widget.lecturerId)));
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
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text('Verify OTP'),
                ),
              ),
              const SizedBox(height: 16.0),
              Center(
                child: Text(
                  'Resend OTP in ${countdown % 60} seconds',
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          // Reset the countdown timer
                          setState(() {
                            countdown = 86400;
                          });

                          await Supabase.instance.client.auth.resend(
                            type: OtpType.email,
                            email: widget.email,
                          );

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  'OTP has been resent to ${widget.email}'),
                            ));
                          }
                        },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: const Text('Resend OTP'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
