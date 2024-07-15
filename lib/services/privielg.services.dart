import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:invo_models/models/EmployeePrivilege.dart';

import 'login.services.dart';
import 'varHttp.dart';

class PrivielgService {
  Future<List<EmployeePrivilege>?> getEmployeePrivielges() async {
    String token = (await LoginServices().getToken())!;
    String myHTTP = await getServerURL();
    final response = await http.get(
      Uri.parse('${myHTTP}company/getEmployeePrivielges'),
      headers: {
        "Api-Auth": token.toString()
      },
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      if (map['success']) {
        List<EmployeePrivilege> employeePrivielges = [];
        for (var element in map['data']) {
          employeePrivielges.add(EmployeePrivilege.fromJson(element));
        }
        return employeePrivielges;
      }
    } else {
      throw Exception('Failed to load getEmployeePrivielges by branchId');
    }
    return null;
  }
}
