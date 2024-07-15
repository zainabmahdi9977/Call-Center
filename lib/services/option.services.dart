import 'dart:convert';
import 'package:invo_models/models/Option.dart';

import 'package:http/http.dart' as http;
import 'package:invo_models/models/OptionGroup.dart';

import 'login.services.dart';
import 'varHttp.dart';

class OptionService {
  Future<Option> loadOption() async {
    String myHTTP = await getServerURL();
    final response = await http.get(Uri.parse('????'));
    if (response.statusCode == 200) {
      return Option.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to load Option');
    }
  }

  ///////////

  // Future<List<Option>?> getOptions() async {
  //   String token = (await LoginServices().getToken())!;
  //   final response = await http.get(Uri.parse('${myHTTP}menu/getOptions'), headers: {
  //     "Api-Auth": token.toString()
  //   });
  //   if (response.statusCode == 200) {
  //     Map<String, dynamic> map = jsonDecode(response.body);
  //     if (map['success']) {
  //       List<Option> optionList = [];
  //       for (var element in map['data']) {
  //         print(element);
  //         optionList.add(Option.fromJson(element));
  //       }

  //       return optionList;
  //     }
  //   }
  //   throw Exception('Failed to load Options');
  // }

  Future<List<Option>?> getOptions() async {
    String token = (await LoginServices().getToken())!;
    String myHTTP = await getServerURL();
    final response = await http.get(
      Uri.parse('${myHTTP}menu/getOptions'),
      headers: {
        "Api-Auth": token,
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);

      if (map['success']) {
        List<Option> optionList = [];
        for (var element in map['data']) {
          optionList.add(Option.fromJson(element));
        }
        return optionList;
      }
    }
    throw Exception('Failed to load Options');
  }

  Future<List<OptionGroup>?> getOptionGroupList() async {
    String token = (await LoginServices().getToken())!;
    String myHTTP = await getServerURL();
    final response = await http.get(Uri.parse('${myHTTP}menu/getOptionGroupList'), headers: {
      "Api-Auth": token.toString()
    });
    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      if (map['success']) {
        List<OptionGroup> optionGroupList = [];
        for (var element in map['data']) {
          optionGroupList.add(OptionGroup.fromJson(element));
        }

        return optionGroupList;
      }
    }
    throw Exception('Failed to load OptionGroupList');
  }
}
