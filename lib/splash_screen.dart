import 'dart:convert';
import 'package:all_platform_device_id/all_platform_device_id.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/global_data.dart';
import 'package:flutter_application/main_screen.dart';
import 'package:flutter_application/otp_screen.dart';
import 'package:flutter_application/utils/constants/image_strings.dart';
import 'package:flutter_application/welcome_screen.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  String? deviceKey;
  bool isVerified = false;

  @override
  void initState() {
    super.initState();
    _initializeDeviceInfo();
  }

  Future<void> _initializeDeviceInfo() async {
    String? deviceId;
    try {
      deviceId = await PlatformDeviceId.getDeviceId;

      if (deviceId != null) {
        setState(() {
          deviceKey = deviceId;
        });
        if (kDebugMode) {
          print(deviceKey);
        }
        verifyUser(deviceKey!);
      } else {
        setState(() {
          deviceKey = 'Failed to get device ID';
        });
      }
    } catch (e) {
      setState(() {
        deviceKey = 'Failed to get device ID';
      });
    }
  }

  Future<void> verifyUser(String deviceKey) async {
    var url = Uri.http('lalpoolnetwork.net', '/api/v2/apps/check_user');
    try {
      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'POST, GET, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization',
        },
        body: jsonEncode(<String, String>{
          'device_key': deviceKey,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          GlobalData.userData = responseData['user'];
          final String phoneNumber = responseData['user']['phone'];
          final int userID = responseData['user']['id'];
          setState(() {
            isVerified = true;
          });
        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
            builder: (context) => responseData['user']['status'] == 1
              // ignore: avoid_types_as_parameter_names
              ?  MainScreen(onNavigateToPage: (int ) { return 1; },)
              :  OTPScreen(phoneNumber: phoneNumber, userID: userID),
          ),
        );
               
           
          if (kDebugMode) {
            print(responseData['user']['status']);
          }
        } else {
          setState(() {
            isVerified = false;
          });
          Navigator.pushReplacement(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(
              builder: (context) => const WelcomeScreen(),
            ),
          );
          if (kDebugMode) {
            print('User verification failed.');
          }
        }
      } else {
        setState(() {
          isVerified = false;
        });
        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
            builder: (context) => const WelcomeScreen(),
          ),
        );
        if (kDebugMode) {
          print('Request failed with status: ${response.statusCode}.');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error verifying user: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Customize the background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              TImages.darkAppLogo,
              width: 150,
              height: 150,
            ), // Ensure this path matches your splash image path
            const SizedBox(height: 20),
            SizedBox(
              height: 100,
              width: double.infinity,
              child: Lottie.asset(
                'assets/logos/loading.json',
                repeat: false, // Set repeat to false to play only once
              ),
            ),
          ],
        ),
      ),
    );
  }
}
