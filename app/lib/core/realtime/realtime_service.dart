abstract class RealtimeService {
  Future<void> connect(String token);
  Future<void> disconnect();
  Stream<Map<String, dynamic>> get stream;
  bool get isConnected;
  Stream<bool> get connectionStream; // add this
}