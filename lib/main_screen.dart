import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:fancy_bottom_navigation_2/fancy_bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/home_screen.dart';
import 'package:flutter_application/notification_screen.dart';
import 'package:flutter_application/utils/constants/colors.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class MainScreen extends StatefulWidget {
  final Function(int) onNavigateToPage;

  const MainScreen({super.key, required this.onNavigateToPage});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int currentPage = 0;
  GlobalKey<FancyBottomNavigationState> bottomNavigationKey = GlobalKey();

  void updatePage(int page) {
    setState(() {
      currentPage = page;
      bottomNavigationKey.currentState?.setPage(page);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ThemeSwitchingArea(
      child: Builder(
        builder: (context) {
          // ignore: deprecated_member_use
          return WillPopScope(
            onWillPop: () async {
              return true; // Disable back button
            },
            child: Scaffold(
              body: _getPageContent(currentPage),
              bottomNavigationBar: FancyBottomNavigation(
                key: bottomNavigationKey,
                circleColor: TColors.tPrimaryColor,
                textColor: TColors.tPrimaryColor,
                initialSelection: currentPage,
                tabs: [
                  TabData(iconData: LineAwesomeIcons.home_solid, title: ""),
                  TabData(iconData: LineAwesomeIcons.user, title: ""),
                  TabData(iconData: LineAwesomeIcons.bell, title: ""),
                ],
                onTabChangedListener: (position) {
                  setState(() {
                    currentPage = position;
                  });
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _getPageContent(int page) {
    switch (page) {
      case 0:
        return HomeScreen(onNavigateToPage: updatePage);
      case 1:
      return NotificationScreen(onNavigateToPage: updatePage);
      default:
        return const Text('404 Page');
    }
  }
}
