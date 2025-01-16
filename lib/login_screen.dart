import 'dart:convert';
import 'dart:io';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:ariyanpay/widget/custom_snackbar.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application/alert_builder.dart';
import 'package:flutter_application/global_data.dart';
import 'package:flutter_application/otp_screen.dart';
import 'package:flutter_application/signup_screen.dart';
import 'package:flutter_application/utils/constants/colors.dart';
import 'package:flutter_application/utils/snackbar_utils.dart';
import 'package:flutter_application/utils/theme/theme.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application/utils/constants/sizes.dart';
import 'package:platform_device_id_platform_interface/platform_device_id_platform_interface.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    if (kDebugMode) {
      print(GlobalData.userData?['reseller_id']);
    }
    super.initState();
  }

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    final result = await QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      confirmBtnColor: TColors.tPrimaryColor,
      text: 'Do you want to exit the app?',
      confirmBtnText: 'Yes',
      cancelBtnText: 'No',
      onConfirmBtnTap: () {
        SystemNavigator.pop(); // Close dialog and exit the app
      },
      onCancelBtnTap: () {
        Navigator.of(context).pop(false); // Close dialog and return false
      },
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeModelInheritedNotifier.of(context).theme;

    return ThemeSwitchingArea(
      // ignore: deprecated_member_use
      child: WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          appBar: AppBar(
            title: const Center(
              child: Text(
                'Login',
                style: TextStyle(fontSize: 16),
              ),
            ),
            actions: [
              ThemeSwitcher(
                clipper: const ThemeSwitcherCircleClipper(),
                builder: (context) {
                  return IconButton(
                    icon: Icon(
                      theme.brightness == Brightness.dark
                          ? Icons.wb_sunny
                          : Icons.nights_stay,
                    ),
                    onPressed: () {
                      ThemeSwitcher.of(context).changeTheme(
                        theme: theme.brightness == Brightness.light
                            ? TAppTheme.darkTheme
                            : TAppTheme.lightTheme,
                      );
                    },
                  );
                },
              ),
            ],
            backgroundColor: TColors.tPrimaryColor,
          ),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(TSizes.tDefaultSize),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FormSection(
                      phoneController: phoneController,
                      passwordController: passwordController,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FormSection extends StatefulWidget {
  final TextEditingController phoneController;
  final TextEditingController passwordController;

  const FormSection({
    super.key,
    required this.phoneController,
    required this.passwordController,
  });

  @override
  FormSectionState createState() => FormSectionState();
}

class FormSectionState extends State<FormSection> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final isPlatformDark =
        // ignore: deprecated_member_use
        WidgetsBinding.instance.window.platformBrightness == Brightness.dark;
    final initTheme =
        isPlatformDark ? TAppTheme.darkTheme : TAppTheme.lightTheme;
    String? deviceId;

    return Center(
      child: ThemeProvider(
        initTheme: initTheme,
        builder: (_, myTheme) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'LOGIN',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                  ),
                  const Text(
                    '(Make your Journey easy with our internet service.)',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: TSizes.tFormHeight - 10),
                  TextFormField(
                    controller: widget.phoneController,
                    enabled: true,
                    decoration: InputDecoration(
                      labelText: "Phone Number",
                      prefixIcon: const Icon(Icons.phone),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      } else if (!RegExp(r'^\+?[0-9]{10,15}$')
                          .hasMatch(value)) {
                        return 'Please enter a valid phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: widget.passwordController,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      } else if (value.length < 6) {
                        return 'Password must be at least 6 characters long';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          AlertBuilder.showLoadingDialog(context);
                          try {
                            deviceId = await getDeviceId();
                            final response = await http.post(
                              Uri.parse(
                                  'https://lalpoolnetwork.net/api/v2/apps/login'),
                              body: {
                                'phone': widget.phoneController.text,
                                'password': widget.passwordController.text,
                                'device_key': deviceId,
                              },
                            );

                            if (response.statusCode == 200) {
                              AlertBuilder.hideLoadingDialog(context);
                              final Map<String, dynamic> responseData =
                                  jsonDecode(response.body);

                              // Proceed with successful login
                              GlobalData.userData = responseData['user'];
                              GlobalData.pppoeData = responseData['pppoe'];
                              final String phoneNumber =
                                  responseData['user']['phone'];
                              final int userID = responseData['user']['id'];

                              if (context.mounted) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        responseData['user']['status'] == 1
                                            ? MainScreen(
                                                onNavigateToPage: (int) {
                                                  return 1;
                                                },
                                              )
                                            : OTPScreen(
                                                phoneNumber: phoneNumber,
                                                userID: userID,
                                              ),
                                  ),
                                );
                              }

                              SnackbarUtils.showSnackBar(context, 'Yeah!!',
                                  'Login successful.', ContentType.success);
                            } else {
                              SnackbarUtils.showSnackBar(context, 'Opps!',
                                  'Invalid credentials.', ContentType.failure);
                            }
                          } catch (e) {
                            if (context.mounted) {
                              snackBar('An error occurred: $e', context);
                            }
                          }
                        }
                      },
                      child: const Text("LOGIN"),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: const [
                      Expanded(
                        child: Divider(
                          thickness: 1,
                          endIndent: 10,
                        ),
                      ),
                      Text('OR'),
                      Expanded(
                        child: Divider(
                          thickness: 1,
                          indent: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignUpScreen(),
                          ),
                        );
                      },
                      child: const Text("SIGN UP"),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Device info retrieval
Future<String?> getDeviceId() async {
  String? deviceId;

  DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
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

  return deviceId;
}
