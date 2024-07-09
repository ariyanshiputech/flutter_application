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
  dynamic valueA;
  dynamic valueB;
  dynamic valueC;
  dynamic valueD;
  dynamic valueE;
  dynamic valueF;
  dynamic valueG;

  RequestResponse({
    this.cusPhone,
    this.amount,
    this.invoiceId,
    this.paymentMethod,
    this.paymentNumber,
    this.transactionId,
    this.date,
    this.status,
    this.valueA,
    this.valueB,
    this.valueC,
    this.valueD,
    this.valueE,
    this.valueF,
    this.valueG,
  });

  factory RequestResponse.fromJson(Map<dynamic, dynamic> json) =>
      RequestResponse(
        amount: json["amount"],
        invoiceId: json["invoice_id"],
        paymentMethod: json["card_type"],
        paymentNumber: json["payment_number"],
        transactionId: json["bank_tran_id"],
        valueA: json["value_a"],
        valueB: json["value_b"],
        valueC: json["value_c"],
        valueD: json["value_d"],
        valueE: json["value_e"],
        valueF: json["value_f"],
        valueG: json["value_g"],
        date: json["tran_date"] == null ? null : DateTime.parse(json["tran_date"]),
        status: json["status"] == 'Successful'
            ? ResponseStatus.completed
            : json['status'] == '' || json['status'] == null
                ? ResponseStatus.pending
                : ResponseStatus.canceled,
      );

  Map<dynamic, dynamic> toJson() => {
        "cus_phone": cusPhone,
        "amount": amount,
        "invoice_id": invoiceId,
        "payment_method": paymentMethod,
        "payment_number": paymentNumber,
        "transaction_id": transactionId,
        "date": date?.toIso8601String(),
        "status": status,
        "value_a": valueA,
        "value_b": valueB,
        "value_c": valueC,
        "value_d": valueD,
        "value_e": valueE,
        "value_f": valueF,
        "value_g": valueG,
      };
}

enum ResponseStatus {
  completed,
  canceled,
  pending,
}
