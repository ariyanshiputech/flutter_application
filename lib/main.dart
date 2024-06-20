import 'dart:io';

import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/welcome_screen.dart';
import 'package:flutter_application/utils/theme/theme.dart';

void main() {
    HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
   return ThemeProvider(
      initTheme: TAppTheme.lightTheme, // Initial theme
      builder: (_, myTheme) {
        return MaterialApp(
          title: "Lalpool Wifi ZOne",
          themeMode: ThemeMode.light,
          theme: TAppTheme.lightTheme,
          darkTheme: TAppTheme.darkTheme,
          debugShowCheckedModeBanner: false,
          // initialBinding: GeneralBindings(),
          home: const WelcomeScreen(),
          routes: {
            '/welcome': (context) => const WelcomeScreen(),
          },
        );
      });
    
     
  }
}

 class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}
