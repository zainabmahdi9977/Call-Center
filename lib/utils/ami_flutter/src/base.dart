import 'dart:async';

import 'dispatcher.dart';
import 'structure.dart';

mixin LifeCycle {
  void init() {}

  void dispose() {}
}

mixin Reader {
  void onReadResponse(Response response) {}

  void onReadEvent(Event event) {}

  void onReadGreeting(String words) {}
}

mixin Connector {
  Stream get statusStream;

  Future<void> connect(String host, int port, {dynamic args});

  void disconnect();

  void send(Map<String, String> data);

  bool available();
}

mixin Parser {
  void handleMessage(dynamic message);
}

mixin Sender on Connector, Dispatcher {
  String? prefix;

  Future<Response?> sendAction(
    String name, {
    String? id,
    Map<String, String>? args,
    Duration? timeout,
  }) async {
    if (!available()) {
      return null;
    }

    id ??= '${prefix}_${DateTime.now().millisecondsSinceEpoch}';

    // print('send action $name id $id');

    final data = <String, String>{
      'Action': name,
      'ActionID': id
    }..addAll(args ?? {});
    // print('send action payload $data');

    send(data);

    if (timeout == null) {
      return registerResponse(id).first;
    } else {
      return registerResponse(id).timeout(timeout, onTimeout: (sink) {
        // if (sink != null) {
        //   sink.add(null);
        // }
      }).first;
    }
  }
}
