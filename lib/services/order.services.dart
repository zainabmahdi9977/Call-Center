// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';

import 'package:invo_models/invo_models.dart';
//import 'package:invo_models/models/Invoice.dart';

import 'package:http/http.dart' as http;

import 'login.services.dart';
import 'varHttp.dart';

class OrderService {
  Future<Object> getCustomerInvoices(customerId) async {
    String token = (await LoginServices().getToken())!;
    String myHTTP = await getServerURL();
    final response = await http.get(
      Uri.parse('${myHTTP}order/getOrders/$customerId'),
      headers: {
        "Api-Auth": token.toString()
      },
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      if (map['success']) {
        return Invoice.fromJson(map['data']);
      }
      return Invoice().customerId.toString();
    } else {
      throw Exception('Failed to load CustomerInvoices');
    }
  }

  Future<Invoice> getInvoiceById(invoiceId) async {
    String token = (await LoginServices().getToken())!;
    String myHTTP = await getServerURL();
    final response = await http.get(
      Uri.parse('${myHTTP}order/getOrder/$invoiceId'),
      headers: {
        "Api-Auth": token.toString()
      },
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      if (map['success']) {
        return Invoice.fromJson(map['data']);
      }
      return Invoice();
    } else {
      throw Exception('Failed to load Invoice ById');
    }
  }

  Future<Invoice?> saveInvoice(Invoice invoice, String branchId) async {
    String myHTTP = await getServerURL();
    try {
      String token = (await LoginServices().getToken())!;
      Map map = invoice.toFullMap();
      map['branchId'] = branchId;
      final response = await http.post(
        Uri.parse('${myHTTP}order/saveInvoice'),
        headers: {
          "Api-Auth": token.toString(),
          "Content-Type": "application/json"
        },
        body: jsonEncode(map),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(response.body);
        if (map["success"]) {
          //  invoice.id =   map["data"][0]["InvoiceId"];
          return invoice;
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

// String Employee, String Branch, String Ticket
  Future<List<InvoiceMini>> getOrders(String? Employee, String? Branch, String? Filter, String? selectedTicket, String? customerContact) async {
    String myHTTP = await getServerURL();

    String token = (await LoginServices().getToken()) ?? '';
    try {
      final response = await http.post(Uri.parse('${myHTTP}order/getInvoices'),
          headers: {
            "Api-Auth": token.toString(),
            "Content-Type": "application/json"
          },
          body: jsonEncode({
            "employeeId": Employee,
            "branchId": Branch,
            "filter": Filter,
            "customerContact": customerContact
          }));
      List<InvoiceMini> orders = [];
      if (response.statusCode == 200) {
        List<dynamic> map = jsonDecode(response.body);
        for (var element in map) {
          InvoiceMini order = InvoiceMini.fromJson(element);
          if (selectedTicket == null || order.status.tr() == selectedTicket.tr()) {
            if (customerContact == null || order.customerContact == customerContact) {
              if (order.arrivalTime == null && order.driverId.isEmpty && selectedTicket?.tr() != "Delivered".tr()) {
                orders.add(order);
              }
            }
          }
          if (order.arrivalTime != null && order.driverId.isNotEmpty && selectedTicket?.tr() == "Delivered".tr()) {
            orders.add(order);
          }
        }
      }
      return orders;
    } on Exception catch (e) {
      throw Exception(e);
    }
  }

  Future<Invoice?> getInvoice(String id) async {
    String token = (await LoginServices().getToken())!;
    String myHTTP = await getServerURL();
    final response = await http.get(
      Uri.parse('$myHTTP/order/getOrder/$id'),
      headers: {
        "Api-Auth": token.toString(),
        "Content-Type": "application/json"
      },
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      if (map['success']) {
        return Invoice.fromFullJson(map['data']);
      }
    }
    return null;
  }

  Future<List<InvoiceMini>> getInvoicesByCustomerID(String customerId) async {
    String token = (await LoginServices().getToken())!;
    String myHTTP = await getServerURL();
    final response = await http.get(
      Uri.parse('${myHTTP}order/getInvoicesByCustomerID/$customerId'),
      headers: {
        "Api-Auth": token.toString(),
        "Content-Type": "application/json"
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => InvoiceMini.fromJson(json)).toList();
    }

    return [];
  }
}
