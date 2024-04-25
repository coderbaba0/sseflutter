import 'dart:async';
import 'dart:convert';

import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';

import 'SSEC_model.dart';

class SSEManager {
  final String serverUrl;
  final Function(SSEEventData) onDataReceived;

  SSEManager({required this.serverUrl, required this.onDataReceived});

   void connectToServer() {
    SSEClient.subscribeToSSE(
      method: SSERequestType.GET,
      url: serverUrl,
      header: {
        "Accept": "text/event-stream",
        "Cache-Control": "no-cache",
      },
    ).listen(
          (event) {
        print('Received SSE event: ${event.data}');
        handleSSEEvent(event.data!);
      },
      onError: (error) {
        // Handle errors
        print('Connection error: $error');
        _reconnect();
      },
      onDone: () {
        // Handle connection closure
        print('Connection closed');
        _reconnect(); // Attempt to reconnect
      },
    );
  }

  void _reconnect() async {
    // Wait for reconnect delay
    print('we are trying to reconnecting..');
    await Future.delayed(const Duration(seconds: 5));
    // Attempt to reconnect
    connectToServer();
  }

  void handleSSEEvent(String eventData) {
    try {
      Map<String, dynamic> eventDataMap = jsonDecode(eventData);
      int connectionId = eventDataMap['connectionId'];
      String event = eventDataMap['event'];
      String message = eventDataMap['message'];
      DateTime timestamp = DateTime.parse(eventDataMap['timestamp']);
      int messageId = eventDataMap['messageId'];

      onDataReceived(SSEEventData(
        connectionId: connectionId,
        event: event,
        message: message,
        timestamp: timestamp,
        messageId: messageId,
      ));
    } catch (e) {
      print('Error parsing SSE event data: $e');
    }
  }
}