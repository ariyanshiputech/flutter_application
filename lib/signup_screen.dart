import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/alert_builder.dart';
import 'package:flutter_application/otp_screen.dart';
import 'package:flutter_application/utils/constants/colors.dart';
import 'package:flutter_application/utils/theme/theme.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application/utils/constants/image_strings.dart';
import 'package:flutter_application/utils/constants/sizes.dart';
import 'package:flutter_application/utils/constants/text_strings.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:flutter_application/form_header_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:platform_device_id_platform_interface/platform_device_id_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _deviceKeyController = TextEditingController();
  final TextEditingController _ipAddressController = TextEditingController();
  File? _profileImage;
  String _phoneErrorMessage = '';
  String _nameErrorMessage = '';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initializeDeviceInfo();
  }

  Future<void> _initializeDeviceInfo() async {
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    final NetworkInfo networkInfo = NetworkInfo();

    try {
      String? deviceId;
      String ipAddress;

      if (kIsWeb) {
        deviceId = await _getOrCreateDeviceId();
        ipAddress = await _getWebIpAddress();
      } else if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
        deviceId = androidInfo.androidId;
        ipAddress = await networkInfo.getWifiIP() ?? 'Unknown IP Address';
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
        deviceId = iosInfo.identifierForVendor;
        ipAddress = await networkInfo.getWifiIP() ?? 'Unknown IP Address';
      } else {
        deviceId = await PlatformDeviceIdPlatform.instance.getDeviceId();
        ipAddress = await networkInfo.getWifiIP() ?? 'Unknown IP Address';
      }

      setState(() {
        _deviceKeyController.text = deviceId!;
        _ipAddressController.text = ipAddress;
      });
    } catch (e) {
      setState(() {
        _deviceKeyController.text = 'Failed to get device ID';
        _ipAddressController.text = 'Failed to get IP Address';
      });
    }
  }

  Future<String> _getOrCreateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString('device_id');

    if (deviceId == null || deviceId.isEmpty) {
      deviceId = _generateRandomString(16);
      await prefs.setString('device_id', deviceId);
    }
    return deviceId;
  }

  String _generateRandomString(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  Future<String> _getWebIpAddress() async {
    try {
      final response = await http.get(Uri.parse('https://api.ipify.org?format=json'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['ip'] ?? 'Unknown IP Address';
      } else {
        return 'Unknown IP Address';
      }
    } catch (e) {
      return 'Failed to get IP Address';
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _profileImage = File(pickedImage.path);
      });
    }
  }

  Future<void> _submitForm(String name, String phoneNo, String appId) async { // Updated
    setState(() {
      _isSubmitting = true;
    });

    final String deviceKey = _deviceKeyController.text;
    final String ipAddress = _ipAddressController.text;

    final url = Uri.https('lalpoolnetwork.net', '/api/v2/apps/signup');

    try {
      String? base64Image;
      if (_profileImage != null) {
        List<int> imageBytes = await _profileImage!.readAsBytes();
        base64Image = base64Encode(imageBytes);
      }

      // Show the loading dialog
      // ignore: use_build_context_synchronously
      AlertBuilder.showLoadingDialog(context);

      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{ // Updated
          'name': name,
          'phoneNo': phoneNo,
          'appId': appId, // Added
          'deviceKey': deviceKey,
          'ipAddress': ipAddress,
          if (base64Image != null) 'profileImage': base64Image,
        }),
      );
      
      // Hide the loading dialog
      AlertBuilder.hideLoadingDialog(context);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          final String phoneNumber = responseData['user']['phone'];
          final int userID = responseData['user']['id'];
          Navigator.push(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(
              builder: (context) => OTPScreen(phoneNumber: phoneNumber, userID: userID),
            ),
          );
        }
      } else {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        setState(() {
          _nameErrorMessage = responseData['errors']?['name']?.first ?? '';
          _phoneErrorMessage = responseData['errors']?['phoneNo']?.first ?? '';

          if (_nameErrorMessage.isNotEmpty) {
            final snackBar = SnackBar(
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              content: AwesomeSnackbarContent(
                title: '',
                message: _nameErrorMessage,
                contentType: ContentType.failure,
              ),
            );
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(snackBar);
          }

          if (_nameErrorMessage.isEmpty && _phoneErrorMessage.isNotEmpty) {
            final snackBar = SnackBar(
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              content: AwesomeSnackbarContent(
                title: 'Oops!',
                message: _phoneErrorMessage,
                contentType: ContentType.failure,
              ),
            );
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(snackBar);
          }

      if (response.statusCode == 401) {
           final snackBar = SnackBar(
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              content: AwesomeSnackbarContent(
                title: 'Oops!',
                message: responseData['message'],
                contentType: ContentType.failure,
              ),
            );
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(snackBar);
          }
        });

        if (kDebugMode) {
          print('Failed to sign up. Status code: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
      }
    } catch (e) {
      // Hide the loading dialog
      // ignore: use_build_context_synchronously
      AlertBuilder.hideLoadingDialog(context);

      if (kDebugMode) {
        print('Error occurred while signing up: $e');
      }
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return SafeArea(
          child: Scaffold(
            body: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(TSizes.tDefaultSize),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FormHeaderWidget(
                      image: TImages.darkAppLogo,
                      title: TTexts.tSignUpTitle,
                      subTitle: TTexts.tSignUpSubTitle,
                      imageHeight: 0.15,
                      isAvatarPresent: true,
                      avatar: _profileImage != null
                          ? GestureDetector(
                              onTap: _pickImage,
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 50,
                                    backgroundImage: FileImage(_profileImage!),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: const BoxDecoration(
                                        color: TColors.tPrimaryColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : GestureDetector(
                              onTap: _pickImage,
                              child: Stack(
                                children: [
                                  const CircleAvatar(
                                    radius: 50,
                                    backgroundImage: AssetImage(TImages.user),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: const BoxDecoration(
                                        color: TColors.tPrimaryColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                    FormSection(
                      deviceKeyController: _deviceKeyController,
                      ipAddressController: _ipAddressController,
                      onSubmit: _submitForm,
                      nameErrorMessage: _nameErrorMessage,
                      phoneErrorMessage: _phoneErrorMessage,
                      isSubmitting: _isSubmitting,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class FormSection extends StatefulWidget {
  final TextEditingController deviceKeyController;
  final TextEditingController ipAddressController;
  final Future<void> Function(String, String, String) onSubmit; // Updated
  final String nameErrorMessage;
  final String phoneErrorMessage;
  final bool isSubmitting;

  const FormSection({
    super.key,
    required this.deviceKeyController,
    required this.ipAddressController,
    required this.onSubmit,
    required this.nameErrorMessage,
    required this.phoneErrorMessage,
    required this.isSubmitting,
  });

  @override
  FormSectionState createState() => FormSectionState();
}

class FormSectionState extends State<FormSection> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneNoController = TextEditingController();
  final TextEditingController appIdController = TextEditingController(); // Added
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? nameError;
  String? phoneError;

  @override
  void initState() {
    super.initState();
    nameError = widget.nameErrorMessage;
    phoneError = widget.phoneErrorMessage;
  }

  @override
  void didUpdateWidget(covariant FormSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.nameErrorMessage != oldWidget.nameErrorMessage) {
      setState(() {
        nameError = widget.nameErrorMessage;
      });
    }
    if (widget.phoneErrorMessage != oldWidget.phoneErrorMessage) {
      setState(() {
        phoneError = widget.phoneErrorMessage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPlatformDark = WidgetsBinding.instance.window.platformBrightness == Brightness.dark;
    final initTheme = isPlatformDark ? TAppTheme.darkTheme : TAppTheme.lightTheme;
    return ThemeProvider(
      initTheme: initTheme,
      builder: (_, myTheme) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 30),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    label: const Text("Name"),
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: nameError != null ? Colors.red : Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: phoneNoController,
                  decoration: InputDecoration(
                    label: const Text("Phone No"),
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: appIdController, // Added
                  decoration: InputDecoration(
                    label: const Text("App ID"), // Added
                    prefixIcon: const Icon(Icons.apps), // Added
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: widget.deviceKeyController,
                  decoration: InputDecoration(
                    label: const Text("Device Key"),
                    prefixIcon: const Icon(Icons.device_hub),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    enabled: false,
                  ),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: widget.ipAddressController,
                  decoration: InputDecoration(
                    label: const Text("IP Address"),
                    prefixIcon: const Icon(Icons.device_thermostat_sharp),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    enabled: false,
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          nameError = null;
                          phoneError = null;
                        });

                        // Show the loading dialog
                        await widget.onSubmit(
                          nameController.text,
                          phoneNoController.text,
                          appIdController.text, // Pass appId
                        );

                        // Hide the loading dialog
                      }
                    },
                    child: const Text("SIGN UP"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
