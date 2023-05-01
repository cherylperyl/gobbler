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
              largeTitle: Text("Gobbler")
            ),
            CupertinoSliverRefreshControl(
              onRefresh: () => _pullRefresh(model),
            ),
            SliverSafeArea(               
              top: false,
              minimum: const EdgeInsets.only(top: 0),
              sliver: SliverToBoxAdapter(
                child: posts != null 
                ? CupertinoListSection(
                    topMargin: 0,
                    children: [
                      for (var post in posts)
                        PostRowItem(
                          post: post,
                        )
                    ],
                  )
                : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: const Text('No posts to show', style: TextStyle(fontSize: 20),),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Image(
                        image: AssetImage('assets/homeemptyfridge.jpg')
                      ),
                    ),
                  ],
                )
                
              ),
            ),   
            SliverSafeArea(
              sliver: SliverToBoxAdapter(
                child: location == null 
                ? const CupertinoListTile(title: Text('Location not granted')) 
                : Container()
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