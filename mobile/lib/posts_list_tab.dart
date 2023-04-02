import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'model/app_state_model.dart';
import 'post_row_item.dart'; 
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/model/user.dart';

class PostsListTab extends StatelessWidget {
  const PostsListTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateModel>(
      builder: (context, model, child) {
        final posts = model.getPosts();
        final location = model.getLoc();
        final user = model.getUser();
        return CustomScrollView(
          slivers: <Widget>[
            CupertinoSliverNavigationBar(
              largeTitle: user != null ? Text(user.email) : Text("no user"),
            ),
            CupertinoSliverRefreshControl(
              onRefresh: () => _pullRefresh(model),
            ),
            SliverSafeArea(               
              top: false,
              minimum: const EdgeInsets.only(top: 0),
              sliver: SliverToBoxAdapter(
                child: posts != null 
                ? posts.isNotEmpty
                  ? CupertinoListSection(
                    topMargin: 0,
                    children: [
                      for (var post in posts)
                        PostRowItem(
                          post: post,
                        )
                    ],
                  )
                  : const CupertinoListTile(title: Text('No posts to show'))
                : const CupertinoListTile(title: Text('Loading posts...'))
              ),
            ),   
            SliverSafeArea(
              sliver: SliverToBoxAdapter(
                child: location == null ? Text('Location not granted') :
                Text('${location.latitude.toString()} ${location.longitude.toString()}'),
              )
            )                         
          ],
        );
      },
    );
  }

  Future<void> _pullRefresh(AppStateModel model) async {
    model.loadPosts();
  }
}