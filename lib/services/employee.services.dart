// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:invo_models/models/Employee.dart';

import 'package:http/http.dart' as http;

import 'login.services.dart';
import 'varHttp.dart';

class EmployeeService {
  Future<List<Employee>?> getEmployeeList() async {
    String token = (await LoginServices().getToken())!;
    String myHTTP = await getServerURL();
    final response = await http.post(Uri.parse('${myHTTP}company/getEmployeeList'), headers: {
      "Api-Auth": token.toString()
    });
    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      if (map['success']) {
        List<Employee> Employees = [];
        for (var element in map['data']['list']) {
          Employees.add(Employee.fromJson(element));
        }
        return Employees;
      }
    } else {
      throw Exception('Failed to load EmployeeList');
    }
    return null;
  }
}
