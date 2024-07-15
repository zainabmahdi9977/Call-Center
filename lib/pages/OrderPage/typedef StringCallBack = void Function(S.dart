/*
import 'package:invo_pos_core/src/vendor/ami_flutter/ami_flutter.dart';
typedef StringCallBack = void Function(String parameter);
class AsteriskCallerID implements ICallerID {
  String extensionNumber;
  String ip;
  int port;
  String userName;
  String password;

  @override
  StringCallBack onCallRecieved;

  late DefaultManager manager;
  AsteriskCallerID({
    required this.ip,
    required this.port,
    required this.userName,
    required this.password,
    required this.extensionNumber,
    required this.onCallRecieved,
  });

  @override
  connect() async {
    manager = DefaultManager();
    manager.init();
    await manager.connect(ip, port);
    Response? loginResult = await manager.login(userName, password);
    manager.registerEvent("Newexten").listen((event) {
      String exten = event.baseMsg.headers["CallerIDNum"].toString();
      String callerNumber = event.baseMsg.headers["ConnectedLineNum"].toString();
      print(event.baseMsg.toString());
      print(exten + " receive call from " + callerNumber);
      if (exten == extensionNumber) {
        onCallRecieved(callerNumber);
      }
    });
    // return loginResult.succeed;
  }

  @override
  disconnect() {
    manager.disconnect();
  }
}


class test {

  connect(){
  AsteriskCallerID callerID = AsteriskCallerID(
            ip: terminal!.devices.callerIDIP,
            port: port,
            userName: terminal!.devices.callerIDUsername,
            password: terminal!.devices.callerIDPassword,
            extensionNumber: terminal!.devices.callerIDSID,
            onCallRecieved: onCallRecieved);
        callerID!.connect();
  }

  onCallRecieved(String number) async {
    int? res = int.tryParse(number);
    if (res != null) {
      
    }
  }
}
*/