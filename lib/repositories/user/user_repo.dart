import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cahubshot/constants/firebase_collection_constants.dart';
import 'package:cahubshot/enums/notification_type.dart';
import 'package:cahubshot/models/models.dart';
import 'package:cahubshot/repositories/repositories.dart';

class UserRepo extends BaseUserRepo {
  final FirebaseFirestore _firebaseFirestore;

  UserRepo({FirebaseFirestore firebaseFirestore}) : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;

  @override
  Future<UserModel> getUserWithId({@required String userId}) async {
    final doc = await _firebaseFirestore.collection(FirebaseConstants.users).doc(userId).get();
    return doc.exists ? UserModel.fromDocument(doc) : UserModel.empty;
  }

  @override
  Future<void> updateUser({@required UserModel userModel}) async {
    await _firebaseFirestore.collection(FirebaseConstants.users).doc(userModel.id).update(
          userModel.toDocument(),
        );
  }

  @override
  Future<List<UserModel>> searchUsers({@required String query}) async {
    final userCollection = FirebaseConstants.users;
    final userSnap = await _firebaseFirestore.collection(userCollection).where("username", isGreaterThanOrEqualTo: query).get();
    return userSnap.docs.map((queryDocSnap) => UserModel.fromDocument(queryDocSnap)).toList();
  }

  @override
  void followUser({@required String userId, @required String followUserId}) {
    final followers = FirebaseConstants.followers;
    final following = FirebaseConstants.following;
    final userFollowers = FirebaseConstants.userFollowers;
    final userFollowing = FirebaseConstants.userFollowing;

    _firebaseFirestore.collection(following).doc(userId).collection(userFollowing).doc(followUserId).set({});
    _firebaseFirestore.collection(followers).doc(followUserId).collection(userFollowers).doc(userId).set({});

    final notification = NotificationModel(
      notificationType: NotificationType.follow,
      fromUser: UserModel.empty.copyWith(id: userId),
      dateTime: DateTime.now(),
    );

    final notificationsCol = FirebaseConstants.notifications;
    final userNotificationsCol = FirebaseConstants.userNotifications;
    _firebaseFirestore.collection(notificationsCol).doc(followUserId).collection(userNotificationsCol).add(
          notification.toDocument(),
        );
  }

  @override
  void unfollowUser({@required String userId, @required String unfollowUserId}) {
    final followers = FirebaseConstants.followers;
    final following = FirebaseConstants.following;
    final userFollowers = FirebaseConstants.userFollowers;
    final userFollowing = FirebaseConstants.userFollowing;

    _firebaseFirestore.collection(following).doc(userId).collection(userFollowing).doc(unfollowUserId).delete();
    _firebaseFirestore.collection(followers).doc(unfollowUserId).collection(userFollowers).doc(userId).delete();

    final notification = NotificationModel(
      notificationType: NotificationType.unfollow,
      fromUser: UserModel.empty.copyWith(id: userId),
      dateTime: DateTime.now(),
    );

    final notificationsCol = FirebaseConstants.notifications;
    final userNotificationsCol = FirebaseConstants.userNotifications;
    _firebaseFirestore.collection(notificationsCol).doc(unfollowUserId).collection(userNotificationsCol).add(
          notification.toDocument(),
        );
  }

  @override
  Future<bool> isFollowing({@required String userId, @required String otherUserId}) async {
    final following = FirebaseConstants.following;
    final userFollowing = FirebaseConstants.userFollowing;
    final otherUserDoc = await _firebaseFirestore.collection(following).doc(userId).collection(userFollowing).doc(otherUserId).get();
    return otherUserDoc.exists;
  }

  @override
  Stream<List<UserModel>> getAllFirebaseUsers() {
    final users = FirebaseConstants.users;
    return _firebaseFirestore.collection(users).snapshots().map(
          (querySnap) => querySnap.docs
              .map(
                (queryDocSnap) => UserModel.fromDocument(queryDocSnap),
              )
              .toList(),
        );
  }
}
