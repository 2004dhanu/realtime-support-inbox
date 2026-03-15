import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../session/session_store.dart';

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<http.Response> get(String path) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}$path');
    return _client.get(uri, headers: _headers());
  }

  Future<http.Response> post(String path, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}$path');
    return _client.post(uri, headers: _headers(), body: jsonEncode(body ?? {}));
  }

  Future<http.Response> patch(String path, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}$path');
    return _client.patch(uri, headers: _headers(), body: jsonEncode(body ?? {}));
  }

  Map<String, String> _headers() {
    final token = SessionStore.instance.token;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
