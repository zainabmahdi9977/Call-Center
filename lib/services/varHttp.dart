// ignore_for_file: file_names
import 'package:shared_preferences/shared_preferences.dart';

// SharedPreferences prefs = await SharedPreferences.getInstance();
// String? url = prefs.getString("serverURL");
// String myHTTP = "http://$url/v1/callcenter/";
Future<String> getServerURL() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? url = prefs.getString("serverURL");
  url ??= "https://productionback.invopos.co";
  String myHTTP = "$url/v1/callcenter/";
  return myHTTP;
}
//String myHTTP = "http://localhost:62941/v1/callcenter/";
// myHTTP1 = "http://10.2.2.155:3001/v1/callcenter/";
// myHTTP2 = "http://10.2.2.49:3001/v1/callcenter/";
