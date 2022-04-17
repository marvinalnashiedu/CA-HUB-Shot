import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:cahubshot/constants/firebase_collection_constants.dart';
import 'package:cahubshot/enums/notification_type.dart';
import 'package:cahubshot/models/models.dart';
import 'package:cahubshot/repositories/post/base_post_repo.dart';

class PostRepository extends BasePostRepo {
  final FirebaseFirestore _firebaseFirestore;

  PostRepository({FirebaseFirestore firebaseFirestore}) : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;

  @override
  Future<void> createPost({@required PostModel postModel}) async {
    final postCollection = FirebaseConstants.posts;
    await _firebaseFirestore.collection(postCollection).add(
          postModel.toDocuments(),
        );
  }

  @override
  Future<void> createComment({@required PostModel postModel, @required CommentModel commentModel}) async {
    final commentCollection = FirebaseConstants.comments;
    final postCommentCollection = FirebaseConstants.postComments;
    await _firebaseFirestore.collection(commentCollection).doc(commentModel.postId).collection(postCommentCollection).add(
          commentModel.toDocuments(),
        );

    if (postModel.author.id != commentModel.author.id) {
      final notification = NotificationModel(
        notificationType: NotificationType.comment,
        fromUser: commentModel.author,
        postModel: postModel,
        dateTime: DateTime.now(),
      );

      final notificationsCol = FirebaseConstants.notifications;
      final userNotificationsCol = FirebaseConstants.userNotifications;
      _firebaseFirestore.collection(notificationsCol).doc(postModel.author.id).collection(userNotificationsCol).add(
            notification.toDocument(),
          );
    }
  }

  @override
  Stream<List<Future<PostModel>>> getUserPosts({@required String userId}) {
    final userCollection = FirebaseConstants.users;
    final postCollection = FirebaseConstants.posts;
    final authorRef = _firebaseFirestore.collection(userCollection).doc(userId);
    return _firebaseFirestore.collection(postCollection).where('author', isEqualTo: authorRef).orderBy("dateTime", descending: true).snapshots().map(
          (querySnap) => querySnap.docs
              .map(
                (queryDocSnap) => PostModel.fromDocument(queryDocSnap),
              )
              .toList(),
        );
  }

  @override
  Stream<List<Future<CommentModel>>> getPostComment({@required String postId}) {
    final commentCollection = FirebaseConstants.comments;
    final postCommentsSubCollection = FirebaseConstants.postComments;
    return _firebaseFirestore.collection(commentCollection).doc(postId).collection(postCommentsSubCollection).orderBy("dateTime", descending: false).snapshots().map(
          (querySnap) => querySnap.docs
              .map(
                (queryDoc) => CommentModel.fromDocument(
                  queryDoc,
                ),
              )
              .toList(),
        );
  }

  @override
  Future<List<PostModel>> getUserFeed({@required String userId, String lastPostId}) async {
    final feeds = FirebaseConstants.feeds;
    final userFeed = FirebaseConstants.userFeed;
    QuerySnapshot postsSnap;
    if (lastPostId == null) {
      postsSnap = await _firebaseFirestore.collection(feeds).doc(userId).collection(userFeed).orderBy("dateTime", descending: true).limit(15).get();
    } else {
      final lastPostDoc = await _firebaseFirestore.collection(feeds).doc(userId).collection(userFeed).doc(lastPostId).get();
      if (!lastPostDoc.exists) {
        return [];
      }
      postsSnap = await _firebaseFirestore.collection(feeds).doc(userId).collection(userFeed).orderBy("dateTime", descending: true).startAfterDocument(lastPostDoc).limit(15).get();
    }

    final futurePostList = Future.wait(postsSnap.docs.map((post) => PostModel.fromDocument(post)).toList());
    return futurePostList;
  }

  @override
  void createLike({@required PostModel postModel, @required String userId}) async {
    final likes = FirebaseConstants.likes;
    final postLikes = FirebaseConstants.postLikes;
    final posts = FirebaseConstants.posts;
    _firebaseFirestore.collection(posts).doc(postModel.id).update({"likes": FieldValue.increment(1)});
    _firebaseFirestore.collection(likes).doc(postModel.id).collection(postLikes).doc(userId).set({});

    if (postModel.author.id != userId) {
      final notification = NotificationModel(
        notificationType: NotificationType.like,
        fromUser: UserModel.empty.copyWith(id: userId),
        postModel: postModel,
        dateTime: DateTime.now(),
      );

      final notificationsCol = FirebaseConstants.notifications;
      final userNotificationsCol = FirebaseConstants.userNotifications;
      _firebaseFirestore.collection(notificationsCol).doc(postModel.author.id).collection(userNotificationsCol).add(
            notification.toDocument(),
          );
    }
  }

  @override
  void deleteLike({@required String postId, @required String userId}) {
    final likes = FirebaseConstants.likes;
    final postLikes = FirebaseConstants.postLikes;
    final posts = FirebaseConstants.posts;
    _firebaseFirestore.collection(posts).doc(postId).update({"likes": FieldValue.increment(-1)});
    _firebaseFirestore.collection(likes).doc(postId).collection(postLikes).doc(userId).delete();
  }

  @override
  Future<Set<String>> getLikedPostIds({@required String userId, @required List<PostModel> postModel}) async {
    final likesCollection = FirebaseConstants.likes;
    final postLikesCollection = FirebaseConstants.postLikes;
    final postIds = <String>{};
    for (final post in postModel) {
      final likedDoc = await _firebaseFirestore.collection(likesCollection).doc(post.id).collection(postLikesCollection).doc(userId).get();
      if (likedDoc.exists) {
        postIds.add(post.id);
      }
    }
    return postIds;
  }
}
