import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cahubshot/cubit/like_cubit/like_post_cubit.dart';
import 'package:cahubshot/models/models.dart';
import 'package:cahubshot/repositories/repositories.dart';
import 'package:cahubshot/screens/home/screens/feed/feed_bloc/feed_bloc.dart';
import 'package:cahubshot/widgets/widgets.dart';

class FeedScreen extends StatefulWidget {
  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController.offset >= _scrollController.position.maxScrollExtent && !_scrollController.position.outOfRange && context.read<FeedBloc>().state.status != FeedStatus.paginating) {
          context.read<FeedBloc>().add(FeedPaginatePostsEvent());
        }
      });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FeedBloc, FeedState>(
      listener: (context, feedState) {
        if (feedState.status == FeedStatus.error) {
          showDialog(
            context: context,
            builder: (context) => ErrorDialog(message: feedState.failure.message),
          );
        } else if (feedState.status == FeedStatus.paginating) {
          BotToast.showText(text: "Looking for more posts");
        }
      },
      builder: (context, feedState) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("CodeArise HUB Shot", style: TextStyle(color: Colors.white)),
            centerTitle: true,
            backgroundColor: Colors.blueAccent,
            actions: [
              if (feedState.postList.isEmpty && feedState.status == FeedStatus.loaded)
                IconButton(
                  onPressed: () => context.read<FeedBloc>().add(FeedFetchPostsEvent()),
                  icon: Icon(
                    Icons.refresh,
                  ),
                ),
            ],
          ),
          body: _buildBody(feedState),
        );
      },
    );
  }

  Widget _buildBody(FeedState feedState) {
    switch (feedState.status) {
      case FeedStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );

      default:
        return RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(
              Duration(milliseconds: 300),
            );
            context.read<FeedBloc>().add(FeedFetchPostsEvent());
            return true;
          },
          child: feedState.postList.isEmpty && feedState.status == FeedStatus.loaded
              ? _buildShowFirebaseUsers()
              : ListView.builder(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  itemCount: feedState.postList.length,
                  itemBuilder: (context, index) {
                    final post = feedState.postList[index];
                    final likedPostState = context.watch<LikePostCubit>().state;
                    final isLiked = likedPostState.likedPostIds.contains(post.id);
                    final recentlyLiked = likedPostState.recentlyLikedPostsIds.contains(post.id);
                    return PostView(
                      postModel: post,
                      isLiked: isLiked,
                      recentlyLiked: recentlyLiked,
                      onLike: () {
                        if (isLiked) {
                          context.read<LikePostCubit>().unLikePost(postModel: post);
                        } else {
                          context.read<LikePostCubit>().likePost(postModel: post);
                        }
                      },
                    );
                  },
                ),
        );
    }
  }

  Widget _buildShowFirebaseUsers() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: const Text(
                  'User Suggestions',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'See More',
                  style: const TextStyle(fontSize: 15, color: Colors.blue),
                ),
              )
            ],
          ),
          StreamBuilder<List<UserModel>>(
              stream: UserRepo().getAllFirebaseUsers(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final userList = snapshot.data;
                  return Container(
                    height: 160,
                    child: ListView.builder(
                      padding: EdgeInsets.only(right: 10),
                      scrollDirection: Axis.horizontal,
                      itemCount: userList.length,
                      itemBuilder: (BuildContext context, int index) {
                        final user = userList[index];
                        return SuggestionTile(user: user);
                      },
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Icon(Icons.error_outline);
                } else {
                  return CircularProgressIndicator();
                }
              })
        ],
      ),
    );
  }
}
