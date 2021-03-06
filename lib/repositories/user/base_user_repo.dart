import 'package:cahubshot/models/models.dart';

abstract class BaseUserRepo {
  Future<UserModel> getUserWithId({String userId});
  Future<void> updateUser({UserModel userModel});
  Future<List<UserModel>> searchUsers({String query});

  void followUser({String userId, String followUserId});
  void unfollowUser({String userId, String unfollowUserId});
  Future<bool> isFollowing({String userId, String otherUserId});

  Stream<List<UserModel>>getAllFirebaseUsers();
}
