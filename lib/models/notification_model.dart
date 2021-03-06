import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:equatable/equatable.dart';
import 'package:cahubshot/constants/firebase_collection_constants.dart';
import 'package:cahubshot/enums/notification_type.dart';
import 'package:cahubshot/models/models.dart';
import 'package:meta/meta.dart';

class NotificationModel extends Equatable {
  final String id;
  final NotificationType notificationType;
  final UserModel fromUser;
  final PostModel postModel;
  final DateTime dateTime;

  const NotificationModel({
    this.id,
    @required this.notificationType,
    @required this.fromUser,
    this.postModel,
    @required this.dateTime,
  });

  Map<String, dynamic> toDocument() {
    final _firebaseInstance = FirebaseFirestore.instance;
    final notificationEnumType = EnumToString.convertToString(notificationType);
    final fromUserDocRef = _firebaseInstance.collection(FirebaseConstants.users).doc(fromUser.id);
    final postDocRef = _firebaseInstance.collection(FirebaseConstants.posts).doc(postModel?.id);
    return {
      'NotificationType': notificationEnumType,
      'fromUser': fromUserDocRef,
      'post': postModel != null ? postDocRef : null,
      'dateTime': Timestamp.fromDate(dateTime),
    };
  }

  static Future<NotificationModel> fromDocument(DocumentSnapshot doc) async {
    if (doc == null) {
      return null;
    }
    final data = doc.data();
    final notificationEnumType = EnumToString.fromString(NotificationType.values, data["NotificationType"]);
    final fromUserDocRef = data["fromUser"] as DocumentReference;
    final postDocRef = data["post"] as DocumentReference;

    if (fromUserDocRef != null) {
      final fromUserDoc = await fromUserDocRef.get();
      if (postDocRef != null) {
        final postDoc = await postDocRef.get();
        if (postDoc.exists) {
          return NotificationModel(
            id: doc.id,
            notificationType: notificationEnumType,
            fromUser: UserModel.fromDocument(fromUserDoc),
            postModel: await PostModel.fromDocument(postDoc),
            dateTime: (data["dateTime"] as Timestamp)?.toDate(),
          );
        }
      } else {
        return NotificationModel(
          id: doc.id,
          notificationType: notificationEnumType,
          fromUser: UserModel.fromDocument(fromUserDoc),
          dateTime: (data["dateTime"] as Timestamp)?.toDate(),
        );
      }
    }
    return null;
  }

  NotificationModel copyWith({
    String id,
    NotificationType notificationType,
    UserModel fromUser,
    PostModel postModel,
    DateTime dateTime,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      notificationType: notificationType ?? this.notificationType,
      fromUser: fromUser ?? this.fromUser,
      postModel: postModel ?? this.postModel,
      dateTime: dateTime ?? this.dateTime,
    );
  }

  @override
  List<Object> get props => [id, notificationType, fromUser, postModel, dateTime];
}
