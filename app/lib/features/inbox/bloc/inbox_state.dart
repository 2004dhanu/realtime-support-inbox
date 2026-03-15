part of 'inbox_bloc.dart';

enum InboxStatus { idle, loading, ready, failure }

class InboxState extends Equatable {
  const InboxState({
    this.status = InboxStatus.idle,
    this.items = const [],
    this.filterStatus,
    this.errorMessage,
  });

  final InboxStatus status;
  final List<ConversationSummary> items;
  final String? filterStatus;
  final String? errorMessage;

  InboxState copyWith({
    InboxStatus? status,
    List<ConversationSummary>? items,
    String? filterStatus,
    String? errorMessage,
  }) {
    return InboxState(
      status: status ?? this.status,
      items: items ?? this.items,
      filterStatus: filterStatus ?? this.filterStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, items, filterStatus, errorMessage];
}
