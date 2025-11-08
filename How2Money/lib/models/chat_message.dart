class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final String? threadId;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.threadId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'threadId': threadId,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      isUser: json['isUser'] ?? false,
      timestamp: DateTime.parse(json['timestamp']),
      threadId: json['threadId'],
    );
  }
}

class ChatThread {
  final String id;
  final String title;
  final DateTime lastMessageTime;
  final int messageCount;

  ChatThread({
    required this.id,
    required this.title,
    required this.lastMessageTime,
    this.messageCount = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'messageCount': messageCount,
    };
  }

  factory ChatThread.fromJson(Map<String, dynamic> json) {
    return ChatThread(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      lastMessageTime: DateTime.parse(json['lastMessageTime']),
      messageCount: json['messageCount'] ?? 0,
    );
  }
}


