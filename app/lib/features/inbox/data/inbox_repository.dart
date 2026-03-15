import '../models/conversation.dart';
import '../models/message.dart';

abstract class InboxRepository {
  Future<List<ConversationSummary>> fetchConversations({
    String? status,
    String? assignee,
    int page = 1,
    int pageSize = 20,
  });

  Future<List<Message>> fetchMessages({
    required String conversationId,
    int page = 1,
    int pageSize = 30,
  });

  Future<Message> sendMessage({
    required String conversationId,
    required String body,
  });

  Future<void> updateStatus({
    required String conversationId,
    required String status,
  });

  Future<void> updatePriority({
    required String conversationId,
    required String priority,
  });
}
