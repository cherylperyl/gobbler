import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:mobile/individual_post.dart';
import 'posts_list_tab.dart';   
import 'create_tab.dart';         
import 'profile_tab.dart';  
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'model/post.dart';

class CupertinoStoreApp extends StatefulWidget {
  const CupertinoStoreApp({super.key});

  @override
  State<CupertinoStoreApp> createState() => _CupertinoStoreAppState();
}

class _CupertinoStoreAppState extends State<CupertinoStoreApp> {
  @override
  Widget build(BuildContext context) {
    // This app is designed only to work vertically, so we limit
    // orientations to portrait up and down.
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    return CupertinoApp(
      theme: CupertinoThemeData(brightness: Brightness.light),
      home: CupertinoStoreHomePage(),
    );
  }
}

class CupertinoStoreHomePage extends StatefulWidget {
  const CupertinoStoreHomePage({super.key});

  @override
  State<CupertinoStoreHomePage> createState() => _CupertinoStoreHomePageState();
}

class _CupertinoStoreHomePageState extends State<CupertinoStoreHomePage> {
  void initNotifs() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      importance: Importance.max,
    );
    void onDidReceiveNotificationResponse(NotificationResponse response) async {
      final String? payload = response.payload;
      if (response.payload != null) {
        final json = jsonDecode(payload!);
        Post post = Post.fromJson(jsonDecode(payload!));
        await Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => IndividualPost(post: post))
      );
      }
      
    }

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const androidInitializationSetting = AndroidInitializationSettings("@mipmap/ic_launcher");
    const initSettings = InitializationSettings(android: androidInitializationSetting);
    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);
    await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    String? token = await FirebaseMessaging.instance.getToken();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (token != null) {
      print("fcm token $token");
      prefs.setString("messagingToken", token);
    }
    FirebaseMessaging.instance.onTokenRefresh.listen((token)=> {
        if (token != null) {
        prefs.setString("messagingToken", token)
      }
    });
    FirebaseMessaging.onBackgroundMessage((message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
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
    
  }
  @override
  void initState() {
    initNotifs();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: 'Posts',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.plus_app),
            label: 'New',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person_crop_circle),
            label: 'Profile',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        late final CupertinoTabView returnValue;
        switch (index) {
          case 0:
            returnValue = CupertinoTabView(builder: (context) {
              return const CupertinoPageScaffold(
                child: PostsListTab(),
              );
            });
            break;
          case 1:
            returnValue = CupertinoTabView(builder: (context) {
              return const CupertinoPageScaffold(
                child: CreateTab(),
              );
            });
            break;
          case 2:
            returnValue = CupertinoTabView(builder: (context) {
              return const CupertinoPageScaffold(
                child: ProfileTab(),
              );
            });
            break;
        }
        return returnValue;
      },
    );
    
  }
}

