import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pusher_client/pusher_client.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late PusherClient pusher;
  late Channel channel;

  @override
  void initState() {
    super.initState();

    String token = getToken();

    pusher = PusherClient(
      "030b522bdbdca49cd4d8",
      PusherOptions(
        // if local on android use 10.0.2.2
        host: 'ws://askdoctor.matgerplus.com/public',
        wsPort: 6001,
        encrypted: false,
        // auth: PusherAuth(
        //   'http://example.com/broadcasting/auth',
        //   headers: {
        //     'Authorization': 'Bearer $token',
        //   },
        // ),
      ),
      enableLogging: true,
    );

    channel = pusher.subscribe("ask_your_doctor");

    pusher.onConnectionStateChange((state) {
      log("previousState: ${state?.previousState}, currentState: ${state?.currentState}");
    });

    pusher.onConnectionError((error) {
      log("error: ${error?.exception}");
    });

    channel.bind('status-update', (event) {
      log(event!=null?event.data??"null":"null");
    });

    channel.bind('order-filled', (event) {
      log("Order Filled Event${event?.data}");
    });
  }

  String getToken() => "super-secret-token";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Example Pusher App'),
        ),
        body: Center(
            child: Column(
          children: [
            ElevatedButton(
              child: const Text('Unsubscribe Private Orders'),
              onPressed: () {
                pusher.unsubscribe('private-orders');
              },
            ),
            ElevatedButton(
              child: const Text('Unbind Status Update'),
              onPressed: () {
                channel.unbind('status-update');
              },
            ),
            ElevatedButton(
              child: const Text('Unbind Order Filled'),
              onPressed: () {
                channel.unbind('order-filled');
              },
            ),
            ElevatedButton(
              child: const Text('Bind Status Update'),
              onPressed: () {
                channel.bind('status-update',(event) {
                  log("Status Update Event${event?.data}");
                });
              },
            ),
            ElevatedButton(
              child: const Text('Trigger Client Typing'),
              onPressed: () {
                channel.trigger('client-istyping', {'name': 'Bob'});
              },
            ),
          ],
        )),
      ),
    );
  }
}