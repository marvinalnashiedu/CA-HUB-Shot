import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:cahubshot/blocs/auth_bloc/auth_bloc.dart';
import 'package:cahubshot/cubit/like_cubit/like_post_cubit.dart';
import 'package:cahubshot/models/models.dart';
import 'package:cahubshot/repositories/repositories.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepo _userRepo;
  final AuthBloc _authBloc;
  //for posts
  final PostRepository _postRepository;
  //for likes
  final LikePostCubit _likePostCubit;
  StreamSubscription<List<Future<PostModel>>> _postsSubscription;

  /// we are using user repo and auth repo to compare currently login user and profile reviewing
  /// if both match we confirm we are looking to own profile

  ProfileBloc({
    @required UserRepo userRepo,
    @required AuthBloc authBloc,
    @required PostRepository postRepository,
    @required LikePostCubit likePostCubit,
  })  : _authBloc = authBloc,
        _userRepo = userRepo,
        _postRepository = postRepository,
        _likePostCubit = likePostCubit,
        super(ProfileState.initial());

  @override
  Future<void> close() {
    _postsSubscription?.cancel();
    return super.close();
  }

  @override
  Stream<ProfileState> mapEventToState(
    ProfileEvent event,
  ) async* {
    if (event is ProfileLoadEvent) {
      yield* _mapProfileLoadEventToState(event);
    } else if (event is ProfileToggleGridViewEvent) {
      yield* _mapProfileToggleGridViewEventToState(event);
    } else if (event is ProfileUpdatePostsEvent) {
      yield* _mapProfileUpdatePostsEventToState(event);
    } else if (event is ProfileFollowUserEvent) {
      yield* _mapProfileFollowUserEventToState(event);
    } else if (event is ProfileUnfollowUserEvent) {
      yield* _mapProfileUnfollowUserEventToState(event);
    }
  }

  Stream<ProfileState> _mapProfileLoadEventToState(ProfileLoadEvent event) async* {
    if (state.status == ProfileStatus.loaded) {
      yield state.copyWith(status: ProfileStatus.loaded);
    } else {
      yield state.copyWith(status: ProfileStatus.loading);
    }

    try {
      final user = await _userRepo.getUserWithId(userId: event.userId);
      final currentUserId = _authBloc.state.user.uid;
      final isCurrentUser = currentUserId == event.userId;
      final isFollowing = await _userRepo.isFollowing(userId: _authBloc.state.user.uid, otherUserId: event.userId);
      _postsSubscription?.cancel();
      _postsSubscription = _postRepository.getUserPosts(userId: event.userId).listen((futurePostList) async {
        final allPosts = await Future.wait(futurePostList);
        add(
          ProfileUpdatePostsEvent(postList: allPosts),
        );
      });

      yield state.copyWith(
        userModel: user,
        isCurrentUser: isCurrentUser,
        isFollowing: isFollowing,
        status: ProfileStatus.loaded,
      );
    } on FirebaseException catch (e) {
      yield state.copyWith(
        status: ProfileStatus.failure,
        failure: Failure(message: "${e.message}"),
      );
    } catch (e) {
      yield state.copyWith(
        status: ProfileStatus.failure,
        failure: const Failure(message: "This profile could not be loaded."),
      );
    }
  }

  Stream<ProfileState> _mapProfileToggleGridViewEventToState(ProfileToggleGridViewEvent event) async* {
    yield state.copyWith(isGridView: event.isGridView);
  }

  Stream<ProfileState> _mapProfileUpdatePostsEventToState(ProfileUpdatePostsEvent event) async* {
    yield state.copyWith(posts: event.postList);
    final likedPostIds = await _postRepository.getLikedPostIds(
      userId: _authBloc.state.user.uid,
      postModel: event.postList,
    );
    _likePostCubit.updateLikedPosts(postIds: likedPostIds);
  }

  Stream<ProfileState> _mapProfileFollowUserEventToState(ProfileFollowUserEvent event) async* {
    try {
      _userRepo.followUser(userId: _authBloc.state.user.uid, followUserId: state.userModel.id);
      final updatedUser = state.userModel.copyWith(followers: state.userModel.followers + 1);
      yield state.copyWith(userModel: updatedUser, isFollowing: true);
    } on FirebaseException catch (e) {
      yield state.copyWith(status: ProfileStatus.failure, failure: Failure(message: e.message));
    } catch (e) {
      yield state.copyWith(status: ProfileStatus.failure, failure: Failure(message: "An error has occured."));
    }
  }

  Stream<ProfileState> _mapProfileUnfollowUserEventToState(ProfileUnfollowUserEvent event) async* {
    try {
      _userRepo.unfollowUser(userId: _authBloc.state.user.uid, unfollowUserId: state.userModel.id);
      final updatedUser = state.userModel.copyWith(followers: state.userModel.followers - 1);
      yield state.copyWith(userModel: updatedUser, isFollowing: false);
    } on FirebaseException catch (e) {
      yield state.copyWith(status: ProfileStatus.failure, failure: Failure(message: e.message));
    } catch (e) {
      yield state.copyWith(status: ProfileStatus.failure, failure: Failure(message: "An error has occured."));
    }
  }
}
