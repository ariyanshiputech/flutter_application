import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/global_data.dart';
import 'package:flutter_application/login_screen.dart';
import 'package:flutter_application/signup_screen.dart';
import 'package:flutter_application/utils/constants/image_strings.dart';
import 'package:flutter_application/utils/constants/sizes.dart';
import 'package:flutter_application/utils/constants/text_strings.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(TSizes.tDefaultSize),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Image with semantic label for screen readers
              Image.asset(
                TImages.lightAppLogo,
                width: 120.0,
                height: 120.0,
                semanticLabel:
                    'App logo representing Lalpool Network', // Detailed semantic label
              ),
              Column(
                children: [
                  Text(
                    TTexts.tWelcomeTitle.toUpperCase(),
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                    semanticsLabel:
                        'Welcome to Lalpool Network', // Updated semanticsLabel
                  ),
                  const SizedBox(height: 10),
                  // Text with semantic label for subtitle
                  Text(
                    TTexts.tWelcomeSubTitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                    semanticsLabel:
                        'Please sign up to continue', // Updated semanticsLabel
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Semantics(
                      button: true,
                      label: 'Continue button',
                      child: ElevatedButton(
                        onPressed: () {
                          if (kDebugMode) {
                            print(GlobalData.demo);
                          }
                          if (GlobalData.demo == 'yes') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignUpScreen(),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15.0), // Ensures touch target
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(8.0), // Rounded corners
                          ),
                        ),
                        child: Text(
                          TTexts.tContinue.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white, // Ensures contrast
                            fontWeight:
                                FontWeight.bold, // Emphasizes button text
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
