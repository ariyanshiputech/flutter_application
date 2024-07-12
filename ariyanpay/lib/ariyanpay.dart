// ignore_for_file: use_build_context_synchronously

library ariyanpay;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ariyanpay/controllers/payment_controller.dart';
import 'package:ariyanpay/models/customer_model.dart';
import 'package:ariyanpay/models/request_response.dart';
import 'package:ariyanpay/views/payment_screen.dart';
import '../core/services/api_services.dart';
import '../models/credentials.dart';

class Ariyanpay {
  static Future<RequestResponse> createPayment({
    required BuildContext context,
    required CustomerDetails customer,
    AriyanpayCredentials? credentials,
    required String amount,
    dynamic valueA,
    dynamic valueB,
    dynamic valueC,
    dynamic valueD,
    dynamic valueE,
    dynamic valueF,
    dynamic valueG,
  }) async {
    final controller = Get.put(PaymentController());

    final request = await ApiServices.createPaymentRequest(
      customer: customer,
      amount: amount,
      valueA: valueA,
      valueB: valueB,
      valueC: valueC,
      valueD: valueD,
      valueE: valueE,
      valueF: valueF,
      valueG: valueG,
      context: context,
    );

    final String paymentURL = request['payment_url'];

    debugPrint(paymentURL);

    // Extract the payment ID from the last segment of the path
    String paymentId = Uri.parse(paymentURL).pathSegments.last;
    controller.paymentID.value = paymentId;

    debugPrint(controller.paymentID.value);

    final body = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          paymentURL: request['payment_url'],
        ),
      ),
    );

    if (body != null) {
      final response = body as RequestResponse;
      return response;
    }

    return RequestResponse(
      status: ResponseStatus.canceled,
    );
  }
}
