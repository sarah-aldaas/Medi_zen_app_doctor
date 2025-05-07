import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../../helpers/utilities.dart';
// import 'package:rxdart/rxdart.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImplementation implements NetworkInfo {
  final InternetConnection connectionChecker;

  // BehaviorSubject<InternetStatus> currentNetworkInfoStatus = BehaviorSubject<InternetStatus>();

  NetworkInfoImplementation(this.connectionChecker) {
    connectionChecker.onStatusChange.listen((status) {
      // currentNetworkInfoStatus.sink.add(status);
      Utilities.showInternetConnectionSnackBar(status);
    });
  }

  @override
  Future<bool> get isConnected => connectionChecker.hasInternetAccess;
}
