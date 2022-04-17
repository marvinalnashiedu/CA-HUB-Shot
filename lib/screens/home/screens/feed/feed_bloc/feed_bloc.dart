import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:cahubshot/blocs/auth_bloc/auth_bloc.dart';
import 'package:cahubshot/cubit/like_cubit/like_post_cubit.dart';
import 'package:cahubshot/models/models.dart';
import 'package:cahubshot/repositories/post/post_repo.dart';
import 'package:meta/meta.dart';

part 'feed_event.dart';
part 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final PostRepository _postRepository;
  final AuthBloc _authBloc;
  final LikePostCubit _likePostCubit;
  FeedBloc({@required PostRepository postRepository, @required AuthBloc authBloc, @required LikePostCubit likePostCubit})
      : _postRepository = postRepository,
        _authBloc = authBloc,
        _likePostCubit = likePostCubit,
        super(
          FeedState.initial(),
        );

  @override
  Stream<FeedState> mapEventToState(
    FeedEvent event,
  ) async* {
    if (event is FeedFetchPostsEvent) {
      yield* mapFetchFeedEventToState(event);
    } else if (event is FeedPaginatePostsEvent) {
      yield* mapPaginatingFeedEventToState(event);
    }
  }

  Stream<FeedState> mapFetchFeedEventToState(FeedFetchPostsEvent event) async* {
    yield (state.copyWith(postList: [], status: FeedStatus.loading));
    try {
      final postList = await _postRepository.getUserFeed(userId: _authBloc.state.user.uid);

      _likePostCubit.clearAllLikedPost();

      final likedPostIds = await _postRepository.getLikedPostIds(
        userId: _authBloc.state.user.uid,
        postModel: postList,
      );

      _likePostCubit.updateLikedPosts(postIds: likedPostIds);

      yield (state.copyWith(postList: postList, status: FeedStatus.loaded));
    } on FirebaseException catch (e) {
      print("Firebase Error: ${e.message}");
      yield (state.copyWith(failure: Failure(message: e.message), status: FeedStatus.error));
    } catch (e) {
      yield (state.copyWith(failure: Failure(message: "The feed could not be loaded."), status: FeedStatus.error));
      print("Unknown Error: $e");
    }
  }

  Stream<FeedState> mapPaginatingFeedEventToState(FeedPaginatePostsEvent event) async* {
    yield (state.copyWith(status: FeedStatus.paginating));
    try {
      final lastPostId = state.postList.isNotEmpty ? state.postList.last.id : null;
      final postListPaginated = await _postRepository.getUserFeed(
        userId: _authBloc.state.user.uid,
        lastPostId: lastPostId,
      );
      final updatedPostList = List<PostModel>.from(state.postList)..addAll(postListPaginated);
      final likedPostIds = await _postRepository.getLikedPostIds(
        userId: _authBloc.state.user.uid,
        postModel: postListPaginated,
      );
      _likePostCubit.updateLikedPosts(postIds: likedPostIds);

      yield (state.copyWith(postList: updatedPostList, status: FeedStatus.loaded));
    } on FirebaseException catch (e) {
      print("Firebase Error: ${e.message}");
      yield (state.copyWith(failure: Failure(message: e.message), status: FeedStatus.error));
    } catch (e) {
      print("Unknown Error: $e");
      yield (state.copyWith(failure: Failure(message: "The feed could not be loaded."), status: FeedStatus.error));
      print("Unknown Error: $e");
    }
  }
}
