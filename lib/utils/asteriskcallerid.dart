import 'ami_flutter/ami_flutter.dart';

typedef StringCallBack = void Function(String parameter);

class AsteriskCallerID {
  String extensionNumber;
  String ip;
  int port;
  String userName;
  String password;
  late String exten;

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

  connect() async {
    manager = DefaultManager();
    manager.init();
    await manager.connect(ip, port);
    await manager.login(userName, password);
    manager.registerEvent("Newexten").listen((event) {
      exten = event.baseMsg.headers["CallerIDNum"].toString();
      String callerNumber = event.baseMsg.headers["ConnectedLineNum"].toString();

      if (exten == extensionNumber) {
        onCallRecieved(callerNumber);
      }
    });
    //return loginResult?.succeed;
  }

  disconnect() {
    manager.disconnect();
  }
}
