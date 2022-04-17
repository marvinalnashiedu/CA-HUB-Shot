import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:cahubshot/constants/firebase_collection_constants.dart';
import 'package:cahubshot/models/models.dart';
import 'package:meta/meta.dart';

class PostModel extends Equatable {
  const PostModel({
    this.id,
    @required this.caption,
    @required this.imageUrl,
    @required this.author,
    @required this.likes,
    @required this.dateTime,
  });

  final String id;
  final String caption;
  final String imageUrl;
  final UserModel author;
  final int likes;
  final DateTime dateTime;

  PostModel copyWith({
    String id,
    String caption,
    String imageUrl,
    UserModel author,
    int likes,
    DateTime dateTime,
  }) {
    return new PostModel(
      id: id ?? this.id,
      caption: caption ?? this.caption,
      imageUrl: imageUrl ?? this.imageUrl,
      author: author ?? this.author,
      likes: likes ?? this.likes,
      dateTime: dateTime ?? this.dateTime,
    );
  }

  @override
  List<Object> get props => [caption, imageUrl, author, likes, dateTime];

  Map<String, dynamic> toDocuments() {
    final authorDocsRef = FirebaseFirestore.instance.collection(FirebaseConstants.users).doc(author.id);
    return {
      'caption': caption,
      'imageUrl': imageUrl,
      'author': authorDocsRef,
      'likes': likes,
      'dateTime': Timestamp.fromDate(dateTime),
    };
  }

  static Future<PostModel> fromDocument(DocumentSnapshot doc) async {
    if (doc == null) {
      return null;
    }
    final data = doc.data();
    final authorRef = data["author"] as DocumentReference;
    if (authorRef != null) {
      final authorDoc = await authorRef.get();
      if (authorDoc.exists) {
        return PostModel(
          id: doc.id,
          caption: data["caption"] ?? "",
          imageUrl: data["imageUrl"] ?? "",
          author: UserModel.fromDocument(authorDoc),
          likes: (data["likes"] ?? 0).toInt(),
          dateTime: (data["dateTime"] as Timestamp)?.toDate(),
        );
      }
    }
    return null;
  }
}
