import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final StreamController<bool> _connectionStatusController = StreamController<bool>();

  Stream<bool> get connectionStatus => _connectionStatusController.stream;

  ConnectivityService() {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult>? event) {
      if (event != null) {
        var isConnected = event.contains(ConnectivityResult.wifi) || event.contains(ConnectivityResult.mobile);
        _connectionStatusController.add(isConnected);
      }
    });
  }

  void dispose() {
    _connectionStatusController.close();
  }
}
