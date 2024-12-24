import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/alert_builder.dart';
import 'package:flutter_application/global_data.dart';
import 'package:flutter_application/main_screen.dart';
import 'package:flutter_application/signup_screen.dart';
import 'package:flutter_application/utils/constants/sizes.dart';
import 'package:flutter_application/utils/constants/text_strings.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:quickalert/quickalert.dart';
import 'dart:async';

class OTPScreen extends StatefulWidget {
  final String phoneNumber;
  final int userID;

  const OTPScreen({super.key, required this.phoneNumber, required this.userID});

  @override
  OTPScreenState createState() => OTPScreenState();
}

class OTPScreenState extends State<OTPScreen> {
  String _otpCode = '';
  bool _isOTPSent = false;
  int _countdown = 0;
  Timer? _timer;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.phoneNumber);
  }

  Future<void> _verifyOTP(BuildContext context) async {
    final url =
        Uri.https('lalpoolnetwork.net', '/api/v2/apps/otp_verification');

    try {
      AlertBuilder.showLoadingDialog(context);

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

      // ignore: use_build_context_synchronously
      AlertBuilder.hideLoadingDialog(context);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          GlobalData.userData = responseData['user'];
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
              MaterialPageRoute(
                builder: (context) => MainScreen(
                  onNavigateToPage: (int) {
                    return 1;
                  },
                ),
              ),
            );
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['errors']),
            ),
          );
        }
      } else {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        final snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Opps!',
            message: responseData['message'],
            contentType: ContentType.failure,
          ),
        );
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  Future<void> _resendOtp(BuildContext context) async {
    final url = Uri.https('lalpoolnetwork.net', '/api/v2/apps/otp_send');

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'user_id': widget.userID,
          'phone_number': _phoneController.text,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        final snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Yeah!',
            message: responseData['message'],
            contentType: ContentType.success,
          ),
        );
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);

        setState(() {
          _isOTPSent = true;
          _startCountdown();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Server error. Please try again later.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  void _startCountdown() {
    _countdown = 300; // 5 minutes countdown
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          _timer?.cancel();
          _isOTPSent = false;
        }
      });
    });
  }

  void _navigateToSignup() async {
    final url = Uri.https('lalpoolnetwork.net', '/api/v2/apps/delete_account', {
      'phone': _phoneController.text,
    });

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Assuming a successful response means account deletion is successful
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Existing Phone number Delete Successful')),
          );

          // Navigate to the SignUpScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const SignUpScreen(),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(responseData['message'] ?? 'Error occurred')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete account. Try again.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _phoneController.dispose();
    super.dispose();
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
                  bottom: MediaQuery.of(context).viewInsets.bottom +
                      TSizes.tDefaultSize,
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
                    const SizedBox(height: 10.0),
                    Text(
                      '${TTexts.tOtpMessage} ${widget.phoneNumber}\n',
                      textAlign: TextAlign.center,
                    ),
                    TextButton(
                      onPressed: _navigateToSignup,
                      child: const Text(
                        'Change Phone',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                    if (!_isOTPSent)
                      TextButton(
                        onPressed: () {
                          _resendOtp(context);
                        },
                        child: const Text(
                          'Resend OTP',
                          textAlign: TextAlign.center,
                        ),
                      )
                    else
                      Text(
                        'Resend OTP in $_countdown seconds',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    const SizedBox(height: 20.0),
                    Center(
                      child: OtpTextField(
                        alignment: Alignment.center,
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
                    ),
                    const SizedBox(height: 20.0),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_otpCode.isNotEmpty) {
                            _verifyOTP(context);
                          } else {
                            final snackBar = SnackBar(
                              elevation: 0,
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.transparent,
                              content: AwesomeSnackbarContent(
                                title: 'Opps!',
                                message: 'Please enter the OTP code.',
                                contentType: ContentType.failure,
                              ),
                            );
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(snackBar);
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
