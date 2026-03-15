import 'dart:async';

import '../../../core/realtime/realtime_service.dart';
import '../bloc/inbox_bloc.dart';

class InboxRealtimeAdapter {
  InboxRealtimeAdapter({
    required this.realtimeService,
    required this.inboxBloc,
  });

  final RealtimeService realtimeService;
  final InboxBloc inboxBloc;

  StreamSubscription? _subscription;

  Future<void> start(String token) async {
    print('🔌 Starting RealtimeAdapter with token: $token');
    await realtimeService.connect(token);
    _subscription = realtimeService.stream.listen(_handleEvent);
  }

  void _handleEvent(Map<String, dynamic> event) {
    print("📡 Realtime event received: $event");

    final type = event['type'];
    final conversationId = event['conversationId'];
    final payload = event['payload'] ?? {};
    final timestamp = event['timestamp'];

    switch (type) {
      case 'conversation.created':
  inboxBloc.add(InboxConversationCreated(payload));
  break;
        

      case 'conversation.updated':
        print('🔄 Conversation updated for ID: $conversationId');
        
        // Handle status update if present
        if (payload.containsKey('status')) {
          print('   Status changed to: ${payload['status']}');
          inboxBloc.add(InboxConversationStatusUpdated({
            'id': conversationId ?? payload['id'],
            'status': payload['status'],
          }));
        }
        
        // Handle priority update if present
        if (payload.containsKey('priority')) {
          print('   Priority changed to: ${payload['priority']}');
          inboxBloc.add(InboxConversationPriorityUpdated({
            'id': conversationId ?? payload['id'],
            'priority': payload['priority'],
          }));
        }
        
        // If only lastMessageAt changed, it might indicate a new message
        if (payload.containsKey('lastMessageAt') && 
            !payload.containsKey('status') && 
            !payload.containsKey('priority')) {
          print('   Last message time updated, refreshing...');
          inboxBloc.add(const RefreshInbox());
        }
        break;

      case 'message.updated':
        print('💬 Message updated for conversation: $conversationId');
        print('   Message payload: $payload');
        
        // Create a proper payload for the message event
        final messagePayload = {
          'conversationId': conversationId ?? payload['conversationId'],
          'body': payload['body'],
          'id': payload['id'],
          'timestamp': timestamp,
        };
        
        inboxBloc.add(InboxMessageCreated(messagePayload));
        break;

      case 'message.created':
        print('💬 New message created for conversation: $conversationId');
        print('   Message payload: $payload');
        
        final messagePayload = {
          'conversationId': conversationId ?? payload['conversationId'],
          'body': payload['body'],
          'id': payload['id'],
          'timestamp': timestamp,
        };
        
        inboxBloc.add(InboxMessageCreated(messagePayload));
        break;

      case 'typing.updated':
        print('⌨️ Typing event for conversation: $conversationId');
        inboxBloc.add(InboxTypingUpdated({
          'conversationId': conversationId,
          ...payload,
        }));
        break;

      case 'presence.updated':
        print('👤 Presence event for conversation: $conversationId');
        inboxBloc.add(InboxPresenceUpdated({
          'conversationId': conversationId,
          ...payload,
        }));
        break;
      case 'conversation.priority.updated':
  inboxBloc.add(
    InboxConversationPriorityUpdated({
      'id': conversationId ?? payload['id'],
      'priority': payload['priority'],
    }),
  );
  break;

      default:
        print('❓ Unknown event type: $type');
        break;
    }
  }

  Future<void> stop() async {
    print('🔌 Stopping RealtimeAdapter');
    await _subscription?.cancel();
    await realtimeService.disconnect();
  }
}