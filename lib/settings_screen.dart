import 'dart:async';
import 'dart:convert';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:babstrap_settings_screen/babstrap_settings_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/global_data.dart';
import 'package:flutter_application/profile_screen.dart';
import 'package:flutter_application/usercard_builder.dart';
import 'package:flutter_application/utils/constants/colors.dart';
import 'package:flutter_application/utils/constants/image_strings.dart';
import 'package:flutter_application/utils/theme/theme.dart';

class SettingsScreen extends StatefulWidget {
  final Function(int) onNavigateToPage;

  const SettingsScreen({
    super.key,
    required this.onNavigateToPage,
  });

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  int currentPage = 1;
  DateTime? currentBackPressTime;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String? base64Image = GlobalData.userData?['profile'];

    // Decode the base64 string to bytes, or use null if it's not available
    Uint8List? decodedBytes;
    if (base64Image != null && base64Image.isNotEmpty) {
      decodedBytes = base64Decode(base64Image);
    }

    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              widget.onNavigateToPage(0);
            },
          ),
          title: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(child: Text('Settings')),
          ),
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
        body: SingleChildScrollView(
          // Added SingleChildScrollView to avoid overflow
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                UserCard(
                  backgroundColor: TColors.tPrimaryColor,
                  userName: GlobalData.userData?['name'],
                  userProfilePic: decodedBytes != null
                      ? MemoryImage(decodedBytes)
                      : const AssetImage(TImages.placeholderimage) as ImageProvider,
                  userPhone: GlobalData.userData?['phone'] ?? '',
                  // Fixed the issue with dynamic text
                  cardActionWidget: SettingsItem(
                    icons: Icons.edit,
                    iconStyle: IconStyle(
                      withBackground: true,
                      borderRadius: 50,
                      backgroundColor: Colors.yellow[600],
                    ),
                    title: "Modify",
                    subtitle: "Tap to change your data",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20), // Add spacing
              
             
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    widget.onNavigateToPage(0);
    return false;
  }
}
