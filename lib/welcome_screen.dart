import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/home_screen.dart';
import 'package:flutter_application/singup_screen.dart';
import 'package:http/http.dart' as http;
import 'package:android_id/android_id.dart';
import 'package:flutter_application/utils/constants/colors.dart';
import 'package:flutter_application/utils/constants/image_strings.dart';
import 'package:flutter_application/utils/constants/sizes.dart';
import 'package:flutter_application/utils/constants/text_strings.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  WelcomeScreenState createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen> {
  String? deviceKey;
  bool isVerified = false;

  @override
  void initState() {
    super.initState();
    _initializeDeviceInfo();
  }

  Future<void> _initializeDeviceInfo() async {
    const androidIdPlugin = AndroidId();
    String? deviceId;
    try {
      if (Platform.isAndroid) {
        deviceId = await androidIdPlugin.getId(); // Unique ID on Android
      } else {
        deviceId = 'Unsupported platform';
      }
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
    var url = Uri.https('lalpoolnetwork.net', '/api/v2/apps/check_user');
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
          setState(() {
            isVerified = true;
          });
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(userData: responseData['user']),
            ),
          );
          if (kDebugMode) {
            print(responseData['success']);
          }
        } else {
          setState(() {
            isVerified = false;
          });
          if (kDebugMode) {
            print('User verification failed.');
          }
        }
      } else {
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
    var mediaQuery = MediaQuery.of(context);
    var brightness = mediaQuery.platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? TColors.tSecondaryColor : TColors.tPrimaryColor,
      body: Container(
        padding: const EdgeInsets.all(TSizes.tDefaultSize),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image.asset(TImages.lightAppLogo),
            Column(
              children: [
                Text(
                  TTexts.tWelcomeTitle,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  TTexts.tWelcomeSubTitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (!isVerified) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignUpScreen()),
                        );
                      }
                    },
                    child: Text(
                      isVerified ? TTexts.tContinue.toUpperCase() : TTexts.tSignup.toUpperCase(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
