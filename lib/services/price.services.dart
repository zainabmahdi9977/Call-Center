import 'dart:convert';

import 'package:invo_models/models/PriceLabel.dart';
import 'package:http/http.dart' as http;

import 'login.services.dart';
import 'varHttp.dart';

class Price {
  Future<List<PriceLabel>> getPriceLabelList() async {
    String token = (await LoginServices().getToken())!;
    String myHTTP = await getServerURL();
    final response = await http.post(Uri.parse('${myHTTP}menu/getPriceLabelList'),
        headers: {
          "Api-Auth": token.toString()
        },
        body: jsonEncode({}));
    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      if (map['success']) {
        List<PriceLabel> priceLabelList = [];

        // for (var element in map['data']['list']) {
        //   priceLabelList.add(PriceLabel.fromJson(element));
        // }

        return priceLabelList;
      }
    }
    throw Exception('Failed to load PriceLabelList');
    // return [];
  }
}
