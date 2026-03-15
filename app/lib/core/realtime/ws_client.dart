import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../config/app_config.dart';
import 'realtime_service.dart';

class WsClient implements RealtimeService {
  WebSocketChannel? _channel;
  final StreamController<Map<String, dynamic>> _controller = StreamController.broadcast();
  final StreamController<bool> _connectionController = StreamController<bool>.broadcast();
  bool _connected = false;

  @override
  bool get isConnected => _connected;

  @override
  Stream<Map<String, dynamic>> get stream => _controller.stream;

  @override
  Stream<bool> get connectionStream => _connectionController.stream;

  @override
  Future<void> connect(String token) async {
    final uri = Uri.parse('ws://172.20.10.3:8000/ws?token=$token');

    _channel = WebSocketChannel.connect(uri);
    _connected = true;
    _connectionController.add(true); // notify connected

    _channel!.sink.add(jsonEncode({
      "type": "subscribe",
      "topic": "conversations"
    }));

    _channel!.stream.listen(
      (event) {
        if (event is String) {
          final decoded = jsonDecode(event) as Map<String, dynamic>;
          _controller.add(decoded);
          print("WS EVENT: $decoded");
        }
      },
      onDone: () {
        _connected = false;
        _connectionController.add(false); // notify disconnected
      },
      onError: (_) {
        _connected = false;
        _connectionController.add(false); // notify on error too
      },
    );
  }

  @override
  Future<void> disconnect() async {
    await _channel?.sink.close();
    _connected = false;
    _connectionController.add(false); // notify disconnected
  }

  void dispose() {
    _controller.close();
    _connectionController.close();
  }
}