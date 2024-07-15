import 'dart:convert';
import 'package:invo_models/models/Discount.dart';

import 'package:http/http.dart' as http;
import 'package:newcall_center/services/login.services.dart';
import 'package:newcall_center/services/varHttp.dart';

class DiscountService {
  Future<List<Discount>> loadDiscount() async {
    String token = (await LoginServices().getToken())!;
    String myHTTP = await getServerURL();
    final response = await http.get(
      Uri.parse('${myHTTP}company/getDiscountList'),
      headers: {
        "Api-Auth": token.toString()
      },
    );

    try {
      if (response.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(response.body);
        List<Discount> discounts = [];
        if (map['success']) {
          for (var element in map['data']) {
            discounts.add(Discount.fromJson(element));
          }
        }
        return discounts;
      }
      return [];
    } on Exception {
      throw Exception("failed to load discounts");
    }
  }
}
