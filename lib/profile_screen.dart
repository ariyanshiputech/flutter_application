import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/global_data.dart';
import 'package:flutter_application/utils/constants/colors.dart';
import 'package:flutter_application/utils/theme/theme.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'main_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int currentPage = 1; // Set to 1 for Profile tab
  GlobalKey bottomNavigationKey = GlobalKey();
  int endTime = DateTime.parse('2024-07-21 12:00:11').millisecondsSinceEpoch;

  @override
  Widget build(BuildContext context) {
    final theme = ThemeModelInheritedNotifier.of(context).theme;

    return ThemeSwitchingArea(
      child: Builder(
        builder: (context) {
          // ignore: deprecated_member_use
          return WillPopScope(
            onWillPop: _onWillPop,
            child: Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    _navigateToMainScreen();
                  },
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
              body: Center(
                child: CountdownTimer(
                  endTime: endTime,
                  widgetBuilder: (_, time) {
                    if (time == null) {
                      return const Text('');
                    }
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildTimeBox(time.days, 'দিন', TColors.tDaysColor),
                        _buildTimeBox(time.hours, 'Hours', TColors.tHoursColor),
                        _buildTimeBox(time.min, 'Minutes', TColors.tMinutesColor),
                        _buildTimeBox(time.sec, 'Seconds', TColors.tSecondsColor),
                      ],
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<bool> _onWillPop() async {
    _navigateToMainScreen();
    return false; // Prevents the default back button behavior
  }

  void _navigateToMainScreen() {
    // ignore: avoid_types_as_parameter_names
    Get.off(() => MainScreen(onNavigateToPage: (int) => 1));
  }

  Widget _buildTimeBox(int? time, String label, Color color) {
    double percent = 1.0;
    if (label == 'দিন') {
      percent = time! / 365;
    } else if (label == 'Hours') {
      percent = time! / 24;
    } else if (label == 'Minutes') {
      percent = time! / 60;
    } else if (label == 'Seconds') {
      percent = time! / 60;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircularPercentIndicator(
            radius: 40.0,
            lineWidth: 5.0,
            percent: percent,
            center: Text(
              '$time\n$label',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontFamily: 'Bangla'),
            ),
            progressColor: color,
            backgroundColor: Colors.grey[200]!,
            circularStrokeCap: CircularStrokeCap.round,
            
          ),
      ),
    );
  }
}
