import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:cahubshot/constants/firebase_collection_constants.dart';
import 'package:cahubshot/models/models.dart';
import 'package:meta/meta.dart';

class CommentModel extends Equatable {
  final String id;
  final String postId;
  final String content;
  final UserModel author;
  final DateTime dateTime;

  const CommentModel({this.id, @required this.postId, @required this.content, @required this.author, @required this.dateTime});

  CommentModel copyWith({String id, String postId, String content, UserModel author, DateTime dateTime}) {
    return CommentModel(id: id ?? this.id, postId: postId ?? this.postId, content: content ?? this.content, author: author ?? this.author, dateTime: dateTime ?? this.dateTime);
  }

  static Future<CommentModel> fromDocument(DocumentSnapshot doc) async {
    if (doc == null) {
      return null;
    }
    final data = doc.data();
    final authorRef = data["author"] as DocumentReference;
    if (authorRef != null) {
      final authorDoc = await authorRef.get();
      if (authorDoc.exists) {
        return CommentModel(
          id: doc.id,
          postId: data["postId"] ?? "",
          content: data["content"] ?? "",
          author: UserModel.fromDocument(authorDoc),
          dateTime: (data["dateTime"] as Timestamp)?.toDate(),
        );
      }
    }
    return null;
  }

  Map<String, dynamic> toDocuments() {
    final authorId = FirebaseFirestore.instance.collection(FirebaseConstants.users).doc(author.id);
    return {
      'postId': postId,
      'content': content,
      'author': authorId,
      'dateTime': Timestamp.fromDate(dateTime),
    };
  }

  @override
  List<Object> get props => [id, postId, content, author, dateTime];
}
