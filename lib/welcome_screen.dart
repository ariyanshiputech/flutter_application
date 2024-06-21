import 'package:flutter/material.dart';
import 'package:flutter_application/singup_screen.dart';
import 'package:flutter_application/utils/constants/colors.dart';
import 'package:flutter_application/utils/constants/image_strings.dart';
import 'package:flutter_application/utils/constants/sizes.dart';
import 'package:flutter_application/utils/constants/text_strings.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    var brightness = mediaQuery.platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode ? TColors.tSecondaryColor : TColors.tPrimaryColor,
      body: Container(
        padding: const EdgeInsets.all(TSizes.tDefaultSize),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image.asset(TImages.lightAppLogo),
            Column(
              children: [
                Text(
                  TTexts.tWelcomeTitle,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  TTexts.tWelcomeSubTitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignUpScreen()),
                      );
                    },
                    child: Text(
                      TTexts.tSignup.toUpperCase(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
