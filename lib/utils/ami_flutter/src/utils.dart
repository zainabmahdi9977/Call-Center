import 'package:flutter/material.dart';

import 'constants.dart';
import 'managers.dart';

bool isGreetingLines(List<String> data) => data.length == 1 && isGreeting(data[0]);

bool isGreeting(String data) => data.contains('/') && !data.contains(':');

Map<String, String> decodeHeaders(List<String> lines) {
  final headers = <String, String>{};
  for (var e in lines) {
    final tags = e.split(':');
    if (tags.length >= 2) {
      final index = e.indexOf(':');
      final key = e.substring(0, index).trim();
      final value = e.substring(index + 1).trim();
      // print('obtain k/v from line [$key]=[$value]');
      headers[key] = value;
    } else {
      debugPrint('decode message line failed $e');
    }
  }
  return headers;
}

MessageType decodeType(List<String> lines) {
  final typeStr = lines.isEmpty ? '' : lines.first.split(':')[0];
  // print('decode type raw data $typeStr');
  return strToEnum(typeStr);
}

MessageType strToEnum(String str) {
  switch (str) {
    case 'Response':
      return MessageType.response;
    case 'Event':
      return MessageType.event;

    case 'Action':
      return MessageType.action;

    default:
      return MessageType.unknown;
  }
}

T selectByPlatform<T extends BaseManager>(bool isWeb) {
  if (isWeb) {
    return WebSocketManager() as T;
  } else {
    return DefaultManager() as T;
  }
}
