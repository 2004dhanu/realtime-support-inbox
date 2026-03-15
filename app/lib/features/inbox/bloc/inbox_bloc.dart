import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../data/inbox_repository.dart';
import '../models/conversation.dart';

part 'inbox_event.dart';
part 'inbox_state.dart';



class InboxBloc extends Bloc<InboxEvent, InboxState> {
  InboxBloc({required this.repository}) : super(const InboxState()) {
    on<LoadInbox>(_onLoadInbox);
    on<SetInboxFilter>(_onSetFilter);
    on<RefreshInbox>(_onRefresh);

    // Realtime events
    on<InboxMessageCreated>(_onMessageCreated);
    on<InboxConversationStatusUpdated>(_onStatusUpdated);
    on<InboxConversationPriorityUpdated>(_onPriorityUpdated);
    on<InboxTypingUpdated>(_onTypingUpdated);
    on<InboxPresenceUpdated>(_onPresenceUpdated);
    on<InboxConversationCreated>(_onConversationCreated);

  }

  final InboxRepository repository;

 Future<void> _onLoadInbox(LoadInbox event, Emitter<InboxState> emit) async {
emit(state.copyWith(status: InboxStatus.loading));

try {
final items = await repository.fetchConversations(
status: event.status ?? state.filterStatus ?? 'open',
assignee: event.assignee,
);

// Sort conversations based on priority and status
items.sort((a, b) {
  const myAgent = "agent_1"; // replace with logged user later

  // closed conversations last
  if (a.status == 'closed' && b.status != 'closed') return 1;
  if (b.status == 'closed' && a.status != 'closed') return -1;

  // assigned to me first
  final aMine = a.assignee == myAgent;
  final bMine = b.assignee == myAgent;

  if (aMine && !bMine) return -1;
  if (bMine && !aMine) return 1;

  // priority
  const priorityOrder = {'high': 0, 'medium': 1, 'low': 2};

  final aPriority = priorityOrder[a.priority] ?? 3;
  final bPriority = priorityOrder[b.priority] ?? 3;

  if (aPriority != bPriority) return aPriority.compareTo(bPriority);

  // newest message
  return b.lastMessageAt.compareTo(a.lastMessageAt);
});


emit(state.copyWith(
  status: InboxStatus.ready,
  items: items,
));

} catch (err) {
emit(state.copyWith(
status: InboxStatus.failure,
errorMessage: err.toString(),
));
}
}

  Future<void> _onSetFilter(
    SetInboxFilter event,
    Emitter<InboxState> emit,
  ) async {
    emit(state.copyWith(filterStatus: event.status));
    add(LoadInbox(status: event.status));
  }

  Future<void> _onRefresh(
    RefreshInbox event,
    Emitter<InboxState> emit,
  ) async {
    add(LoadInbox(
      status: state.filterStatus,
      assignee: event.assignee,
    ));
  }

  /// Message updated from websocket
  void _onMessageCreated(
  InboxMessageCreated event,
  Emitter<InboxState> emit,
) {
  print('📨 Processing message event: ${event.payload}');

  final conversationId = event.payload['conversationId'];
  final content = event.payload['body'];

  if (conversationId == null) return;

  final items = List<ConversationSummary>.from(state.items);

  final index = items.indexWhere((c) => c.id == conversationId);

  if (index == -1) {
    print('⚠️ Conversation not found, refreshing...');
    add(const RefreshInbox());
    return;
  }

  final convo = items[index];

  final updated = convo.copyWith(
    lastMessagePreview: content ?? convo.lastMessagePreview,
    lastMessageAt: DateTime.now(),
    unreadCount: convo.unreadCount + 1,
  );

  // move conversation to top
  items.removeAt(index);
  items.insert(0, updated);

  emit(state.copyWith(
    status: InboxStatus.ready,
    items: items,
  ));
}


  /// Conversation status updated
  void _onStatusUpdated(
    InboxConversationStatusUpdated event,
    Emitter<InboxState> emit,
  ) {
    print('🔄 Processing status updated event: ${event.payload}');
    
    final conversationId = event.payload['id'];
    final status = event.payload['status'];

    if (conversationId == null) {
      print('❌ No id in status event');
      return;
    }

    if (status == null) {
      print('❌ No status in status event');
      return;
    }

    final updatedItems = state.items.map((c) {
      if (c.id == conversationId) {
        print('✅ Updating conversation: ${c.id} status from ${c.status} to $status');
        return c.copyWith(status: status);
      }
      return c;
    }).toList();

    emit(state.copyWith(
      status: InboxStatus.ready,
      items: updatedItems,
    ));
  }

  /// Conversation priority updated
  void _onPriorityUpdated(
  InboxConversationPriorityUpdated event,
  Emitter<InboxState> emit,
) {
  final conversationId = event.payload['id'];
  final priority = event.payload['priority'];

  final items = state.items.map((c) {
    if (c.id == conversationId) {
      return c.copyWith(priority: priority);
    }
    return c;
  }).toList();

  // re-sort after priority change
  items.sort((a, b) {
    const priorityOrder = {'high': 0, 'medium': 1, 'low': 2};

    final aPriority = priorityOrder[a.priority] ?? 3;
    final bPriority = priorityOrder[b.priority] ?? 3;

    return aPriority.compareTo(bPriority);
  });

  emit(state.copyWith(
    status: InboxStatus.ready,
    items: items,
  ));
}


  /// Typing events (not needed for inbox UI but must exist)
  void _onTypingUpdated(
  InboxTypingUpdated event,
  Emitter<InboxState> emit,
) {
  final conversationId = event.payload['conversationId'];
  final isTyping = event.payload['isTyping'] ?? false;

  final items = state.items.map((c) {
    if (c.id == conversationId) {
      return c.copyWith(isTyping: isTyping);
    }
    return c;
  }).toList();

  emit(state.copyWith(
    status: InboxStatus.ready,
    items: items,
  ));
}


  /// Presence events (not needed for inbox UI)
  void _onPresenceUpdated(
  InboxPresenceUpdated event,
  Emitter<InboxState> emit,
) {
  final conversationId = event.payload['conversationId'];
  final presence = event.payload['state'];

  final items = state.items.map((c) {
    if (c.id == conversationId) {
      return c.copyWith(presenceState: presence);
    }
    return c;
  }).toList();

  emit(state.copyWith(
    status: InboxStatus.ready,
    items: items,
  ));
}

  void _onConversationCreated(
  InboxConversationCreated event,
  Emitter<InboxState> emit,
) {
  print('🆕 Processing conversation.created event: ${event.payload}');

  final payload = event.payload;

  final newConversation = ConversationSummary(
    id: payload['id'],
    title: payload['title'] ?? 'New Conversation',
    status: payload['status'] ?? 'open',
    priority: payload['priority'] ?? 'low',
    assignee: payload['assignee'],
    lastMessagePreview: '',
    unreadCount: 0,
    lastMessageAt: DateTime.parse(payload['lastMessageAt']),
  );

  final items = List<ConversationSummary>.from(state.items);

  final exists = items.any((c) => c.id == newConversation.id);

if (!exists) {
  items.insert(0, newConversation);
}


  emit(state.copyWith(
    status: InboxStatus.ready,
    items: items,
  ));
}

}
