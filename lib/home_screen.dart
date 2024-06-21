import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/utils/constants/colors.dart';
import 'package:flutter_application/utils/theme/theme.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class HomeScreen extends StatefulWidget {
  final Map<dynamic, dynamic> userData;
  const HomeScreen({super.key, required this.userData});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int currentPage = 1; // Set to 1 for Profile tab
  GlobalKey bottomNavigationKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
          final theme = ThemeModelInheritedNotifier.of(context).theme;
          // ignore: deprecated_member_use
          return WillPopScope(
            onWillPop: _onWillPop,
            child: Scaffold(
              appBar: AppBar(
                leading: GestureDetector(
                  onTap: () {
                    // You can implement navigation logic if needed
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(
                        widget.userData['profile'] ?? 'https://via.placeholder.com/150',
                      ),
                      onBackgroundImageError: (_, __) {},
                    ),
                  ),
                ),
                title: Text(
                  'Hello, ${widget.userData['name'] ?? 'Customer'}',
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
              body: const Center(
                child: Text('Home Screen'),
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
        Navigator.of(context).pop(true); // Close dialog and return true
      },
      onCancelBtnTap: () {
        Navigator.of(context).pop(false); // Close dialog and return false
      },
    );
    return result ?? false;
  }
}
