import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/otp_screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application/utils/constants/image_strings.dart';
import 'package:flutter_application/utils/constants/sizes.dart';
import 'package:flutter_application/utils/constants/text_strings.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:flutter_application/form_header_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:android_id/android_id.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _deviceKeyController = TextEditingController();
  final TextEditingController _ipAddressController = TextEditingController();
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _initializeDeviceInfo();
  }

  Future<void> _initializeDeviceInfo() async {
    const androidIdPlugin = AndroidId();
    final NetworkInfo networkInfo = NetworkInfo();

    try {
      String? deviceId;
      String ipAddress;

      if (Platform.isAndroid) {
        final String? androidId = await androidIdPlugin.getId();
        deviceId = androidId; // Unique ID on Android
      } else {
        deviceId = 'Unsupported platform';
      }

      ipAddress = await networkInfo.getWifiIP() ?? 'Unknown IP Address';

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

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _profileImage = File(pickedImage.path);
      });
    }
  }

  Future<void> _submitForm(String name, String phoneNo, String macAddress) async {
    final String deviceKey = _deviceKeyController.text;
    final String ipAddress = _ipAddressController.text;

    final url = Uri.parse('https://lalpoolnetwork.net/api/v2/apps/signup');

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'name': name,
          'phoneNo': phoneNo,
          'deviceKey': deviceKey,
          'ipAddress': ipAddress,
          'macAddress': macAddress,
        }),
      );

     if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          final String phoneNumber = responseData['user']['phone'];
          final int userID = responseData['user']['id'];
          if (kDebugMode) {
            print('Sign up successful');
            print('Phone Number: $phoneNumber');
          }
          // Navigate to the OTP screen with the phone number
          Navigator.push(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(
              builder: (context) => OTPScreen(phoneNumber: phoneNumber, userID : userID),
            ),
          );
        }
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        if (kDebugMode) {
          print('Failed to sign up');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred while signing up: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                                    color: Colors.blue,
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
                                    color: Colors.blue,
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
                const SizedBox(height: TSizes.tFormHeight - 10),
                const SizedBox(height: 20),
                FormSection(
                  deviceKeyController: _deviceKeyController,
                  ipAddressController: _ipAddressController,
                  onSubmit: _submitForm,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FormSection extends StatelessWidget {
  final TextEditingController deviceKeyController;
  final TextEditingController ipAddressController;
  final Function(String, String, String) onSubmit;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  FormSection({
    super.key,
    required this.deviceKeyController,
    required this.ipAddressController,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController phoneNoController = TextEditingController();
    final TextEditingController macAddressController = TextEditingController();

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
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: phoneNoController,
              decoration: InputDecoration(
                label: const Text("Phone No"),
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Phone No is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: deviceKeyController,
              decoration: InputDecoration(
                label: const Text("Device Key"),
                prefixIcon: const Icon(Icons.device_hub),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                enabled: false,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Device Key is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: ipAddressController,
              decoration: InputDecoration(
                label: const Text("IP Address"),
                prefixIcon: const Icon(Icons.device_thermostat_sharp),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                enabled: false,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'IP Address is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: macAddressController,
              decoration: InputDecoration(
                label: const Text("Mac Address"),
                prefixIcon: const Icon(Icons.security_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Mac Address is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    onSubmit(
                      nameController.text,
                      phoneNoController.text,
                      macAddressController.text,
                    );
                  }
                },
                child: const Text("SIGN UP"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
