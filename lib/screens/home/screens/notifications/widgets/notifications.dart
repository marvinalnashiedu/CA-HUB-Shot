import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cahubshot/enums/notification_type.dart';
import 'package:cahubshot/models/models.dart';
import 'package:cahubshot/widgets/widgets.dart';
import 'package:intl/intl.dart';

import '../../screens.dart';

class Notifications extends StatelessWidget {
  final NotificationModel notificationModel;

  const Notifications({
    @required this.notificationModel,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () =>  Navigator.pushNamed(
        context,
        ProfileScreen.routeName,
        arguments: ProfileScreenArgs(userId: notificationModel.fromUser.id),
      ),
      leading: GestureDetector(
        onTap: () => Navigator.pushNamed(
          context,
          ProfileScreen.routeName,
          arguments: ProfileScreenArgs(userId: notificationModel.fromUser.id),
        ),
        child: UserProfileImage(
          radius: 18,
          profileImageURl: notificationModel.fromUser.imageUrl,
        ),
      ),
      title: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: "${notificationModel.fromUser.username}",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const TextSpan(text: " "),
            TextSpan(
              text: _getText(notificationModel),
            ),
          ],
        ),
      ),
      subtitle: Text(
        DateFormat.yMd().add_jm().format(notificationModel.dateTime),
        style: TextStyle(
          color: Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: _getTrailing(context, notificationModel),
    );
  }

  String _getText(NotificationModel notificationModel) {
    switch (notificationModel.notificationType) {
      case NotificationType.like:
        return 'liked your post.';

      case NotificationType.comment:
        return 'commented on your post.';

      case NotificationType.follow:
        return 'follows you.';

      case NotificationType.unfollow:
        return 'unfollowed you.';

      default:
        return "";
    }
  }

  Widget _getTrailing(BuildContext context, NotificationModel notificationModel) {
    if (notificationModel.notificationType == NotificationType.like || notificationModel.notificationType == NotificationType.comment) {
      return GestureDetector(
        onTap: () => Navigator.pushNamed(
          context,
          CommentScreen.routeName,
          arguments: CommentScreenArgs(postModel: notificationModel.postModel),
        ),
        child: CachedNetworkImage(
          height: 60,
          width: 60,
          imageUrl: notificationModel.postModel.imageUrl,
          fit: BoxFit.cover,
        ),
      );
    } else if (notificationModel.notificationType == NotificationType.follow || notificationModel.notificationType == NotificationType.unfollow) {
      return const SizedBox(
        height: 60,
        width: 60,
        child: Icon(Icons.person_add),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
