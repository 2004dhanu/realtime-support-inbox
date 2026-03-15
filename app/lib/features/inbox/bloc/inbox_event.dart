// In inbox_event.dart
part of 'inbox_bloc.dart';

abstract class InboxEvent extends Equatable {
  const InboxEvent();

  @override
  List<Object?> get props => [];
}

class LoadInbox extends InboxEvent {
  final String? status;
  final String? assignee;

  const LoadInbox({this.status, this.assignee});

  @override
  List<Object?> get props => [status, assignee];
}

class SetInboxFilter extends InboxEvent {
  final String status;

  const SetInboxFilter(this.status);

  @override
  List<Object?> get props => [status];
}

class RefreshInbox extends InboxEvent {
  final String? assignee;

  const RefreshInbox({this.assignee});

  @override
  List<Object?> get props => [assignee];
}

// Realtime events
class InboxMessageCreated extends InboxEvent {
  final Map<String, dynamic> payload;

  const InboxMessageCreated(this.payload);

  @override
  List<Object?> get props => [payload];
}

class InboxConversationStatusUpdated extends InboxEvent {
  final Map<String, dynamic> payload;

  const InboxConversationStatusUpdated(this.payload);

  @override
  List<Object?> get props => [payload];
}

class InboxConversationPriorityUpdated extends InboxEvent {
  final Map<String, dynamic> payload;

  const InboxConversationPriorityUpdated(this.payload);

  @override
  List<Object?> get props => [payload];
}

class InboxTypingUpdated extends InboxEvent {
  final Map<String, dynamic> payload;

  const InboxTypingUpdated(this.payload);

  @override
  List<Object?> get props => [payload];
}

class InboxPresenceUpdated extends InboxEvent {
  final Map<String, dynamic> payload;

  const InboxPresenceUpdated(this.payload);

  @override
  List<Object?> get props => [payload];
}
class InboxConversationCreated extends InboxEvent {
  final Map<String, dynamic> payload;

  const InboxConversationCreated(this.payload);

  @override
  List<Object?> get props => [payload];
}
