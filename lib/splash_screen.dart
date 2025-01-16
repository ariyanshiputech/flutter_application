import 'dart:convert';
import 'dart:io';
import 'package:device_info/device_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/global_data.dart';
import 'package:flutter_application/main_screen.dart';
import 'package:flutter_application/otp_screen.dart';
import 'package:flutter_application/utils/constants/image_strings.dart';
import 'package:flutter_application/welcome_screen.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:platform_device_id_platform_interface/platform_device_id_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  String? deviceKey;
  bool isVerified = false;
  DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  @override
  void initState() {
    super.initState();
    _initializeDeviceInfo();
  }

  Future<void> _initializeDeviceInfo() async {
    String? deviceId;
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        deviceId = prefs.getString('device_id');
      } else if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
        deviceId = androidInfo.androidId;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
        deviceId = iosInfo.identifierForVendor;
      } else {
        deviceId = await PlatformDeviceIdPlatform.instance.getDeviceId();
      }

      setState(() {
        deviceKey = deviceId;
      });
      if (kDebugMode) {
        print(deviceKey);
      }
      verifyUser(deviceKey!);
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
        },
        body: jsonEncode(<String, String>{
          'device_key': deviceKey,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          GlobalData.userData = responseData['user'];
          GlobalData.pppoeData = responseData['pppoe'];
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
                  ? MainScreen(
                      onNavigateToPage: (int) {
                        return 1;
                      },
                    )
                  : OTPScreen(phoneNumber: phoneNumber, userID: userID),
            ),
          );

          if (kDebugMode) {
            print(responseData['user']['status']);
          }
        } else {
          setState(() {
            isVerified = false;
          });
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          if (kDebugMode) {
            print(responseData['demo']);
          }
          GlobalData.demo = responseData['demo'];

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

        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (kDebugMode) {
          print(responseData['demo']);
        }
        GlobalData.demo = responseData['demo'];
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
