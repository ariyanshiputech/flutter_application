import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:fancy_bottom_navigation_2/fancy_bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/home_screen.dart'; // Make sure you import your HomeScreen file
import 'package:flutter_application/notification_screen.dart';
import 'package:flutter_application/utils/constants/colors.dart';
import 'package:flutter_application/utils/constants/image_strings.dart';
import 'package:flutter_application/utils/theme/theme.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class ProfileScreen extends StatefulWidget {
  final Map<dynamic, dynamic> userData;
  const ProfileScreen({super.key, required this.userData});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int currentPage = 1; // Set to 1 for Profile tab
  GlobalKey bottomNavigationKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return ThemeSwitchingArea(
      child: Builder(
        builder: (context) {
          final theme = ThemeModelInheritedNotifier.of(context).theme;

          // ignore: deprecated_member_use
          return WillPopScope(
            onWillPop: () async {
              return true; // Disable back button
            },
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
              bottomNavigationBar: FancyBottomNavigation(
                circleColor: TColors.tPrimaryColor,
                textColor: TColors.tPrimaryColor,
                initialSelection: currentPage,
                tabs: [
                  TabData(iconData: LineAwesomeIcons.home_solid, title: "Home"),
                  TabData(iconData: LineAwesomeIcons.qrcode_solid, title: "Profile"),
                  TabData(iconData: LineAwesomeIcons.shopping_bag_solid, title: "Basket"),
                ],
                onTabChangedListener: (position) {
                  setState(() {
                    currentPage = position;
                  });
                  switch (position) {
                    case 0:
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeScreen(userData: widget.userData),
                        ),
                      );
                      break;
                    case 1:
                      // Already on ProfileScreen, no need to navigate
                      break;
                    case 2:
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotificationScreen(userData: widget.userData), // Placeholder for the Basket screen
                        ),
                      );
                      break;
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
