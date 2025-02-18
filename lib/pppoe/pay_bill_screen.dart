import 'dart:convert';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/alert_builder.dart';
import 'package:flutter_application/global_data.dart';
import 'package:flutter_application/main_screen.dart';
import 'package:flutter_application/utils/constants/colors.dart';
import 'package:flutter_application/utils/snackbar_utils.dart';
import 'package:flutter_application/utils/theme/theme.dart';
import 'package:flutter_application/pppoe/payment_invoice_screen.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application/utils/constants/sizes.dart';

class PayBillScreen extends StatefulWidget {
  const PayBillScreen({super.key});

  @override
  PayBillScreenState createState() => PayBillScreenState();
}

class PayBillScreenState extends State<PayBillScreen> {
  bool _isDataFetched = false;

  @override
  void initState() {
    super.initState();
    // Initialization logic that doesn't depend on context
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ensure _fetchData runs only once
    if (!_isDataFetched) {
      _isDataFetched = true;

      // Delay context-dependent operations to after widget build
      Future.microtask(() => _fetchData());
    }
  }

  Future<void> _fetchData() async {
    final url = Uri.https('lalpoolnetwork.net', '/api/v2/apps/get_pppoe_info');

    try {
      AlertBuilder.showLoadingDialog(context); // Now safe to call
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'app_id': GlobalData.userData?['app_id'],
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        setState(() {
          GlobalData.pppoeData = responseData['pppoe'];
          GlobalData.pppoesBills = responseData['bills'];
        });
      } else {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        SnackbarUtils.showSnackBar(
          context,
          'Oops',
          responseData['message'],
          ContentType.failure,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred while fetching data: $e');
      }
    } finally {
      AlertBuilder.hideLoadingDialog(context);
    }
  }

  Future<bool> _onWillPop() async {
    _navigateToMainScreen();
    return false;
  }

  void _navigateToMainScreen() {
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
            title: const Text(
              'Pay Your Bill',
              style: TextStyle(fontSize: 16),
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
          body: const SingleChildScrollView(
            padding: EdgeInsets.all(TSizes.tDefaultSize),
            child: FormSection(),
          ),
        ),
      ),
    );
  }
}

class FormSection extends StatefulWidget {
  const FormSection({super.key});

  @override
  FormSectionState createState() => FormSectionState();
}

class FormSectionState extends State<FormSection> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String runningMonth;
  late String runningYear;
  String? selectedMonth;
  String? selectedYear;

  @override
  void initState() {
    super.initState();
    _initializeRunningDate();
    _initializeDefaultSelection();
  }

  void _initializeRunningDate() {
    final now = DateTime.now();
    runningMonth = _getMonthName(now.month);
    runningYear = now.year.toString();

    if (kDebugMode) {
      print("Running Month: $runningMonth, Running Year: $runningYear");
    }
  }

  void _initializeDefaultSelection() {
    final bills = GlobalData.pppoesBills ?? [];
    if (bills.isNotEmpty) {
      // Attempt to find the running month and year in the bills
      final runningBill = bills.firstWhere(
        (bill) =>
            bill['month'] == runningMonth &&
            bill['year'].toString() == runningYear,
        orElse: () => null,
      );

      if (runningBill != null) {
        selectedMonth = runningBill['month'];
        selectedYear = runningBill['year'].toString();
      } else {
        // If no running month is found, default to the first available bill
        selectedMonth = bills[0]['month'];
        selectedYear = bills[0]['year'].toString();
      }
    }
  }

  String _getMonthName(int month) {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return monthNames[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final isPlatformDark =
        // ignore: deprecated_member_use
        WidgetsBinding.instance.window.platformBrightness == Brightness.dark;
    final initTheme =
        isPlatformDark ? TAppTheme.darkTheme : TAppTheme.lightTheme;

    final bills = GlobalData.pppoesBills ?? [];
    Map<String, List<Map<String, dynamic>>> groupedByYear = {};
    for (var bill in bills) {
      final year = bill['year'].toString();
      if (groupedByYear.containsKey(year)) {
        groupedByYear[year]!.add(bill);
      } else {
        groupedByYear[year] = [bill];
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
                  const Text(
                    'PAY YOUR BILL',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                  ),
                  const Text(
                    '(Make your journey easy with our first internet service.)',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: TSizes.tFormHeight - 10),

                  // Dynamically render year and months
                  ...groupedByYear.entries.map((entry) {
                    final year = entry.key;
                    final yearBills = entry.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            year,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10.0,
                            mainAxisSpacing: 10.0,
                            childAspectRatio: 2.0,
                          ),
                          itemCount: yearBills.length,
                          itemBuilder: (BuildContext context, int index) {
                            final month = yearBills[index]['month'];
                            bool isSelected =
                                selectedMonth == month && selectedYear == year;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedMonth = month;
                                  selectedYear = year;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.blue.shade100
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(
                                    color:
                                        isSelected ? Colors.blue : Colors.grey,
                                    width: 1.0,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  month,
                                  style: TextStyle(
                                    color:
                                        isSelected ? Colors.blue : Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    );
                  }),

                  // Show total amount or 0.00 if no month is selected
                  Center(
                    child: SizedBox(
                      child: Text(
                        selectedMonth == null
                            ? "৳ 0.00"
                            : "৳ ${_calculateTotalAmount().toStringAsFixed(2)}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                  ),

                  // Hide "NEXT" button if no month is selected
                  if (selectedMonth != null)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final totalAmount = _calculateTotalAmount();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentInvoiceScreen(
                                totalAmount: totalAmount,
                              ),
                            ),
                          );
                        },
                        child: const Text("NEXT"),
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

  double _calculateTotalAmount() {
    final bills = GlobalData.pppoesBills ?? [];
    double totalAmount = 0.0;

    for (var bill in bills) {
      final amount = bill['amount'];

      if (amount is int || amount is double) {
        totalAmount += amount;
      }
    }
    return totalAmount;
  }
}
