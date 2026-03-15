import 'package:flutter/foundation.dart';

class SessionStore extends ChangeNotifier {
  SessionStore._();

  static final SessionStore instance = SessionStore._();

  String? _token;
  Map<String, dynamic>? _agent;

  String? get token => _token;
  Map<String, dynamic>? get agent => _agent;

  bool get isAuthenticated => _token != null;

  void setSession({required String token, required Map<String, dynamic> agent}) {
    _token = token;
    _agent = agent;
    notifyListeners();
  }

  void clear() {
    _token = null;
    _agent = null;
    notifyListeners();
  }
}
