import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:cahubshot/constants/firebase_collection_constants.dart';
import 'package:cahubshot/models/notification_model.dart';
import 'package:cahubshot/repositories/repositories.dart';

class NotificationRepo extends BaseNotificationRepo {
  final FirebaseFirestore _firebaseFirestore;

  NotificationRepo({
    FirebaseFirestore firebaseFirestore,
  }) : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<Future<NotificationModel>>> getUserNotifications({@required String userId}) {
    final notification = FirebaseConstants.notifications;
    final userNotifications = FirebaseConstants.userNotifications;
    final snapshots = _firebaseFirestore.collection(notification).doc(userId).collection(userNotifications).orderBy("dateTime", descending: true).snapshots();

    return snapshots.map(
      (querySnaps) => querySnaps.docs.map((queryDocSnap) {
        return NotificationModel.fromDocument(queryDocSnap);
      }).toList(),
    );
  }
}
