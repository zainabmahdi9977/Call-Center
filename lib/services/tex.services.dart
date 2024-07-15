// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:invo_models/models/Surcharge.dart';
import 'package:invo_models/models/tax.dart';

import 'package:http/http.dart' as http;

import 'login.services.dart';
import 'varHttp.dart';

class TaxService {
  Future<List<Surcharge>?> getSurchargeList() async {
    String token = (await LoginServices().getToken())!;
    String myHTTP = await getServerURL();
    final response = await http.post(Uri.parse('${myHTTP}menu/getSurchargeList'),
        headers: {
          "Api-Auth": token.toString()
        },
        body: jsonEncode({}));
    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      if (map['success']) {
        List<Surcharge> surchargeList = [];
        for (var element in map['data']['list']) {
          surchargeList.add(Surcharge.fromJson(element));
        }

        return surchargeList;
      }
    }
    throw Exception('Failed to load SurchargeList');
  }

  Future<List<Tax>?> loadTax() async {
    String myHTTP = await getServerURL();
    String token = (await LoginServices().getToken())!;
    final response = await http.post(Uri.parse('${myHTTP}company/getTaxesList'),
        headers: {
          "Api-Auth": token.toString()
        },
        body: jsonEncode({}));
    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      if (map['success']) {
        List<Tax> TaxList = [];
        for (var element in map['data']['list']) {
          TaxList.add(Tax.fromJson(element));
        }

        return TaxList;
      }
    } else {
      throw Exception('Failed to load Tax');
    }
    return null;
  }
}
