import 'dart:convert';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application/global_data.dart';
import 'package:flutter_application/pppoe/pay_bill_screen.dart';
import 'package:flutter_application/profile_screen.dart';
import 'package:flutter_application/utils/constants/colors.dart';
import 'package:flutter_application/utils/constants/image_strings.dart';
import 'package:flutter_application/utils/constants/translate.dart';
import 'package:flutter_application/utils/theme/theme.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:toast/toast.dart';
import 'package:in_app_update/in_app_update.dart'; // Import in_app_update
import 'package:webview_flutter/webview_flutter.dart'; // Import webview_flutter

class PppoeHomeScreen extends StatefulWidget {
  final Function(int) onNavigateToPage;

  const PppoeHomeScreen({super.key, required this.onNavigateToPage});

  @override
  State<PppoeHomeScreen> createState() => PppoeHomeScreenState();
}

class PppoeHomeScreenState extends State<PppoeHomeScreen> {
  int currentPage = 1; // Set to 1 for Profile tab
  GlobalKey bottomNavigationKey = GlobalKey();
  int endTime = DateTime.parse(GlobalData.pppoeData?['billing_expire_date'])
      .millisecondsSinceEpoch;
  bool _isPressed = false;
  bool lottieAnimate = false;

  @override
  void initState() {
    super.initState();
    _checkForUpdates(); // Check for updates
    WebView.platform = SurfaceAndroidWebView(); // Initialize WebView
    if (kDebugMode) {
      // ignore: prefer_interpolation_to_compose_strings
      print(GlobalData.pppoeData?['billing_expire_date']);
    }
  }

  Future<void> _checkForUpdates() async {
    try {
      final updateInfo = await InAppUpdate.checkForUpdate();

      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        // Perform a flexible update
        await InAppUpdate.startFlexibleUpdate().then((_) {
          // Complete the update after download
          InAppUpdate.completeFlexibleUpdate();
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to check for updates: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeModelInheritedNotifier.of(context).theme;
    ToastContext().init(context);
    String? base64Image = GlobalData.userData?['profile'];
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
                    : const AssetImage(TImages.user) as ImageProvider,
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
          backgroundColor: TColors
              .tPrimaryColor, // Set AppBar background color to the theme's primary color
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
                                  _buildTimeBox(
                                      0, 'ঘন্টা', TColors.tHoursColor),
                                  _buildTimeBox(
                                      0, 'মিনিট', TColors.tMinutesColor),
                                  _buildTimeBox(
                                      0, 'সেকেন্ড', TColors.tSecondsColor),
                                ],
                              );
                            } else {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildTimeBox(
                                      time.days, 'দিন', TColors.tDaysColor),
                                  _buildTimeBox(
                                      time.hours, 'ঘন্টা', TColors.tHoursColor),
                                  _buildTimeBox(
                                      time.min, 'মিনিট', TColors.tMinutesColor),
                                  _buildTimeBox(time.sec, 'সেকেন্ড',
                                      TColors.tSecondsColor),
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
                              TImages.payBill,
                              () {
                                setState(() {
                                  _isPressed = !_isPressed;
                                });

                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const PayBillScreen(),
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

                                // Navigator.pushReplacement(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) =>
                                //         const CardRechargeScreen(),
                                //   ),
                                // );

                                if (kDebugMode) {
                                  print('Custom Image Button Pressed');
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      buildStylishInfoGrid(),

                      //
                      //
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

  Widget _buildStylishInfoGridItem({
    required String title,
    required String value,
    required String iconPath,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              iconPath,
              height: 24,
              width: 24,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Bangla',
                  color: Colors.blueGrey.shade700,
                ),
              ),
              Text(
                Translate.convertToBangla(value),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Bangla',
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildStylishInfoGrid() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildStylishInfoGridItem(
                  title: 'মাসিক বিল',
                  value: '৳ ${GlobalData.pppoeData!['amount']}',
                  iconPath: 'assets/icons/monthly_bill.png',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStylishInfoGridItem(
                  title: 'বকেয়া',
                  value:
                      '৳ ${_calculateTotalPppoesBills()}', // Dynamically calculate and show the total
                  iconPath: 'assets/icons/balance_due.png',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildStylishInfoGridItem(
                  title: 'প্যাকেজ',
                  value: 'নিয়মিত',
                  iconPath: 'assets/icons/package.png',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStylishInfoGridItem(
                  title: 'শেষ তারিখ',
                  value: DateFormat('dd-MM-yyyy').format(DateTime.parse(
                      GlobalData.pppoeData?['billing_expire_date'])),
                  iconPath: 'assets/icons/expire_date.png',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _calculateTotalPppoesBills() {
    // Ensure GlobalData.pppoesBills is not null and calculate the total
    List<Map<String, dynamic>> pppoesBills = (GlobalData.pppoesBills ?? [])
        .whereType<
            Map<String,
                dynamic>>() // Ensure each item is a Map<String, dynamic>
        .toList();

    double total = pppoesBills.fold(0.0, (sum, bill) {
      final amount = bill['amount'];
      return sum + (amount is num ? amount.toDouble() : 0.0);
    });

    // Safely handle the type conversion for GlobalData.pppoeData!['amount']
    double pppoeAmount = (GlobalData.pppoeData?['amount'] is num)
        ? (GlobalData.pppoeData!['amount'] as num).toDouble()
        : 0.0;

    // If GlobalData.pppoeData!['amount'] is less than the total, show 0.00
    if (pppoeAmount < total) {
      return '0.00';
    }

    // Format the total to remove .0 if it's a whole number
    return total % 1 == 0 ? total.toInt().toString() : total.toStringAsFixed(2);
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
            time == 0
                ? '০০\n$label'
                : '${Translate.convertToBangla(time!)}\n$label',
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Bangla'),
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
        SystemNavigator.pop(); // Close dialog and exit app
      },
      onCancelBtnTap: () {
        Navigator.of(context).pop(false); // Close dialog and return false
      },
    );
    return result ?? false;
  }

  // Method to inject JavaScript and remove the header, branding, and display the speedtest logo
}
