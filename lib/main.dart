import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application/welcome_screen.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:flutter_application/utils/constants/text_strings.dart';
import 'package:flutter_application/utils/theme/theme.dart';
import 'package:lehttp_overrides/lehttp_overrides.dart';

void main() {
  if (Platform.isAndroid) {
    HttpOverrides.global = LEHttpOverrides();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return GetMaterialApp(
      title: TTexts.appName,
      themeMode: ThemeMode.system,
      theme: TAppTheme.lightTheme,
      darkTheme: TAppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      // initialBinding: GeneralBindings(),
       home: const WelcomeScreen(),
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
      },
    );
  
    
     
  }
}
