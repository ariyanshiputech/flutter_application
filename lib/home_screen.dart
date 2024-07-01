import 'dart:convert';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application/global_data.dart';
import 'package:flutter_application/payment.dart';
import 'package:flutter_application/profile_screen.dart';
import 'package:flutter_application/utils/constants/colors.dart';
import 'package:flutter_application/utils/constants/image_strings.dart';
import 'package:flutter_application/utils/theme/theme.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

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
        body: Container(
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
                                _buildTimeBox(0, 'Days', TColors.tDaysColor),
                                _buildTimeBox(0, 'Hours', TColors.tHoursColor),
                                _buildTimeBox(0, 'Minutes', TColors.tMinutesColor),
                                _buildTimeBox(0, 'Seconds', TColors.tSecondsColor),
                              ],
                            );
                          } else {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildTimeBox(time.days, 'Days', TColors.tDaysColor),
                                _buildTimeBox(time.hours, 'Hours', TColors.tHoursColor),
                                _buildTimeBox(time.min, 'Minutes', TColors.tMinutesColor),
                                _buildTimeBox(time.sec, 'Seconds', TColors.tSecondsColor),
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
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  children: [
                    _buildCustomImageButton(
                      TImages.buyHotsot, // Path to your custom image
                      'BUY HOTSPOT',
                      () {  
                        setState(() {
                          _isPressed = !_isPressed;
                        });
                        if (kDebugMode) {
                          print('Custom Image Button Pressed');
                        }
                      },
                    ),
                    _buildCustomImageButton(
                      TImages.banner1, // Path to your custom image
                      'CARD RECHARGE',
                      () {
                        setState(() {
                          _isPressed = !_isPressed;
                        });
                        if (kDebugMode) {
                          print('Custom Image Button Pressed');
                        }
                      },
                    ),
                    // Add more custom image buttons or other widgets here
                  ],
                ),
              ),
              const SizedBox(height: 8.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PaymentScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "SIGN UP",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomImageButton(String imagePath, String title, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: Colors.transparent,
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: TColors.tPrimaryColor.withOpacity(1.0), // Background color for the title
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(12.0),
                  ),
                ),
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeBox(int? time, String label, Color color) {
    double percent = 1.0;
    if (label == 'Days') {
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
            time == 0 ? '00\n$label' : '$time\n$label',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13),
          ),
          progressColor: color,
          backgroundColor: time == null ? Colors.grey[200]! : color,
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
