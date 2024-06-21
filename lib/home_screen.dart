import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:fancy_bottom_navigation_2/fancy_bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/notification_screen.dart';
import 'package:flutter_application/profile_screen.dart';
import 'package:flutter_application/utils/constants/colors.dart';
import 'package:flutter_application/utils/constants/image_strings.dart';
import 'package:flutter_application/utils/theme/theme.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class HomeScreen extends StatefulWidget {
  final Map<dynamic, dynamic> userData;
  const HomeScreen({super.key, required this.userData});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentPage = 0;
  GlobalKey bottomNavigationKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return ThemeSwitchingArea(
      child: Builder(
        builder: (context) {
          final theme = ThemeModelInheritedNotifier.of(context).theme;

          return WillPopScope(
            onWillPop: _onWillPop,
            child: Scaffold(
              appBar: AppBar(
                leading: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(userData: widget.userData),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(
                          widget.userData['profile'] ?? 'https://via.placeholder.com/150',
                        ),
                        onBackgroundImageError: (_, __) {
                          // Fallback image in case of an error
                          const AssetImage(TImages.user);
                        },
                      ),
                    ),
                  ),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        'Hello, ${widget.userData['name'] ?? 'Customer'}',
                        style: const TextStyle(fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
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
              body: const Center(child: Text('Home Screen')), // Placeholder for the Home screen content
              bottomNavigationBar: FancyBottomNavigation(
                circleColor: TColors.tPrimaryColor,
                textColor: TColors.tPrimaryColor,
                initialSelection: currentPage,
                tabs: [
                  TabData(iconData: LineAwesomeIcons.home_solid, title: "Home"),
                  TabData(iconData: LineAwesomeIcons.qrcode_solid, title: "Profile"),
                  TabData(iconData: LineAwesomeIcons.bell_solid, title: "Notification"),
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
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(userData: widget.userData),
                        ),
                      );
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

  Future<bool> _onWillPop() async {
    return await QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,
        confirmBtnColor: TColors.tPrimaryColor,
        text: 'Do you want to exit the app?',
        confirmBtnText: 'Yes',
        cancelBtnText: 'No',
        onConfirmBtnTap: () {
          Navigator.of(context).pop(true); // Close dialog and return true
        },
        onCancelBtnTap: () {
          Navigator.of(context).pop(false); // Close dialog and return false
        },
      );
  }
}
