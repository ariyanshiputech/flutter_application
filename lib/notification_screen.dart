import 'dart:async';

import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/utils/constants/colors.dart';
import 'package:flutter_application/utils/theme/theme.dart';

class NotificationScreen extends StatefulWidget {
  final Map<dynamic, dynamic> userData;
  final Function(int) onNavigateToPage; // Callback function

  const NotificationScreen({
    super.key,
    required this.userData,
    required this.onNavigateToPage,
  });

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

    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              widget.onNavigateToPage(0); // Navigate back to home page
            },
          ),
          title: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(child: Text('Notifications')),
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
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
      ),
    );
  }

  Future<bool> _onWillPop() async {
    widget.onNavigateToPage(0);
    return false; // Prevent default back navigation
  }

  Widget _buildNotificationList(List notifications) {
    if (notifications.isEmpty) {
      return const Center(child: Text('No notifications available'));
    }

    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.notifications, color: TColors.tPrimaryColor),
          title: Text(notifications[index]),
        );
      },
    );
  }
}
