import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:sseflutter/sse_manager.dart';

import 'SSEC_model.dart';
import 'notify.dart';

class SSEClientPage2 extends StatefulWidget {
  @override
  _SSEClientPage2State createState() => _SSEClientPage2State();
}

class _SSEClientPage2State extends State<SSEClientPage2> {
  int count = 0;
  int _status = 0;
  final List<SSEEventData> sseEvents = [];
  final ScrollController _scrollController = ScrollController();
  String servermessage = '';

  late SSEManager _sseManager;

  @override
  void initState() {
    super.initState();
    _sseManager = SSEManager(
      serverUrl: 'http://192.168.1.42:3000/events',
      onDataReceived: _handleSSEEvent,
    );
    _sseManager.connectToServer();
  }

  void _handleSSEEvent(SSEEventData eventData) {
    setState(() {
      sseEvents.add(eventData);
    });
    _scrollToTop();
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _onClickStatus() async {
    int status = await BackgroundFetch.status;
    print('[BackgroundFetch] status: $status');
    setState(() {
      _status = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text(
          'SSE Client',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Badge(
              backgroundColor: Colors.green,
              label: Text('0'),
              child: Icon(Icons.notifications, color: Colors.white),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
              onPressed: _onClickStatus,
              child: Text('Background Status'),
            ),
            Container(
              child: Text("$_status"),
              margin: EdgeInsets.only(left: 20.0),
            )
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 45.0),
        child: Row(
          children: [
            Expanded(
              child: FloatingActionButton.small(
                onPressed: () async {
                  NotificationServices().showNotification(
                      title: "My Notification",
                      body: "This is my notification body",
                      payload: "secondScreen");

                  print('Count $count');
                },
                child: Text('Send Notifications'),
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.pink.withOpacity(0.1),
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListView.builder(
              reverse: true,
              controller: _scrollController,
              itemCount: sseEvents.length,
              itemBuilder: (context, index) {
                final eventData = sseEvents[index];
                return Card(
                  child: ListTile(
                    title:
                    Text('Connection ID: ${eventData.connectionId}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Event: ${eventData.event}'),
                        Text('Message: ${eventData.message}'),
                        Text('Timestamp: ${eventData.timestamp}'),
                      ],
                    ),
                    trailing: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.purple,
                      child: Text(
                        'MID ${eventData.messageId}',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}