import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:mobile/model/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/login_page.dart';
import 'package:provider/provider.dart';
import 'model/app_state_model.dart';
import './model/user.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() {
    return _ProfileTabState();
  }
}

class _ProfileTabState extends State<ProfileTab> {
  String? bearer;

  void initState() {
    super.initState();
    userData().then((value) {
      setState(() {
        bearer = value;
      });
    });
  }
  Future<String?> userData() async {
    final prefs = await SharedPreferences.getInstance();
    String? prefsBearer = prefs.getString('bearerToken');
    return prefsBearer;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateModel>(
      builder: (context, model, child) {
        User? user = model.getUser();
        return CupertinoPageScaffold(
          navigationBar: const CupertinoNavigationBar(
            middle: Text('Profile'),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: ListView(
                children: [
                  user == null ?
                  CupertinoButton.filled(
                    child: const Text("Log in"), 
                    onPressed: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => LoginPage()
                        )
                      );
                      setState(() {});
                    })
                  : CupertinoButton.filled(
                    child: Text("Log out"), 
                    onPressed: () {
                      model.logoutUser(); 
                      setState((){
                        bearer = null;
                      });
                      }
                  ),
                  Text(user.toString())
                ],
              ),
            
            ),
          )
        );
      },
    );
  }
}
