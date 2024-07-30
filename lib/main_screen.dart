// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:fancy_bottom_navigation_2/fancy_bottom_navigation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/alert_builder.dart';
import 'package:flutter_application/global_data.dart';
import 'package:flutter_application/home_screen.dart';
import 'package:flutter_application/notification_screen.dart';
import 'package:flutter_application/settings_screen.dart';
import 'package:flutter_application/utils/constants/colors.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:http/http.dart' as http;

class MainScreen extends StatefulWidget {
  final Function(int) onNavigateToPage;

  const MainScreen({super.key, required this.onNavigateToPage});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int currentPage = 0;
  GlobalKey<FancyBottomNavigationState> bottomNavigationKey = GlobalKey();
  String? ipAddress;

  void updatePage(int page) {
    setState(() {
      currentPage = page;
      bottomNavigationKey.currentState?.setPage(page);
    });
  }

  @override
  void initState()
  {
    super.initState();
    _fetchData(); 
  }
 @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchData() async {
    final url = Uri.https('lalpoolnetwork.net', '/api/v2/apps/get_info');
    final NetworkInfo networkInfo = NetworkInfo();
    String? ip = await networkInfo.getWifiIP();
    setState(() {
      ipAddress = ip ?? 'Unknown IP Address';
    });
    // if (mounted){
    //   AlertBuilder.showLoadingDialog(context);

    // } // Add this check to ensure the widget is still mounted
    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'ipAddress': ipAddress,
          'reseller_id' : GlobalData.userData?['reseller_id'],
        }),
      );

      if (response.statusCode == 200) {
        // AlertBuilder.hideLoadingDialog(context);
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        // Handle the fetched data as needed
        setState(() {
          GlobalData.resellerData = responseData;
          // Optionally update other state variables based on the fetched data
        });

        

        if (kDebugMode) {
          print('Data fetched successfully');
          print('Response body: ${response.body}');
        }
      } else {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final snackBar = SnackBar(
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              content: AwesomeSnackbarContent(
                title: 'Opps!',
                message: responseData['message'],
                contentType: ContentType.failure,
              ),
            );
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(snackBar);
        if (kDebugMode) {
          print('Failed to fetch data. Status code: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
      }
    } catch (e) {
      if (mounted) 
      {
        AlertBuilder.hideLoadingDialog(context);

      } // Add this check to ensure the widget is still mounted
      if (kDebugMode) {
        print('Error occurred while fetching data: $e');
      }
    }
  }

@override
  Widget build(BuildContext context) {
    return ThemeSwitchingArea(
      child: Builder(
        builder: (context) {
          // ignore: deprecated_member_use
          return WillPopScope(
            onWillPop: () async {
              return true; // Disable back button
            },
            child: Scaffold(
              body: _getPageContent(currentPage),
              bottomNavigationBar: FancyBottomNavigation(
                key: bottomNavigationKey,
                circleColor: TColors.tPrimaryColor,
                textColor: TColors.tPrimaryColor,
                initialSelection: currentPage,
                tabs: [
                  TabData(iconData: LineAwesomeIcons.home_solid, title: ""),
                  TabData(iconData: LineAwesomeIcons.cog_solid, title: ""),
                  TabData(iconData: LineAwesomeIcons.bell, title: ""),
                ],
                onTabChangedListener: (position) {
                  setState(() {
                    currentPage = position;
                  });
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _getPageContent(int page) {
    switch (page) {
      case 0:
        return HomeScreen(onNavigateToPage: updatePage);
      case 1:
      return SettingsScreen(onNavigateToPage: updatePage);
      case 2:
      return NotificationScreen(onNavigateToPage: updatePage);
      default:
        return const Text('404 Page');
    }
  }
}
