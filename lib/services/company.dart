import 'dart:convert';

import 'package:invo_models/invo_models.dart';
import 'package:invo_models/models/Preferences.dart';

import 'package:http/http.dart' as http;

import 'login.services.dart';
import 'varHttp.dart';

// ignore: camel_case_types
class company {
  Future<Preferences> getCompanyPreferences() async {
    String token = (await LoginServices().getToken())!;
    String myHTTP = await getServerURL();
    final response = await http.get(
      Uri.parse('${myHTTP}company/getCompanyPrefrences'),
      headers: {
        "Api-Auth": token.toString(),
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      if (map['success']) {
        return Preferences.fromJson(map['data']);
      }
    }

    throw Exception('Failed to load preferences');
  }

  Future<DeliveryAddresses?> getCoveredAddresses() async {
    String token = (await LoginServices().getToken())!;
    String myHTTP = await getServerURL();
    final response = await http.get(
      Uri.parse('${myHTTP}company/getCoveredAddresses'),
      headers: {
        "Api-Auth": token.toString()
      },
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      if (map['success']) {
        try {
          return DeliveryAddresses.fromMap(map['data']);
        } catch (e) {
          return DeliveryAddresses();
        }
      }
    } else {
      throw Exception('Failed to load getCoveredAddresses ');
    }
    return null;
  }
}
