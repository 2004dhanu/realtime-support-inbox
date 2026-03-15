class Message {
  Message({
    required this.id,
    required this.conversationId,
    required this.senderType,
    required this.senderId,
    required this.body,
    required this.createdAt,
  });

  final String id;
  final String conversationId;
  final String senderType;
  final String? senderId;
  final String body;
  final DateTime createdAt;

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      senderType: json['senderType'] as String,
      senderId: json['senderId'] as String?,
      body: json['body'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
