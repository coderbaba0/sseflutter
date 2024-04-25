class SSEEventData {
  final int connectionId;
  final String event;
  final String message;
  final DateTime timestamp;
  final int messageId;

  SSEEventData({
    required this.connectionId,
    required this.event,
    required this.message,
    required this.timestamp,
    required this.messageId
  });
}