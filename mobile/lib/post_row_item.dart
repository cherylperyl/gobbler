import 'package:flutter/cupertino.dart';
import 'package:mobile/individual_post.dart';
import 'package:provider/provider.dart';

import 'model/app_state_model.dart';
import 'model/post.dart';
import 'styles.dart';
import 'model/post_repository.dart';

class PostRowItem extends StatelessWidget {
  const PostRowItem({
    required this.post,
    super.key,
  });

  final Post post;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      minimum: const EdgeInsets.only(
        left: 0,
        top: 8,
        bottom: 8,
        right: 8,
      ),
      child: CupertinoListTile(
        onTap: () => {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => IndividualPost(post: post)
            )
          )
          },
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.network(
            post.imageLink,
            fit: BoxFit.cover,
            width: 68,
            height: 68,
          ),
        ),
        leadingSize: 68,
        title: Text(
          post.title,
          style: Styles.productRowItemName,
        ),
        subtitle: Text(
          '${post.locationDescription}',
          style: Styles.productRowItemPrice,
        ),
        trailing: const Icon(
            CupertinoIcons.chevron_right,
            semanticLabel: 'Open',
          ),
        ),
    );
  }
}