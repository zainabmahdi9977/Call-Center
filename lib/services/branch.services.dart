// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/branch.models.dart';
import 'login.services.dart';
import 'varHttp.dart';

class BranchService {
  Future<List<Branch>?> getBranchList() async {
    String token = (await LoginServices().getToken())!;
    String myHTTP = await getServerURL();
    final response = await http.get(Uri.parse('${myHTTP}company/getBranchList'), headers: {
      "Api-Auth": token.toString()
    });
    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      if (map['success']) {
        List<Branch> branches = [];
        for (var element in map['data']) {
          branches.add(Branch.fromJson(element));
        }
        return branches;
      }
    } else {
      throw Exception('Failed to load BranchList');
    }
    return null;
  }

  Future<List<Branch>?> fetchBranches() async {
    try {
      return await getBranchList();
    } catch (e) {
      throw Exception(e);
    }
  }
}
