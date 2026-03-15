import 'dart:convert';

import '../../../core/network/api_client.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import 'inbox_repository.dart';

class InboxApiRepository implements InboxRepository {
  InboxApiRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  /// Fetch conversations list
  @override
  Future<List<ConversationSummary>> fetchConversations({
    String? status,
    String? assignee,
    int page = 1,
    int pageSize = 20,
  }) async {
    final query = <String, String>{
      'page': '$page',
      'pageSize': '$pageSize',
      if (status != null) 'status': status,
      if (assignee != null) 'assignee': assignee,
    };

    final uri = Uri(
      path: '/conversations',
      queryParameters: query,
    ).toString();

    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch conversations');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    return (data['items'] as List<dynamic>)
        .map((item) =>
            ConversationSummary.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Fetch messages for a conversation
  @override
  Future<List<Message>> fetchMessages({
    required String conversationId,
    int page = 1,
    int pageSize = 30,
  }) async {
    final query = <String, String>{
      'page': '$page',
      'pageSize': '$pageSize',
    };

    final uri = Uri(
      path: '/conversations/$conversationId/messages',
      queryParameters: query,
    ).toString();

    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch messages');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    return (data['items'] as List<dynamic>)
        .map((item) => Message.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Send message
  @override
  Future<Message> sendMessage({
    required String conversationId,
    required String body,
  }) async {
    final response = await _client.post(
      '/conversations/$conversationId/messages',
      body: {
        'body': body,
        'senderType': 'agent',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send message');
    }

    return Message.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Update conversation status (open / closed / pending)
  @override
  Future<void> updateStatus({
    required String conversationId,
    required String status,
  }) async {
    final response = await _client.patch(
      '/conversations/$conversationId/status',
      body: {
        'status': status,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update status');
    }
  }

  /// Update conversation priority
  @override
  Future<void> updatePriority({
    required String conversationId,
    required String priority,
  }) async {
    final response = await _client.patch(
      '/conversations/$conversationId/priority',
      body: {
        'priority': priority,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update priority');
    }
  }
}
