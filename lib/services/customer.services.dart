import 'dart:convert';
import 'package:invo_models/models/Customer.dart';

import 'package:http/http.dart' as http;

import 'login.services.dart';
import 'varHttp.dart';

class CustomerService {
  Future<Customer> getCustomerByNumber(number) async {
    String token = (await LoginServices().getToken())!;
    String myHTTP = await getServerURL();
    final response = await http.get(Uri.parse('${myHTTP}customer/getCustomerByNumber/$number'), headers: {
      "Api-Auth": token.toString()
    });

    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      if (map['success']) {
        return Customer.fromJson(map['data']);
      }
      return Customer(phone: number);
    } else {
      throw Exception('Failed to load Customer ByNumber');
    }
  }

  Future<Customer> getCustomerById(customerId) async {
    String token = (await LoginServices().getToken())!;
    String myHTTP = await getServerURL();
    final response = await http.get(
      Uri.parse('${myHTTP}customer/getCustomerById/$customerId'),
      headers: {
        "Api-Auth": token.toString()
      },
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      if (map['success']) {
        return Customer.fromJson(map['data']);
      }

      return Customer(id: customerId);
    } else {
      throw Exception('Failed to load Customer ById');
    }
  }

  Future<List<dynamic>?> getSuggestion(groupId, number) async {
    String token = (await LoginServices().getToken())!;
    String myHTTP = await getServerURL();
    final response = await http.post(Uri.parse('${myHTTP}customer/getSuggestion'),
        headers: {
          "Api-Auth": token.toString(),
          "Content-Type": "application/json"
        },
        body: jsonEncode({
          'groupid': groupId,
          "search": number
        }));
    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      if (map['success']) {
        return map['data'];
      }
    }
    throw Exception('Failed to load Suggestion');
  }

  Future<String?> saveCustomer(Customer customer) async {
    String myHTTP = await getServerURL();
    String token = (await LoginServices().getToken())!;
    final response = await http.post(Uri.parse('$myHTTP/customer/saveCustomer'),
        headers: {
          "Api-Auth": token.toString(),
          "Content-Type": "application/json"
        },
        body: jsonEncode(customer.toJson()));

    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      if (map['success']) {
        // Customer saved successfully
        return map['customerId'];
      }
    }
    throw Exception('Failed to save Customer');
  }
}
