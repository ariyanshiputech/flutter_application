import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/utils/theme/theme.dart';

class HomeScreen extends StatefulWidget {
  final Map<dynamic, dynamic> userData;
  const HomeScreen({super.key, required this.userData});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    final isPlatformDark = WidgetsBinding.instance.window.platformBrightness == Brightness.dark;
    final initTheme = isPlatformDark ? TAppTheme.darkTheme : TAppTheme.lightTheme;
    return ThemeProvider(
      initTheme: initTheme,
      builder: (_, myTheme) {
        // ignore: deprecated_member_use
        return WillPopScope(
          onWillPop: () async {
            return false; // Disable back button
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Home Screen'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('User Data:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text('Name: ${widget.userData['name'] ?? 'N/A'}'),
                  Text('Phone: ${widget.userData['phone'] ?? 'N/A'}'),
                  // Display other user data fields as needed
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
