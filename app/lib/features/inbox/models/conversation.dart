class ConversationSummary {
  ConversationSummary({
    required this.id,
    required this.title,
    required this.status,
    required this.priority,
    required this.assignee,
    required this.unreadCount,
    required this.lastMessagePreview,
    required this.lastMessageAt,
    bool? isTyping,
    this.presenceState,
  }) : isTyping = isTyping ?? false;

  final String id;
  final String title;
  final String status;
  final String priority;
  final String? assignee;
  final int unreadCount;
  final String lastMessagePreview;
  final DateTime lastMessageAt;

  final bool isTyping;
  final String? presenceState;

  factory ConversationSummary.fromJson(Map<String, dynamic> json) {
    return ConversationSummary(
      id: json['id'] as String,
      title: json['title'] as String,
      status: json['status'] as String,
      priority: json['priority'] as String,
      assignee: json['assignee'] as String?,
      unreadCount: json['unreadCount'] as int? ?? 0,
      lastMessagePreview: json['lastMessagePreview'] as String? ?? '',
      lastMessageAt: DateTime.parse(json['lastMessageAt'] as String),
      isTyping: false, // important
    );
  }

  ConversationSummary copyWith({
    String? title,
    String? status,
    String? priority,
    String? assignee,
    int? unreadCount,
    String? lastMessagePreview,
    DateTime? lastMessageAt,
    bool? isTyping,
    String? presenceState,
  }) {
    return ConversationSummary(
      id: id,
      title: title ?? this.title,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      assignee: assignee ?? this.assignee,
      unreadCount: unreadCount ?? this.unreadCount,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      isTyping: isTyping ?? this.isTyping,
      presenceState: presenceState ?? this.presenceState,
    );
  }
}
