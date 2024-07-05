import 'dart:convert';
import 'dart:io';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/alert_builder.dart';
import 'package:flutter_application/global_data.dart';
import 'package:flutter_application/utils/constants/colors.dart';
import 'package:flutter_application/utils/theme/theme.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application/utils/constants/image_strings.dart';
import 'package:flutter_application/utils/constants/sizes.dart';
import 'package:image_picker/image_picker.dart';

import 'main_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  File? _profileImage;
  String _nameErrorMessage = '';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
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

  Future<void> _submitForm(String name) async {
    setState(() {
      _isSubmitting = true;
    });

    final url = Uri.https('lalpoolnetwork.net', '/api/v2/apps/update_user');

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
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'POST, GET, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization',
        },
        body: jsonEncode(<String, dynamic>{
          'name': name,
          'user_id': GlobalData.userData?['id'],
          if (base64Image != null) 'profileImage': base64Image,
        }),
      );

      // Hide the loading dialog
      // ignore: use_build_context_synchronously
      AlertBuilder.hideLoadingDialog(context);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          GlobalData.userData = responseData['user'];
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
            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(snackBar);
          if (kDebugMode) {
            print('Sign up successful');
          }
         
        }
      } else {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        setState(() {
          _nameErrorMessage = responseData['errors']?['name']?.first ?? '';

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

  Future<bool> _onWillPop() async {
    _navigateToMainScreen();
    return false; // Prevents the default back button behavior
  }

  void _navigateToMainScreen() {
    // ignore: avoid_types_as_parameter_names
    Get.off(() => MainScreen(onNavigateToPage: (int) => 1));
  }

  @override
  Widget build(BuildContext context) {
    String? base64Image = GlobalData.userData?['profile'];

    // Decode the base64 string to bytes, or use null if it's not available
    Uint8List? decodedBytes;
    if (base64Image != null && base64Image.isNotEmpty) {
      decodedBytes = base64Decode(base64Image);
    }

    final theme = ThemeModelInheritedNotifier.of(context).theme;

    return ThemeSwitchingArea(
      // ignore: deprecated_member_use
      child: WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _navigateToMainScreen,
            ),
            title: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  'Profile of ${GlobalData.userData?['name'] ?? 'User'}',
                  style: const TextStyle(fontSize: 16),
                ),
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
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(TSizes.tDefaultSize),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                       CircleAvatar(
                          radius: 50,
                          backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : (decodedBytes != null
                                ? MemoryImage(decodedBytes)
                                : const AssetImage(TImages.placeholderimage)), // Ensure `decodedBytes` is non-nullable
                          onBackgroundImageError: (_, __) {},
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
                const SizedBox(height: 20),
                FormSection(
                  onSubmit: _submitForm,
                  nameErrorMessage: _nameErrorMessage,
                  isSubmitting: _isSubmitting,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FormSection extends StatefulWidget {
  final Future<void> Function(String) onSubmit;
  final String nameErrorMessage;
  final bool isSubmitting;

  const FormSection({
    super.key,
    required this.onSubmit,
    required this.nameErrorMessage,
    required this.isSubmitting,
  });

  @override
  FormSectionState createState() => FormSectionState();
}

class FormSectionState extends State<FormSection> {
  final TextEditingController nameController = TextEditingController(text: GlobalData.userData?["name"]); // Default value 'hi'
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? nameError;

  @override
  void initState() {
    super.initState();
    nameError = widget.nameErrorMessage;
  }

  @override
  void didUpdateWidget(covariant FormSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.nameErrorMessage != oldWidget.nameErrorMessage) {
      setState(() {
        nameError = widget.nameErrorMessage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    final isPlatformDark = WidgetsBinding.instance.window.platformBrightness == Brightness.dark;
    final initTheme = isPlatformDark ? TAppTheme.darkTheme : TAppTheme.lightTheme;

    return Center(
      child: ThemeProvider(
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
                      labelText: "Name",
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: nameError != null ? Colors.red : Colors.grey),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Name cannot be empty';
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
                          setState(() {
                            nameError = null;
                          });
                          await widget.onSubmit(nameController.text);
                        }
                      },
                      child: const Text("UPDATE"),
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
