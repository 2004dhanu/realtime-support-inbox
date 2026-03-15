import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/network/api_client.dart';
import '../../core/session/session_store.dart';
import '../inbox/ui/inbox_page.dart';

class DevLoginPage extends StatefulWidget {
  const DevLoginPage({super.key});

  static const routeName = '/login';

  @override
  State<DevLoginPage> createState() => _DevLoginPageState();
}

class _DevLoginPageState extends State<DevLoginPage> {
  final _controller = TextEditingController(text: 'agent_1');
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final client = ApiClient();
      final response = await client.post(
        '/auth/dev-login',
        body: {'agentId': _controller.text.trim()},
      );
      if (response.statusCode != 200) {
        throw Exception('Login failed');
      }
      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      SessionStore.instance.setSession(
        token: payload['token'] as String,
        agent: payload['agent'] as Map<String, dynamic>,
      );
      if (!mounted) return;
      Get.offAllNamed(InboxPage.routeName);
    } catch (err) {
      setState(() => _error = 'Could not log in. Check the server.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dev Login', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _controller,
                    decoration: const InputDecoration(labelText: 'Agent ID'),
                  ),
                  const SizedBox(height: 12),
                  if (_error != null)
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _login,
                      child: _loading
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Continue'),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
