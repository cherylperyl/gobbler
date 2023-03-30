import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/signup_page.dart';
import 'package:mobile/user_posts_page.dart';
import 'package:provider/provider.dart';
import 'package:mobile/model/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/login_page.dart';
import 'package:provider/provider.dart';
import 'package:mobile/stripe_webview.dart';
import 'model/app_state_model.dart';
import './model/user.dart';
import './model/post.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() {
    return _ProfileTabState();
  }
}

class _ProfileTabState extends State<ProfileTab> {
  String? bearer;
  late final WebViewController controller;
  
  @override
  void initState() {
    super.initState();
    userData().then((value) {
      setState(() {
        bearer = value;
      });
    });
    controller = WebViewController();
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
        List<Post> userRegisteredPosts = model.getUserRegisteredPosts();
        List<Post> userCreatedPosts = model.getUserCreatedPosts();
        return CustomScrollView(
          slivers: [
          const CupertinoSliverNavigationBar(
            largeTitle: Text('Profile'),
          ),
            SliverToBoxAdapter(
              child: user == null 
              ? Padding(
                padding: const EdgeInsets.all(20.0),
                child: CupertinoButton.filled(
                      child: const Text("Log in"), 
                      onPressed: () {
                        // Navigator.push(
                        //   context,
                        //   CupertinoPageRoute(
                        //     builder: (context) => LoginPage()
                        //   )
                        // );
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => SignupPage()
                          )
                        );
                        setState(() {});
                  }),
              )
              : SizedBox()
            ),
          user != null 
          ? SliverToBoxAdapter(
              child: Column(
                children: [
                  SizedBox(height: 6),
                  Icon(
                    CupertinoIcons.person_circle_fill,
                    size: 65,
                  ),
                  Text(user.username, style: TextStyle(fontWeight: FontWeight.bold),),
                  Text(user.email),
                  SizedBox(height: 12)
                ]
              )
            )
          : SliverToBoxAdapter(child: SizedBox(),),
          user != null
          ? SliverToBoxAdapter(
              child: CupertinoListSection(
                topMargin: 14,
                margin: EdgeInsets.symmetric(horizontal: 10),
                header: const Text('History'),
                children: [
                  CupertinoListTile(
                    title: userCreatedPosts.isEmpty
                      ? const Text('No food posts created yet')
                      : const Text('My food posts'),
                    leading: Icon(
                      CupertinoIcons.create_solid
                      ),
                      trailing: userCreatedPosts.isEmpty 
                      ? null
                      : const CupertinoListTileChevron(),
                      onTap: userCreatedPosts.isEmpty
                      ? null
                      : () => {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => UserPostsPage(
                              posts:  userCreatedPosts,
                              title: "Created Posts",
                            ))
                        )
                      }
                  ),
                  CupertinoListTile(
                    title: userRegisteredPosts.isEmpty
                    ? const Text("No registered foods yet")
                    : const Text('My reservations'),
                    leading: Icon(
                      CupertinoIcons.square_stack_3d_up_fill
                      ),
                    trailing: userRegisteredPosts.isEmpty
                    ? null
                    : const CupertinoListTileChevron(),
                    onTap: () => {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => UserPostsPage(
                            posts: userRegisteredPosts,
                            title: "Registered Posts"
                          )
                        )
                      )
                    }
                  ),
                ],
              ),
            )
          : SliverToBoxAdapter(child: SizedBox(),),
          user != null
          ? SliverToBoxAdapter(
              child: CupertinoListSection(
                topMargin: 14,
                margin: EdgeInsets.fromLTRB(10, 0, 10, 14),
                header: const Text('User status'),
                children: [
                  CupertinoListTile(
                    title: user.isPremium
                    ? const Text("Premium")
                    : const Text("Standard"),
                    leading: user.isPremium
                    ? Icon(
                      CupertinoIcons.bolt_fill
                    )
                    : Icon(
                      CupertinoIcons.bolt_slash_fill
                    ),
                    subtitle: user.isPremium
                    ? Text('You get notifications!')
                    : Text('Premium users get notifications...'),
                    trailing: user.isPremium
                    ? null
                    : const CupertinoListTileChevron(),
                    onTap: user.isPremium
                    ? null
                    : (){ 
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (context) => StripeWebView()
                        )
                      );
                    },
                  )
                ],
              )
            )
          : SliverToBoxAdapter(child: SizedBox(),),
          user != null
          ? SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0, vertical: 14
                ),
                child: CupertinoButton(
                  color: CupertinoColors.systemRed,
                  child: Text("Log out"), 
                  onPressed: () {
                    model.logoutUser(); 
                    setState((){
                      bearer = null;
                    });
                    }
                ),
              ),
            )
          : SliverToBoxAdapter(child: SizedBox(),)
        ]
        );      
      }
    );
}
}

