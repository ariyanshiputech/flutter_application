import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/splash_screen.dart';
import 'package:flutter_application/utils/theme/theme.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      initTheme: TAppTheme.lightTheme, // Set your initial theme
      builder: (context, myTheme) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: myTheme,
          home: const SplashScreen(),
        );
      },
    );
  }
}
