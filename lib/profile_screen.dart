import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/utils/constants/colors.dart';
import 'package:flutter_application/utils/theme/theme.dart';

class ProfileScreen extends StatefulWidget {
  final Map<dynamic, dynamic> userData;
  final Function(int) onNavigateToPage; // Callback function

  const ProfileScreen({
    super.key,
    required this.userData,
    required this.onNavigateToPage,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int currentPage = 1; // Set to 1 for Profile tab
  GlobalKey bottomNavigationKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final theme = ThemeModelInheritedNotifier.of(context).theme;
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Profile of ${widget.userData['name'] ?? 'User'}',
              style: const TextStyle(fontSize: 16),
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
          backgroundColor: TColors.tPrimaryColor, // Set AppBar background color to the theme's primary color
        ),
        body: const Center(child: Text('Profile Screen')), // Placeholder for the Profile screen content
      ),
    );
  }

  Future<bool> _onWillPop() async {
    widget.onNavigateToPage(0); // Navigate to the Home tab
    return false; // Prevent default back navigation
  }
}
