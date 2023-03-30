import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';     
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'model/push_notification.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'model/post.dart';


import 'app.dart';
import 'model/app_state_model.dart';                 

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    importance: Importance.max,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const androidInitializationSetting = AndroidInitializationSettings("@mipmap/ic_launcher");
  const initSettings = InitializationSettings(android: androidInitializationSetting);
  await flutterLocalNotificationsPlugin.initialize(initSettings);
  await flutterLocalNotificationsPlugin
    .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
    ?.createNotificationChannel(channel);
  FirebaseMessaging messaging = FirebaseMessaging.instance;


  String? token = await FirebaseMessaging.instance.getToken();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (token != null) {
    prefs.setString("messagingToken", token);
  }
  FirebaseMessaging.instance.onTokenRefresh.listen((token)=> {
      if (token != null) {
      prefs.setString("messagingToken", token)
    }
  });
  FirebaseMessaging.onBackgroundMessage((message) {
    print(message);
    return Future(() => null);
  });
  
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    // If `onMessage` is triggered with a notification, construct our own
    // local notification to show to users using the created channel.

    
    if (notification != null && android != null) {
      final json = jsonDecode(notification.body!);
      flutterLocalNotificationsPlugin.show(
          2,
          "Gobble these nuts",
          json['title'],
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              priority: Priority.max,
              importance: Importance.max,
              ticker: "ticker",
            ),
          ),
          payload: notification.body);
    }
  });
  await dotenv.load(fileName: ".env");
  
 runApp(
   ChangeNotifierProvider<AppStateModel>(            
     create: (_) => AppStateModel()..loadPosts() ..updateLocation() ..getLoggedInUser(), 
     child: const CupertinoStoreApp(),               
   ),
 );
}

