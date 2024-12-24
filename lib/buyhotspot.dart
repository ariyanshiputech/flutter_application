// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:ariyanpay/ariyanpay.dart';
import 'package:ariyanpay/models/customer_model.dart';
import 'package:ariyanpay/models/request_response.dart';
import 'package:ariyanpay/widget/custom_snackbar.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/alert_builder.dart';
import 'package:flutter_application/global_data.dart';
import 'package:flutter_application/utils/constants/colors.dart';
import 'package:flutter_application/utils/snackbar_utils.dart';
import 'package:flutter_application/utils/theme/theme.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application/utils/constants/sizes.dart';
import 'package:network_info_plus/network_info_plus.dart';

import 'main_screen.dart';

class BuyHotspotScreen extends StatefulWidget {
  const BuyHotspotScreen({super.key});

  @override
  BuyHotspotScreenState createState() => BuyHotspotScreenState();
}

class BuyHotspotScreenState extends State<BuyHotspotScreen> {
  final TextEditingController validityController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController _ipAddressController = TextEditingController();
  final TextEditingController macController = TextEditingController();
  String? ipAddress;
  bool isPaymentEnabled = false; // Track button enabled state

  @override
  void initState() {
    if (kDebugMode) {
      print(GlobalData.userData?['reseller_id']);
    }

    super.initState();
    _getIPAddress();
    _fetchData();

    // Add listener to validityController
    validityController.addListener(_calculateAmount);
  }

  @override
  void dispose() {
    validityController.removeListener(_calculateAmount);
    validityController.dispose();
    amountController.dispose();
    _ipAddressController.dispose();
    macController.dispose();
    super.dispose();
  }

  void _calculateAmount() {
    final int validity = int.tryParse(validityController.text) ?? 0;
    final int hotPrice = GlobalData.resellerData?['hot_price'] ?? 0;

    setState(() {
      if (kDebugMode) {
        print(GlobalData.resellerData?['hot_price']);
      }
      amountController.text = (validity * hotPrice).toString();
      isPaymentEnabled = amountController.text.isNotEmpty &&
          int.parse(amountController.text) > 0;
    });
  }

  Future<void> _fetchData() async {
    final url = Uri.https('lalpoolnetwork.net', '/api/v2/apps/get_info');
    final NetworkInfo networkInfo = NetworkInfo();
    String? ip = await networkInfo.getWifiIP();
    setState(() {
      ipAddress = ip ?? 'Unknown IP Address';
    });
    AlertBuilder.showLoadingDialog(context);
    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'ipAddress': ipAddress,
          'reseller_id': GlobalData.userData?['reseller_id'],
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

        if (kDebugMode) {
          print('Data fetched successfully');
          print('Response body: ${response.body}');
        }
      } else {
        AlertBuilder.hideLoadingDialog(context);
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        SnackbarUtils.showSnackBar(
            context, 'Opps', responseData['message'], ContentType.failure);
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
                  'Buy Hotspot',
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
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(TSizes.tDefaultSize),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FormSection(
                    ipAddressController: _ipAddressController,
                    validityController: validityController,
                    macController: macController,
                    amountController: amountController,
                    isPaymentEnabled: isPaymentEnabled,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FormSection extends StatefulWidget {
  final TextEditingController ipAddressController;
  final TextEditingController validityController;
  final TextEditingController macController;
  final TextEditingController amountController;
  final String? macAddress;
  final bool isPaymentEnabled;
  const FormSection({
    super.key,
    required this.ipAddressController,
    required this.macController,
    this.macAddress,
    required this.validityController,
    required this.amountController,
    required this.isPaymentEnabled,
  });

  @override
  FormSectionState createState() => FormSectionState();
}

class FormSectionState extends State<FormSection> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final isPlatformDark =
        // ignore: deprecated_member_use
        WidgetsBinding.instance.window.platformBrightness == Brightness.dark;
    final initTheme =
        isPlatformDark ? TAppTheme.darkTheme : TAppTheme.lightTheme;

    void proccessPayment(dynamic data) async {
      final url = Uri.https(
          'lalpoolnetwork.net', '/api/v2/apps/proccess_online_hotspot');

      try {
        final response = await http.post(
          url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<dynamic, dynamic>{
            'invoice_id': data.invoiceId,
            'reseller_id': GlobalData.userData?['reseller_id'],
            'user_id': GlobalData.userData?['id'],
            'device_key': data.valueA,
            'amount': data.amount,
            'hotspot_sell_price': data.valueD,
            'validity': data.valueG,
            'mac_address': data.valueC,
          }),
        );
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (response.statusCode == 200) {
          GlobalData.userData = responseData['user'];
          SnackbarUtils.showSnackBar(
              context, 'Success', responseData['message'], ContentType.success);
          // Show success message
        } else {
          // Show failure message
          SnackbarUtils.showSnackBar(
            context,
            'Error',
            responseData['message'],
            ContentType.failure,
          );
        }
      } catch (e) {
        SnackbarUtils.showSnackBar(
          context,
          'Error',
          'An error occurred: $e',
          ContentType.failure,
        );

        if (kDebugMode) {
          print('Error occurred while processing payment: $e');
        }
      }
    }

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
                  const Text('BUY HOTSPOT',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
                  const Text(
                      '(Make your Journey easy with connect out first internet service.)',
                      style: TextStyle(
                          fontWeight: FontWeight.normal, fontSize: 12)),
                  const SizedBox(height: TSizes.tFormHeight - 10),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: widget.validityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Validity",
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a number';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Invalid number format';
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
                  TextFormField(
                    controller: widget.amountController,
                    readOnly: true,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Amount",
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
                      onPressed: widget.isPaymentEnabled
                          ? () async {
                              if (_formKey.currentState!.validate()) {
                                try {
                                  AlertBuilder.showLoadingDialog(context);
                                  final response =
                                      await Ariyanpay.createPayment(
                                    context: context,
                                    customer: CustomerDetails(
                                      fullName: GlobalData.userData?['name'],
                                      cusPhone: GlobalData.userData?['phone'],
                                    ),
                                    amount: widget.amountController.text,
                                    valueA: GlobalData.userData?['device_key'],
                                    valueB: widget.ipAddressController.text,
                                    valueC: widget.macController.text,
                                    valueD: GlobalData
                                        .resellerData?['hotspot_sell_price'],
                                    valueE: GlobalData.userData?['reseller_id'],
                                    valueF: GlobalData.userData?['id'],
                                    valueG: widget.validityController.text,
                                  );
                                  AlertBuilder.hideLoadingDialog(context);

                                  if (response.status ==
                                      ResponseStatus.completed) {
                                    proccessPayment(response);
                                  } else if (response.status ==
                                      ResponseStatus.canceled) {
                                    SnackbarUtils.showSnackBar(
                                      context,
                                      'Error',
                                      'Payment Canceled',
                                      ContentType.failure,
                                    );
                                  } else if (response.status ==
                                      ResponseStatus.pending) {
                                    SnackbarUtils.showSnackBar(
                                      context,
                                      'Error',
                                      'Payment Pending',
                                      ContentType.failure,
                                    );
                                  }
                                } catch (e) {
                                  snackBar('An error occurred: $e', context);
                                }
                              }
                            }
                          : null, // Disable button if isPaymentEnabled is false
                      child: const Text("PAYMENT NOW"),
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
