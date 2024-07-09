import 'dart:convert';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application/buyhotspot.dart';
import 'package:flutter_application/card_recharge.dart';
import 'package:flutter_application/global_data.dart';
import 'package:flutter_application/profile_screen.dart';
import 'package:flutter_application/utils/constants/colors.dart';
import 'package:flutter_application/utils/constants/image_strings.dart';
import 'package:flutter_application/utils/constants/translate.dart';
import 'package:flutter_application/utils/theme/theme.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:lottie/lottie.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onNavigateToPage;

  const HomeScreen({super.key, required this.onNavigateToPage});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int currentPage = 1; // Set to 1 for Profile tab
  GlobalKey bottomNavigationKey = GlobalKey();
  int endTime = DateTime.parse(GlobalData.userData?['expire_date']).millisecondsSinceEpoch;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = ThemeModelInheritedNotifier.of(context).theme;

    // Get the base64 encoded image string from userData
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
          leading: GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundImage: decodedBytes != null
                    ? MemoryImage(decodedBytes)
                    : const AssetImage(TImages.placeholderimage) as ImageProvider,
                onBackgroundImageError: (_, __) {},
              ),
            ),
          ),
          title: Text(
            'Hello, ${GlobalData.userData?['name'] ?? 'Customer'}',
            style: const TextStyle(fontSize: 16),
            overflow: TextOverflow.ellipsis,
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
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const SizedBox(height: 8.0),
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return FittedBox(
                      child: Center(
                        child: CountdownTimer(
                          endTime: endTime,
                          widgetBuilder: (_, time) {
                            if (time == null) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildTimeBox(0, 'দিন', TColors.tDaysColor),
                                  _buildTimeBox(0, 'ঘন্টা', TColors.tHoursColor),
                                  _buildTimeBox(0, 'মিনিট', TColors.tMinutesColor),
                                  _buildTimeBox(0, 'সেকেন্ড', TColors.tSecondsColor),
                                ],
                              );
                            } else {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildTimeBox(time.days, 'দিন', TColors.tDaysColor),
                                  _buildTimeBox(time.hours, 'ঘন্টা', TColors.tHoursColor),
                                  _buildTimeBox(time.min, 'মিনিট', TColors.tMinutesColor),
                                  _buildTimeBox(time.sec, 'সেকেন্ড', TColors.tSecondsColor),
                                ],
                              );
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8.0),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: _buildCustomImageButton(
                              TImages.buyHotsot,
                              () {
                                setState(() {
                                  _isPressed = !_isPressed;
                                });

                                 Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const BuyHotspotScreen(),
                                    ),
                                  );

                                if (kDebugMode) {
                                  print('Buy HotSpot Button Press');
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 25.0),
                          Expanded(
                            child: _buildCustomImageButton(
                              TImages.cardRecharge,
                              () {
                                setState(() {
                                  _isPressed = !_isPressed;
                                });

                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const CardRechargeScreen(),
                                    ),
                                  );

                                if (kDebugMode) {
                                  print('Custom Image Button Pressed');
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: Colors.blue, // Set the border color here
                            width: 1.0, // Optionally set the width of the border
                          ),
                        ),
                        constraints: const BoxConstraints(minHeight: 300), // Set minimum height here
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 8.0),
                            const Text(
                               textAlign: TextAlign.center,
                              'মেয়াদ থাকার পরেও ওয়াইপাই না চললে\nনিচের বাটনে চাপ দিন।',
                               style: TextStyle(
                                  fontFamily: 'Bangla',
                                  fontSize: 16.0, // Adjust the font size as needed
                                  fontWeight: FontWeight.bold,
                                ),

                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () {
                                if (kDebugMode) {
                                  print('Lottie Button Pressed');
                                }
                              },
                              child: Lottie.asset(
                                'assets/logos/connect.json',
                                height: 250,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Add more rows of buttons if needed
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomImageButton(String imagePath, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.transparent, // Background color for the title
            ),
          ],
          border: Border.all(
            color: Colors.blue, // Set the border color to blue
            width: 1, // Adjust the width of the border if needed
          ),
        ),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
Widget _buildTimeBox(int? time, String label, Color color) {
  double percent = 1.0;
  if (label == 'দিন') {
    percent = time! / 365;
  } else if (label == 'ঘন্টা') {
    percent = time! / 24;
  } else if (label == 'মিনিট') {
    percent = time! / 60;
  } else if (label == 'সেকেন্ড') {
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
          time == 0 ? '০০\n$label' : '${Translate.convertToBangla(time!)}\n$label',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Bangla'),
        ),
        progressColor: color,
        backgroundColor: time == 0 ? color : Colors.grey[200]!,
        circularStrokeCap: CircularStrokeCap.round,
      ),
    ),
  );
}
  Future<bool> _onWillPop() async {
    final result = await QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      confirmBtnColor: TColors.tPrimaryColor,
      text: 'Do you want to exit the app?',
      confirmBtnText: 'Yes',
      cancelBtnText: 'No',
      onConfirmBtnTap: () {
        SystemNavigator.pop(); // Close dialog and
      },
      onCancelBtnTap: () {
        Navigator.of(context).pop(false); // Close dialog and return false
      },
    );
    return result ?? false;
  }
}


