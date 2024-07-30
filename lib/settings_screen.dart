import 'dart:async';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/utils/constants/colors.dart';
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
        body:  const Center(child: Text('Settings')),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    widget.onNavigateToPage(0);
    return false;
  }

}