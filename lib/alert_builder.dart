import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AlertBuilder {
  // Method to show the loading dialog
  static void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // ignore: deprecated_member_use
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            backgroundColor: Colors.transparent,
            content: Center(
              child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                    child: Lottie.asset(
                          'assets/logos/round_loading.json',
                          repeat: true, // Set repeat to false to play only once
                        ),
                    ),
                    ),
                  
            ),
          ),
        );
      },
    );
  }

  // Method to hide the loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}
