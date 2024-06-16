import 'package:flutter/material.dart';
import 'package:flutter_application/home_screen.dart';  // Make sure this import points to your home_screen.dart file
import 'package:flutter_application/utils/constants/sizes.dart';
import 'package:flutter_application/utils/constants/text_strings.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:quickalert/quickalert.dart';

class OTPScreen extends StatefulWidget {
  final String phoneNumber;
  final int userID;

  const OTPScreen({super.key, required this.phoneNumber, required this.userID});

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  String _otpCode = '';

  Future<void> _verifyOTP(BuildContext context) async {
    final url = Uri.parse('https://lalpoolnetwork.net/api/v2/apps/otp_verification');

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'user_id': widget.userID,
          'otp': _otpCode,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            text: 'Completed Registration!',
            autoCloseDuration: const Duration(seconds: 2),
            showConfirmBtn: false,
          );
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OTP verification failed. Please try again.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server error. Please try again later.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Padding(
                padding: const EdgeInsets.all(TSizes.tDefaultSize).copyWith(
                  bottom: MediaQuery.of(context).viewInsets.bottom + TSizes.tDefaultSize,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      TTexts.tOtpTitle,
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                        fontSize: 60.0,
                      ),
                    ),
                    Text(
                      TTexts.tOtpSubTitle.toUpperCase(),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 40.0),
                    Text(
                      '${TTexts.tOtpMessage} ${widget.phoneNumber}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20.0),
                    OtpTextField(
                      mainAxisAlignment: MainAxisAlignment.center,
                      numberOfFields: 6,
                      fillColor: Colors.black.withOpacity(0.1),
                      filled: true,
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      onSubmit: (code) {
                        setState(() {
                          _otpCode = code;
                        });
                      },
                    ),
                    const SizedBox(height: 20.0),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_otpCode.isNotEmpty) {
                            _verifyOTP(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter the OTP code.')),
                            );
                          }
                        },
                        child: const Text(TTexts.tNext),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}