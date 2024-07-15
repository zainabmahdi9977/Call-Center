import 'dart:convert';

import 'package:invo_models/invo_models.dart';

import 'login.services.dart';
import 'varHttp.dart';

import 'package:http/http.dart' as http;

class AddressServices {
  Future<List<Address>?> getCompanyAddresses() async {
    String token = (await LoginServices().getToken())!;
    String myHTTP = await getServerURL();
    final response = await http.get(
      Uri.parse('${myHTTP}address/getCompanyAddresses'),
      headers: {
        "Api-Auth": token.toString()
      },
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      if (map['success']) {
        List<Address> customerAddressList = [];
        for (var element in map['data']) {
          customerAddressList.add(Address.fromMap(element));
        }

        return customerAddressList;
      }
    }
    throw Exception('Failed to load CompanyAddresses');
  }
}
