// To parse this JSON data, do
//
//     final requestResponse = requestResponseFromJson(jsonString);

import 'dart:convert';

RequestResponse requestResponseFromJson(String str) =>
    RequestResponse.fromJson(json.decode(str));

String requestResponseToJson(RequestResponse data) =>
    json.encode(data.toJson());

class RequestResponse {
  String? cusPhone;
  String? amount;
  String? invoiceId;
  String? paymentMethod;
  String? paymentNumber;
  String? transactionId;
  DateTime? date;
  ResponseStatus? status;

  RequestResponse({
    this.cusPhone,
    this.amount,
    this.invoiceId,
    this.paymentMethod,
    this.paymentNumber,
    this.transactionId,
    this.date,
    this.status,
  });

  factory RequestResponse.fromJson(Map<String, dynamic> json) =>
      RequestResponse(
        amount: json["amount"],
        invoiceId: json["invoice_id"],
        paymentMethod: json["card_type"],
        paymentNumber: json["payment_number"],
        transactionId: json["bank_tran_id"],
        date: json["tran_date"] == null ? null : DateTime.parse(json["tran_date"]),
        status: json["status"] == 'Successful'
            ? ResponseStatus.completed
            : json['status'] == '' || json['status'] == null
                ? ResponseStatus.pending
                : ResponseStatus.canceled,
      );

  Map<String, dynamic> toJson() => {
        "cus_phone": cusPhone,
        "amount": amount,
        "invoice_id": invoiceId,
        "payment_method": paymentMethod,
        "payment_number": paymentNumber,
        "transaction_id": transactionId,
        "date": date?.toIso8601String(),
        "status": status,
      };
}

enum ResponseStatus {
  completed,
  canceled,
  pending,
}
