// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/alert_builder.dart';
import 'package:flutter_application/global_data.dart';
import 'package:flutter_application/utils/constants/colors.dart';
import 'package:flutter_application/utils/theme/theme.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application/utils/constants/sizes.dart';
import 'package:network_info_plus/network_info_plus.dart';

import 'main_screen.dart';

class CardRechargeScreen extends StatefulWidget {
  const CardRechargeScreen({super.key});

  @override
  CardRechargeScreenState createState() => CardRechargeScreenState();
}

class CardRechargeScreenState extends State<CardRechargeScreen> {
  final TextEditingController cardController = TextEditingController();
  final TextEditingController _ipAddressController = TextEditingController();
  final TextEditingController macController = TextEditingController();
  String? ipAddress;

  @override
  void initState() {
    if (kDebugMode) {
      print(GlobalData.userData?['reseller_id']);
    }

    super.initState();
    _getIPAddress();
    _fetchData();

    // Add listener to validityController
  }

  @override
  void dispose() {
    cardController.dispose();
    _ipAddressController.dispose();
    macController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    final url = Uri.https('lalpoolnetwork.net', '/api/v2/apps/get_info');
    final NetworkInfo networkInfo = NetworkInfo();
    String? ip = await networkInfo.getWifiIP();
    setState(() {
      ipAddress = ip ?? 'Unknown IP Address';
    });
    try {
      AlertBuilder.showLoadingDialog(context);
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
        AlertBuilder.hideLoadingDialog(context);
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        // Handle the fetched data as needed
        setState(() {
          GlobalData.resellerData = responseData;
          macController.text = GlobalData.resellerData?['mac_address'];
          // Optionally update other state variables based on the fetched data
        });

        // final snackBar = SnackBar(
        //       elevation: 0,
        //       behavior: SnackBarBehavior.floating,
        //       backgroundColor: Colors.transparent,
        //       content: AwesomeSnackbarContent(
        //         title: 'Yeah!',
        //         message: responseData['message'],
        //         contentType: ContentType.success,
        //       ),
        //     );
        //     ScaffoldMessenger.of(context)
        //       ..hideCurrentSnackBar()
        //       ..showSnackBar(snackBar);

        if (kDebugMode) {
          print('Data fetched successfully');
          print('Response body: ${response.body}');
        }
      } else {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        AlertBuilder.hideLoadingDialog(context);
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
        AlertBuilder.hideLoadingDialog(context);
      if (kDebugMode) {
        print('Error occurred while fetching data: $e');
      }
    }
  }

  Future<void> _getIPAddress() async {
    final NetworkInfo networkInfo = NetworkInfo();
    String? ip = await networkInfo.getWifiIP();
    setState(() {
      _ipAddressController.text = ip ?? 'Unknown IP Address';
    });
  }

  Future<bool> _onWillPop() async {
    _navigateToMainScreen();
    return false; // Prevents the default back button behavior
  }

  void _navigateToMainScreen() {
    // ignore: avoid_types_as_parameter_names
    Get.off(() => MainScreen(onNavigateToPage: (int) => 1));
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeModelInheritedNotifier.of(context).theme;

    return ThemeSwitchingArea(
      // ignore: deprecated_member_use
      child: WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _navigateToMainScreen,
            ),
            title: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  'Card Recharge',
                  style: TextStyle(fontSize: 16),
                ),
              ),
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
            backgroundColor: TColors.tPrimaryColor,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(TSizes.tDefaultSize),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FormSection(
                  ipAddressController: _ipAddressController,
                  cardController: cardController,
                  macController: macController, 
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FormSection extends StatefulWidget {
  final TextEditingController ipAddressController;
  final TextEditingController cardController;
  final TextEditingController macController;
  final String? macAddress;
  const FormSection({
    super.key,
    required this.ipAddressController,
    required this.macController, this.macAddress,
    required this.cardController, 
  });

  @override
  FormSectionState createState() => FormSectionState();
}

class FormSectionState extends State<FormSection> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> submit() async {
    final url = Uri.https('lalpoolnetwork.net', '/api/v2/apps/card_recharge');
    
    AlertBuilder.showLoadingDialog(context); // Show loading dialog

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'seller_id': GlobalData.userData?['reseller_id'],
          'code': widget.cardController.text,
          'mac_address': widget.macController.text,
          'ip_address': widget.ipAddressController.text,
          'user_id': GlobalData.userData?['id'], // Replace with actual user ID
          'device_key': GlobalData.userData?['device_key'], // Replace with actual device key
        }),
      );


      if (response.statusCode == 200) {
      AlertBuilder.hideLoadingDialog(context); // Hide loading dialog
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        GlobalData.userData = responseData['user'];
        final snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Success!',
            message: responseData['message'],
            contentType: ContentType.success,
          ),
        );
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
      } else if (response.statusCode == 422) {
      AlertBuilder.hideLoadingDialog(context); // Hide loading dialog in case of error
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Error!',
            message: responseData['message'] ?? 'Validation failed',
            contentType: ContentType.failure,
          ),
        );
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
      } else {
        AlertBuilder.hideLoadingDialog(context);
        final snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Error!',
            message: 'Something went wrong',
            contentType: ContentType.failure,
          ),
        );
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
      }
    } catch (e) {
      AlertBuilder.hideLoadingDialog(context); // Hide loading dialog in case of error
      final snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Error!',
          message: 'An error occurred: $e',
          contentType: ContentType.failure,
        ),
      );
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPlatformDark =
        // ignore: deprecated_member_use
        WidgetsBinding.instance.window.platformBrightness == Brightness.dark;
    final initTheme = isPlatformDark ? TAppTheme.darkTheme : TAppTheme.lightTheme;

    return Center(
      child: ThemeProvider(
        initTheme: initTheme,
        builder: (_, myTheme) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('CARD RECHARGE',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
                  const Text(
                      '(Make your Journey easy with connect out first internet service.)',
                      style: TextStyle(
                          fontWeight: FontWeight.normal, fontSize: 12)),
                  const SizedBox(height: TSizes.tFormHeight - 10),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: widget.cardController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Card Number",
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter card number';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Invalid card number format';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: widget.ipAddressController,
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: "IP Address",
                      prefixIcon: const Icon(Icons.network_check),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: widget.macController,
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: "MAC Address",
                      prefixIcon: const Icon(Icons.perm_device_information),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await submit();
                        }
                      },
                      child: const Text("RECHARGE"),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
