import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'web_view.dart';

enum EventState { success, fail, cancel, error, backButtonPressed }

typedef PaymentStatus<T> = void Function(T value);
typedef IsLoadingStatus<T> = void Function(T value);
typedef ReadUrl<T> = void Function(T value);

typedef Status<A, B> = void Function(A status, B message);

class Aamarpay extends StatefulWidget {
  final bool isSandBox;
  final String successUrl;
  final String failUrl;
  final String cancelUrl;
  final String storeID;
  final String transactionID;
  final String? transactionAmount;
  final TextEditingController? transactionAmountFromTextField;
  final String signature;
  final String? description;
  final String? customerName;
  final String? customerEmail;
  final String customerMobile;
  final PaymentStatus<String>? paymentStatus;
  final IsLoadingStatus<bool>? isLoading;
  final ReadUrl<String>? returnUrl;
  final Status<EventState, String>? status;
  final String? customerAddress1;
  final String? customerAddress2;
  final String? customerCity;
  final String? customerState;
  final String? customerPostCode;
  final String? optA;
  final String? optB;
  final String? optC;
  final String? optD;
  final Widget child;

  const Aamarpay({
    super.key,
    required this.isSandBox,
    required this.successUrl,
    required this.failUrl,
    required this.cancelUrl,
    required this.storeID,
    required this.transactionID,
    this.transactionAmount,
    this.transactionAmountFromTextField,
    required this.signature,
    this.description,
    required this.customerName,
    required this.customerMobile,
    @Deprecated('Use status function instead of paymentStatus') this.paymentStatus,
    this.isLoading,
    this.returnUrl,
    this.status,
    this.optA,
    this.optB,
    this.optC,
    this.optD, 
    required this.child, this.customerEmail, this.customerAddress1, this.customerAddress2, this.customerCity, this.customerState, this.customerPostCode,
  }) : assert((transactionAmount != null || transactionAmountFromTextField != null),
              'Add transactionAmount or transactionAmountFromTextField');

  @override
  AamarpayState createState() => AamarpayState();
}

class AamarpayState extends State<Aamarpay> {
  final String _sandBoxUrl = 'https://secure.ariyanshipu.me';
  final String _productionUrl = 'https://secure.ariyanshipu.me';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initiatePayment();
    });
  }

  void _paymentHandler(String value) {
    widget.paymentStatus?.call(value);
  }

  void _loadingHandler(bool value) {
    widget.isLoading?.call(value);
  }

  void _urlHandler(String? value) {
    widget.returnUrl?.call(value ?? "No URL was found because user pressed the back button");
    if (value == null) {
      widget.status?.call(EventState.backButtonPressed, 'User pressed the back button');
    }
  }

  void _initiatePayment() {
    _loadingHandler(true);
    _getPayment().then((url) {
      if (url == null) {
        _loadingHandler(false);
        widget.status?.call(EventState.error, 'Error');
      } else {
        Route route = MaterialPageRoute(
          builder: (context) => AAWebView(
            url: url,
            successUrl: widget.successUrl,
            failUrl: widget.failUrl,
            cancelUrl: widget.cancelUrl,
          ),
        );
        Navigator.push(context, route).then((value) {
          _handlePaymentResult(value.toString());
        });
      }
    }).catchError((error) {
      _loadingHandler(false);
      widget.status?.call(EventState.error, error.toString());
    });
  }

  void _handlePaymentResult(String result) {
    if (result.contains(widget.successUrl)) {
      _paymentHandler("success");
      widget.status?.call(EventState.success, 'Payment has succeeded');
    } else if (result.contains(widget.cancelUrl)) {
      _paymentHandler("cancel");
      widget.status?.call(EventState.cancel, 'Payment has been canceled');
    } else if (result.contains(widget.failUrl)) {
      _paymentHandler("fail");
      widget.status?.call(EventState.fail, 'Payment has failed');
    } else {
      _paymentHandler("fail");
      widget.status?.call(EventState.fail, 'Payment has failed');
    }
    _loadingHandler(false);
    _urlHandler(result);
  }

  Future<String?> _getPayment() async {
    final uri = Uri.parse(widget.isSandBox ? '$_sandBoxUrl/payment/store' : '$_productionUrl/payment/store');
    final response = await http.post(
      uri,
      headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'POST, GET, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization',
        },
        body: jsonEncode(<String, dynamic>{
        "store_id": widget.storeID,
        "invoice_id": widget.transactionID,
        "success_url": widget.successUrl,
        "fail_url": widget.failUrl,
        "cancel_url": widget.cancelUrl,
        "amount": widget.transactionAmount ?? widget.transactionAmountFromTextField?.text ?? 0,
        "currency": "BDT",
        "signature_key": widget.signature,
        "desc": widget.description ?? 'Empty',
        "cus_name": widget.customerName ?? 'Customer name',
        "cus_phone": widget.customerMobile,
        "value_a": widget.optA ?? "",
        "value_b": widget.optB ?? "",
        "value_c": widget.optC ?? "",
        "value_d": widget.optD ?? "",
        "value_e": widget.optD ?? "",
        "value_f": widget.optD ?? "",
        "value_g": widget.optD ?? "",
        "value_h": widget.optD ?? "",
        "type": "json",
     }),
    );
    if (kDebugMode) {
      print(response.body);
    }
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['payment_url'];
    } else {
      throw Exception(_parseExceptionMessage(response.body));
    }
  }

  String _parseExceptionMessage(String data) {
    try {
      final res = jsonDecode(data);
      if (res is Map<String, dynamic>) {
        return res.values.first;
      } else {
        return res.toString();
      }
    } catch (e) {
      return 'Unknown error, please contact AamarPay';
    }
  }
  
  @override
  Widget build(BuildContext context) {
       return Scaffold(
      body: Center(
        child: widget.child,
        ),
      );
  
  }
}
