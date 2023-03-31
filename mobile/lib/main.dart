import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobile/individual_post.dart';
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
  await dotenv.load(fileName: ".env");
  
 runApp(
   ChangeNotifierProvider<AppStateModel>(            
     create: (_) => AppStateModel()..loadPosts() ..updateLocation() ..getLoggedInUser(), 
     child: const CupertinoStoreApp(),               
   ),
 );
}
