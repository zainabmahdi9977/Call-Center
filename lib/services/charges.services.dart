import 'dart:convert';
import 'package:invo_models/models/Surcharge.dart';

import 'package:http/http.dart' as http;

class ChargesService {
  Future<Surcharge> loadCharges() async {
    final response = await http.get(Uri.parse('????'));
    if (response.statusCode == 200) {
      return Surcharge.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to load Charges');
    }
  }
}
