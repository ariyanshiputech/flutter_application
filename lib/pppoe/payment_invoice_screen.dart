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
import 'package:flutter_application/main_screen.dart';
import 'package:flutter_application/utils/constants/colors.dart';
import 'package:flutter_application/utils/snackbar_utils.dart';
import 'package:flutter_application/utils/theme/theme.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class PaymentInvoiceScreen extends StatefulWidget {
  final double totalAmount;

  const PaymentInvoiceScreen({required this.totalAmount, super.key});

  @override
  PaymentInvoiceScreenState createState() => PaymentInvoiceScreenState();
}

class PaymentInvoiceScreenState extends State<PaymentInvoiceScreen> {
  @override
  void initState() {
    super.initState();
  }

  Future<bool> _onWillPop() async {
    _navigateToMainScreen();
    return false;
  }

  void _navigateToMainScreen() {
    Get.off(() => MainScreen(onNavigateToPage: (int) => 1));
  }

  double _calculateTotalAmount() {
    final bills = GlobalData.pppoesBills ?? [];
    double totalAmount = 0.0;

    for (var bill in bills) {
      final amount = bill['amount'];
      if (amount is num) {
        totalAmount += amount.toDouble();
      } else if (kDebugMode) {
        print("Invalid amount format for bill: $bill");
      }
    }

    if (kDebugMode) {
      print("Total Amount from All Bills: $totalAmount");
    }
    return totalAmount;
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeModelInheritedNotifier.of(context).theme;
    final totalAmount =
        widget.totalAmount > 0 ? widget.totalAmount : _calculateTotalAmount();
    final bills = GlobalData.pppoesBills ?? [];

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
            title: const Text(
              'Invoice',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Invoice Summary',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildInvoiceDetails(),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: bills.length,
                    itemBuilder: (context, index) {
                      final bill = bills[index];
                      final month = bill['month'] ?? 'Unknown Month';
                      final year = bill['year']?.toString() ?? 'Unknown Year';
                      final description = '$month-$year';
                      final amount = bill['amount'] ?? 0.0;

                      return Card(
                        color: TColors.tWhiteColor.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        elevation: 1,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shadowColor: TColors.accent.withOpacity(0.2),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor:
                                        TColors.tPrimaryColor.withOpacity(1),
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        description,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '৳ ${amount.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Text(
                                '৳ ${amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: TColors.tPrimaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(
                  thickness: 1,
                  color: TColors.black,
                ),
                _buildTotalAmountRow(totalAmount),
                const SizedBox(height: 20),
                _buildPaymentButton(totalAmount),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceDetails() {
    return Column(
      children: [
        _buildDetailRow(
            'Invoice To:', GlobalData.userData?["name"] ?? 'Unknown'),
        _buildDetailRow('Phone:', GlobalData.userData?["phone"] ?? 'Unknown'),
        _buildDetailRow(
            'Username:', GlobalData.pppoeData?["username"] ?? 'Unknown'),
        _buildDetailRow(
            'Password:', GlobalData.pppoeData?["password"] ?? 'Unknown'),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalAmountRow(double totalAmount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Total:',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '৳ ${totalAmount.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentButton(double totalAmount) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          if (totalAmount > 0) {
            try {
              AlertBuilder.showLoadingDialog(context);
              final response = await Ariyanpay.createPayment(
                context: context,
                customer: CustomerDetails(
                  fullName: GlobalData.userData?['name'],
                  cusPhone: GlobalData.userData?['phone'],
                ),
                amount: widget.totalAmount.toStringAsFixed(2),
                valueA: GlobalData.userData?['device_key'],
                valueB: GlobalData.pppoeData?['id'],
                valueC: totalAmount,
                valueD: GlobalData.userData?['reseller_id'],
                valueE: GlobalData.userData?['reseller_id'],
                valueF: GlobalData.userData?['id'],
              );
              AlertBuilder.hideLoadingDialog(context);

              if (response.status == ResponseStatus.completed) {
                proccessPayment(response);
              } else if (response.status == ResponseStatus.canceled) {
                SnackbarUtils.showSnackBar(
                  context,
                  'Error',
                  'Payment Canceled',
                  ContentType.failure,
                );
              } else if (response.status == ResponseStatus.pending) {
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

            if (kDebugMode) {
              print("Proceeding to payment with total: ৳$totalAmount");
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('No amount to pay!'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: const Text("PAYMENT NOW"),
      ),
    );
  }

  void proccessPayment(dynamic data) async {
    final url =
        Uri.https('lalpoolnetwork.net', '/api/v2/apps/proccess_online_bill');

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
          'pppoe_id': data.valueB,
          'amount': data.amount,
        }),
      );
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        GlobalData.pppoeData = responseData['pppoe'];
        SnackbarUtils.showSnackBar(
            context, 'Success', responseData['message'], ContentType.success);

        _navigateToMainScreen();
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
}
