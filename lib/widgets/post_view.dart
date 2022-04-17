// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cahubshot/extensions/extensions.dart';
import 'package:cahubshot/models/models.dart';
import 'package:cahubshot/screens/home/screens/screens.dart';
import 'package:cahubshot/widgets/user_profile_image.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:share_plus/share_plus.dart';

class PostView extends StatelessWidget {
  final PostModel postModel;
  final bool isLiked;
  final VoidCallback onLike;
  final bool recentlyLiked;

  const PostView({
    Key key,
    @required this.isLiked,
    @required this.postModel,
    @required this.onLike,
    this.recentlyLiked = false,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final author = postModel.author;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, ProfileScreen.routeName, arguments: ProfileScreenArgs(userId: author.id)),
            child: Row(
              children: [
                UserProfileImage(radius: 18, profileImageURl: author.imageUrl),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    author.username,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            FlutterWebBrowser.openWebPage(
              url: postModel.imageUrl,
              customTabsOptions: const CustomTabsOptions(
                colorScheme: CustomTabsColorScheme.dark,
                toolbarColor: Colors.deepPurple,
                secondaryToolbarColor: Colors.green,
                navigationBarColor: Colors.amber,
                shareState: CustomTabsShareState.on,
                instantAppsEnabled: true,
                showTitle: true,
                urlBarHidingEnabled: true,
              ),
              safariVCOptions: const SafariViewControllerOptions(
                barCollapsingEnabled: true,
                preferredBarTintColor: Colors.green,
                preferredControlTintColor: Colors.amber,
                dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
                modalPresentationCapturesStatusBarAppearance: true,
              ),
            );
          },
          onDoubleTap: onLike,
          child: CachedNetworkImage(
            height: MediaQuery.of(context).size.height / 2.25,
            width: double.infinity,
            imageUrl: postModel.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: onLike,
              icon: isLiked ? const Icon(Icons.favorite, color: Colors.indigoAccent) : const Icon(Icons.favorite_outline_rounded),
            ),
            IconButton(
              onPressed: () => Navigator.pushNamed(
                context,
                CommentScreen.routeName,
                arguments: CommentScreenArgs(postModel: postModel),
              ),
              icon: Icon(Icons.mode_comment_outlined),
            ),
            IconButton(
              onPressed: () {Share.share(postModel.imageUrl);},
              icon: Icon(Icons.share_outlined),
            ),
            IconButton(
              onPressed: () async {await ImageDownloader.downloadImage(postModel.imageUrl);},
              icon: Icon(Icons.file_download_done_rounded),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${recentlyLiked ? postModel.likes + 1 : postModel.likes} ${postModel.likes == 1 ? "like" : "likes"}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text.rich(TextSpan(children: [
                TextSpan(text: author.username, style: const TextStyle(fontWeight: FontWeight.w600)),
                TextSpan(text: " "),
                TextSpan(text: postModel.caption),
              ])),
              const SizedBox(height: 4),
              Text(
                '${postModel.dateTime.timeAgoExt()}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
