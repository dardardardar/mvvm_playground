import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkHelper {
  final Connectivity _connectivity = Connectivity();

  Future<bool> isConnected() async {
    var connectivityResults = await _connectivity.checkConnectivity();
    return _isConnected(connectivityResults);
  }

  bool _isConnected(List<ConnectivityResult> results) {
    for (var result in results) {
      if (result != ConnectivityResult.none) {
        return true;
      }
    }
    return false;
  }
}
