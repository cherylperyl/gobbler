import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/login_page.dart';
import 'package:mobile/model/post.dart';
import 'package:intl/intl.dart';
import 'package:mobile/post_row_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/model/app_state_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserPostsPage extends StatefulWidget {
  UserPostsPage({
    super.key,
    required this.title
  });
  String title;
  @override
  State<UserPostsPage> createState() => _UserPostsPageState();
}

class _UserPostsPageState extends State<UserPostsPage> {
  bool isLoading = false;
  int availableReservations = 0;

  @override
  void initState() {  
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
      return Consumer<AppStateModel>(
        builder: (context, model, child) {
          List<Post>? posts;
          if (widget.title == 'Reserved Posts') {
            posts = model.getUserRegisteredPosts();
          } else {
            posts = model.getUserCreatedPosts();
          }
          return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text(widget.title),
          ),
          child: CustomScrollView(
            slivers: [
              CupertinoSliverRefreshControl(
                onRefresh: () => _pullRefresh(model),
              ),
              SliverSafeArea(
                sliver: SliverToBoxAdapter(
                  child: CupertinoListSection(
                    topMargin: 0,
                    children: posts.isEmpty
                    ? [ const CupertinoListTile(title: Text('No posts to show')) ]
                    : [ for (var post in posts) 
                        PostRowItem(
                          post: post
                        )
                      ],
                  ),
                )
              )
            ],
        
          ),
          );
        }
      ); 
  }
  Future<void> _pullRefresh(AppStateModel model) async {
    model.getUserRegisteredPosts();
    model.getUserCreatedPosts();
  }
}