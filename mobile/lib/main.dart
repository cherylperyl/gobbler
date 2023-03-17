import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';     
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app.dart';
import 'model/app_state_model.dart';                 

Future main() async {
  await dotenv.load(fileName: ".env");
 runApp(
   ChangeNotifierProvider<AppStateModel>(            
     create: (_) => AppStateModel()..loadPosts() ..updateLocation() ..updateUser(), 
     child: const CupertinoStoreApp(),               
   ),
 );
}