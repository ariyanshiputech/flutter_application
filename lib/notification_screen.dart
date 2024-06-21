import 'dart:async';

import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:fancy_bottom_navigation_2/fancy_bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/home_screen.dart';
import 'package:flutter_application/profile_screen.dart';
import 'package:flutter_application/utils/constants/colors.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:flutter_application/utils/theme/theme.dart';

class NotificationScreen extends StatefulWidget {
  final Map<dynamic, dynamic> userData;
  const NotificationScreen({super.key, required this.userData});

  @override
  NotificationScreenState createState() => NotificationScreenState();
}

class NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  int currentPage = 2; // Set to 2 for Notification tab
  late TabController _tabController;
  DateTime? currentBackPressTime;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final successfulNotifications =
        widget.userData['successfulNotifications'] ?? [];
    final unsuccessfulNotifications =
        widget.userData['unsuccessfulNotifications'] ?? [];

    return ThemeSwitchingArea(
      child: WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false, // Hides the automatically added back button
            title: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Notifications'),
            ),
            backgroundColor: TColors.tPrimaryColor,
            actions: [
              ThemeSwitcher(
                clipper: const ThemeSwitcherCircleClipper(),
                builder: (context) {
                  final theme =
                      ThemeModelInheritedNotifier.of(context).theme;
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
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: TabBar(
                        controller: _tabController,
                        tabs: const [
                          Tab(text: 'Successful'),
                          Tab(text: 'Unsuccessful'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildNotificationList(successfulNotifications),
                    _buildNotificationList(unsuccessfulNotifications),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: FancyBottomNavigation(
            circleColor: TColors.tPrimaryColor,
            textColor: TColors.tPrimaryColor,
            initialSelection: currentPage,
            tabs: [
              TabData(iconData: LineAwesomeIcons.home_solid, title: "Home"),
              TabData(iconData: LineAwesomeIcons.qrcode_solid, title: "Profile"),
              TabData(
                  iconData: LineAwesomeIcons.bell_solid,
                  title: "Notification"),
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
                      builder: (context) =>
                          HomeScreen(userData: widget.userData),
                    ),
                  );
                  break;
                case 1:
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProfileScreen(userData: widget.userData),
                    ),
                  );
                  break;
                case 2:
                  // Already on NotificationScreen, no need to navigate
                  break;
              }
            },
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (currentPage != 0) {
      // If not on the home page, navigate to the home page first
      setState(() {
        currentPage = 0;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(userData: widget.userData),
        ),
      );
      return false;
    } 
    return true;
  }

  Widget _buildNotificationList(List notifications) {
    if (notifications.isEmpty) {
      return Center(child: Text('No notifications available'));
    }

    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Icon(Icons.notifications, color: TColors.tPrimaryColor),
          title: Text(notifications[index]),
        );
      },
    );
  }
}
