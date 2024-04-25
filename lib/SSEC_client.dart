import 'dart:async';
import 'dart:convert';

import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'SSEC_model.dart';
import 'notificationpulgin.dart';
import 'notify.dart';
import 'ontap_notifications.dart';

class SSEClientPage extends StatefulWidget {
  @override
  _SSEClientPageState createState() => _SSEClientPageState();
}

class _SSEClientPageState extends State<SSEClientPage> {
  int count = 0;
  int _status = 0;
  final List<SSEEventData> sseEvents = [];
  final ScrollController _scrollController = ScrollController();
  String servermessage = '';


  @override
  void initState() {
    super.initState();
    backgroundFetchHeadlessTask();
    //NotificationServices().initNotification(context);
   //_connectToServer();
  }
  onNotificationInLowerVersions(ReceivedNotification receivedNotification) {
    print('Notification Received ${receivedNotification.id}');
  }

  onSelectNotification(String? payload) {
    if (payload != null) {
      return Navigator.push(context, MaterialPageRoute(builder: (coontext) {
        return NotificationScreen(
          payload: payload,
        );
      }));
    }
  }


  // connection for server
  void _connectToServer() {
    SSEClient.subscribeToSSE(
      method: SSERequestType.GET,
      url: 'http://192.168.1.42:3000/events',
      header: {
        "Accept": "text/event-stream",
        "Cache-Control": "no-cache",
      },
    ).listen(
      (event) {
        print('Received SSE event: ${event.data}');
        _handleSSEEvent(event.data!);
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
    _connectToServer();
  }

  void _handleSSEEvent(String eventData) {
    try {
      Map<String, dynamic> eventDataMap = jsonDecode(eventData);
      int connectionId = eventDataMap['connectionId'];
      String event = eventDataMap['event'];
      String message = eventDataMap['message'];
      DateTime timestamp = DateTime.parse(eventDataMap['timestamp']);
      int messageId = eventDataMap['messageId'];

      setState(() {
        sseEvents.add(SSEEventData(
          connectionId: connectionId,
          event: event,
          message: message,
          timestamp: timestamp,
          messageId: messageId,
        ));
      });
      _scrollToTop();
    } catch (e) {
      print('Error parsing SSE event data: $e');
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void backgroundFetchHeadlessTask() async {
    // Initialize SSE connection and event handling in background
    _connectToServer();
    // Your SSE connection and event handling logic goes here
    print('Background fetch triggered');
    // Example: Establish SSE connection and handle events
  }

  void initBackgroundFetch() async {
    // Configure the background fetch
    BackgroundFetch.configure(
      BackgroundFetchConfig(
        minimumFetchInterval: 15, // Minimum fetch interval (in minutes)
        stopOnTerminate: false, // Keep running even when app is terminated
        enableHeadless: true, // Enable headless mode for background execution
        startOnBoot: true, // Start background fetch on device boot
        requiredNetworkType: NetworkType.ANY,
      ),
      backgroundFetchHeadlessTask,
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
              label: Text('0',),
              child: Icon(Icons.notifications,color: Colors.white,),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
            TextButton(
                onPressed: _onClickStatus, child: Text('Background Status')),
            Container(
                child: Text("$_status"), margin: EdgeInsets.only(left: 20.0))
          ])),

      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 45.0),
        child: Row(
          children: [
            Expanded(
              child: FloatingActionButton.small(onPressed: ()async{
                NotificationServices().showNotification(title: "My Notification", body: "This is my notification body", payload: "secondScreen");

                //await notificationPlugin.showNotification();
                // await notificationPlugin.scheduleNotification();
                 //await notificationPlugin.showNotificationWithAttachment();
                 //await notificationPlugin.repeatNotification();
                // await notificationPlugin.showDailyAtTime();
                // await notificationPlugin.showWeeklyAtDayTime();
                //  count = await notificationPlugin.getPendingNotificationCount();
                //  print('Count $count');
                //  await notificationPlugin.cancelNotification();
                //  count = await notificationPlugin.getPendingNotificationCount();
                 print('Count $count');
              },child: Text('Send Notifications'),),
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
                    title: Text('Connection ID: ${eventData.connectionId}'),
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
