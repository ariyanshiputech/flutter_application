// Import Statements
import 'dart:convert';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:babstrap_settings_screen/babstrap_settings_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/alert_builder.dart';
import 'package:flutter_application/global_data.dart';
import 'package:flutter_application/profile_screen.dart';
import 'package:flutter_application/usercard_builder.dart';
import 'package:flutter_application/utils/constants/colors.dart';
import 'package:flutter_application/utils/constants/image_strings.dart';
import 'package:flutter_application/utils/snackbar_utils.dart';
import 'package:flutter_application/utils/theme/theme.dart';
import 'package:http/http.dart' as http;

class SettingsScreen extends StatefulWidget {
  final Function(int) onNavigateToPage;

  const SettingsScreen({
    super.key,
    required this.onNavigateToPage,
  });

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  bool isHomeUserVersion = false;
  bool isLoading = false;
  Uint8List? decodedBytes;

  @override
  void initState() {
    super.initState();

    // Fetch the version value from GlobalData
    final version = GlobalData.userData?['version'];

    // Check the value of version and set isHomeUserVersion accordingly
    isHomeUserVersion =
        (version == 1 || version == '1' || version == true) ? true : false;

    // Decode the profile image if present
    decodeBase64Image();
  }

  void decodeBase64Image() {
    final base64Image = GlobalData.userData?['profile'];
    if (base64Image != null && base64Image.isNotEmpty) {
      try {
        decodedBytes = base64Decode(base64Image);
      } catch (e) {
        if (kDebugMode) {
          print('Error decoding base64 image: $e');
        }
      }
    }
  }

  Future<void> _updateVersion(bool newVersion) async {
    setState(() {
      isLoading = true;
      isHomeUserVersion = newVersion; // Update the version state
    });

    try {
      final uri = Uri.https('lalpoolnetwork.net', '/api/v2/apps/version');
      final userId = GlobalData.userData?['id'];
      if (userId == null) {
        throw Exception("User ID is null");
      }

      AlertBuilder.showLoadingDialog(context); // Show loading dialog

      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode({
              'user_id': userId.toString(),
              'version': newVersion,
            }),
          )
          .timeout(const Duration(seconds: 10));

      AlertBuilder.hideLoadingDialog(context); // Hide loading dialog

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          setState(() {
            GlobalData.userData = responseData['user'];
            isHomeUserVersion = GlobalData.userData?['version'] == true ||
                GlobalData.userData?['version'] == '1';
          });
          SnackbarUtils.showSnackBar(context, 'Success',
              'Version updated successfully', ContentType.success);
        } else {
          throw Exception("Request failed with success=false");
        }
      } else {
        throw Exception(
            "Request failed with status code: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isHomeUserVersion = !isHomeUserVersion; // Revert on error
      });
      SnackbarUtils.showSnackBar(
          context, 'Error', e.toString(), ContentType.failure);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appId = GlobalData.userData?['app_id'];

    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        widget.onNavigateToPage(0);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => widget.onNavigateToPage(0),
          ),
          title: const Text('Settings'),
          backgroundColor: TColors.tPrimaryColor,
          actions: [
            ThemeSwitcher(
              clipper: const ThemeSwitcherCircleClipper(),
              builder: (context) {
                final theme = ThemeModelInheritedNotifier.of(context).theme;
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
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                UserCard(
                  backgroundColor: TColors.tPrimaryColor,
                  userName: GlobalData.userData?['name'] ?? 'N/A',
                  userProfilePic: decodedBytes != null
                      ? MemoryImage(decodedBytes!)
                      : const AssetImage(TImages.user),
                  userPhone: GlobalData.userData?['phone'] ?? '',
                  cardActionWidget: SettingsItem(
                    icons: Icons.edit,
                    iconStyle: IconStyle(
                      withBackground: true,
                      borderRadius: 50,
                      backgroundColor: Colors.yellow[600],
                    ),
                    title: "Modify",
                    subtitle: "Tap to change your data",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (appId != null && appId.isNotEmpty)
                  Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    elevation: 4,
                    shadowColor: Colors.black.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.settings,
                                size: 28,
                                color: TColors.tPrimaryColor,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "Select Application Version",
                                  style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.045, // Adaptive font size
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(
                            thickness: 1.2,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 10),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              "Home User Version",
                              style: TextStyle(
                                fontSize: MediaQuery.of(context).size.width *
                                    0.042, // Adaptive font size
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              "Ideal for residential users with simplified settings.",
                              style: TextStyle(
                                fontSize: MediaQuery.of(context).size.width *
                                    0.035, // Smaller adaptive font size
                                color: Colors.black54,
                              ),
                            ),
                            value: isHomeUserVersion,
                            onChanged: (value) {
                              _updateVersion(value);
                            },
                            activeColor: TColors.tPrimaryColor,
                            secondary: const Icon(Icons.home_rounded,
                                color: Colors.blue),
                          ),
                          const SizedBox(height: 8),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              "Hotspot Package Version",
                              style: TextStyle(
                                fontSize: MediaQuery.of(context).size.width *
                                    0.042, // Adaptive font size
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              "Best for businesses with advanced networking.",
                              style: TextStyle(
                                fontSize: MediaQuery.of(context).size.width *
                                    0.035, // Smaller adaptive font size
                                color: Colors.black54,
                              ),
                            ),
                            value: !isHomeUserVersion,
                            onChanged: (value) {
                              _updateVersion(!value); // Toggle the value
                            },
                            activeColor: TColors.tPrimaryColor,
                            secondary: const Icon(Icons.wifi_rounded,
                                color: Colors.orange),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
