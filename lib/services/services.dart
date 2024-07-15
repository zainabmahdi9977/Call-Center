import 'dart:convert';

import 'package:invo_models/invo_models.dart';

import 'package:invo_models/models/Service.dart';

import 'package:http/http.dart' as http;

import 'login.services.dart';
import 'varHttp.dart';

class ServicesApi {
  Future<Service> loadService() async {
    String myHTTP = await getServerURL();
    final response = await http.get(Uri.parse('????'));
    if (response.statusCode == 200) {
      return Service.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to load Service');
    }
  }

  Future<List<Service>> getServices() async {
    String token = (await LoginServices().getToken())!;
    String myHTTP = await getServerURL();
    final response = await http.get(
      Uri.parse('${myHTTP}menu/getServices'),
      headers: {
        "Api-Auth": token.toString()
      },
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      if (map['success']) {
        List<Service> service = [];
        for (var element in map['data']['list']) {
          service.add(Service.fromJson(element));
        }
        return service;
      }
    }
    throw Exception('Failed to load service');
  }
}
