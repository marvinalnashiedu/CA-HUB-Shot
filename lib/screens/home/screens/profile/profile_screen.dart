import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cahubshot/blocs/blocs.dart';
import 'package:cahubshot/cubit/like_cubit/like_post_cubit.dart';
import 'package:cahubshot/repositories/repositories.dart';
import 'package:cahubshot/screens/home/screens/comment/comment_screen.dart';
import 'package:cahubshot/widgets/widgets.dart';
import 'widgets/widgets.dart';

class ProfileScreenArgs {
  final String userId;
  ProfileScreenArgs({@required this.userId});
}

class ProfileScreen extends StatefulWidget {
  static const String routeName = "/profile";

  static Route route({@required ProfileScreenArgs args}) {
    return MaterialPageRoute(
      settings: RouteSettings(name: ProfileScreen.routeName),
      builder: (context) => BlocProvider<ProfileBloc>(
        create: (_) => ProfileBloc(
          userRepo: context.read<UserRepo>(),
          authBloc: context.read<AuthBloc>(),
          postRepository: context.read<PostRepository>(),
          likePostCubit: context.read<LikePostCubit>(),
        )..add(ProfileLoadEvent(userId: args.userId)),
        child: ProfileScreen(),
      ),
    );
  }

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  TabController _tabController;

  final tabList = [
    Tab(icon: Icon(Icons.grid_on, size: 28)),
    Tab(icon: Icon(Icons.list, size: 28)),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabList.length, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, profileState) {
        if (profileState.status == ProfileStatus.failure) {
          Navigator.of(context, rootNavigator: true).pop();
          BotToast.closeAllLoading();
          BotToast.showText(text: profileState.failure.message);
          showDialog(
            context: context,
            builder: (context) {
              return ErrorDialog(
                title: "Error signing in",
                message: profileState.failure.message,
              );
            },
          );
        }
      },
      builder: (context, profileState) {
        return _buildBody(profileState);
      },
    );
  }

  Widget _buildBody(ProfileState profileState) {
    switch (profileState.status) {
      case ProfileStatus.loading:
        return Scaffold(body: Center(child: CircularProgressIndicator()));
      default:
        return Scaffold(
          appBar: AppBar(
            title: Text(profileState.userModel.username, style: TextStyle(color: Colors.white)),
            centerTitle: true,
            backgroundColor: Colors.blueAccent,
            actions: [
              if (profileState.isCurrentUser)
                IconButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(
                          AuthLogOutRequestedEvent(),
                        );
                    context.read<LikePostCubit>().clearAllLikedPost();
                  },
                  icon: Icon(Icons.exit_to_app),
                  color: Colors.white,
                )
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              context.read<ProfileBloc>().add(ProfileLoadEvent(userId: profileState.userModel.id));
              await Future.delayed(
                Duration(milliseconds: 500),
              );
              return true;
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            UserProfileImage(
                              radius: 40,
                              profileImageURl: profileState.userModel.imageUrl,
                            ),
                            ProfileStat(
                              isCurrentUser: profileState.isCurrentUser,
                              isFollowing: profileState.isFollowing,
                              posts: profileState.posts.length,
                              followers: profileState.userModel.followers,
                              following: profileState.userModel.following,
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          child: ProfileInfo(
                            username: profileState.userModel.username,
                            bio: profileState.userModel.bio,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Theme.of(context).primaryColor,
                    unselectedLabelColor: Colors.grey,
                    tabs: tabList,
                    indicatorWeight: 3,
                    onTap: (index) {
                      context.read<ProfileBloc>().add(
                            ProfileToggleGridViewEvent(isGridView: index == 0),
                          );
                    },
                  ),
                ),
                profileState.isGridView
                    ? SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 2,
                          crossAxisSpacing: 2,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final post = profileState.posts[index];
                            return GestureDetector(
                              onTap: () => Navigator.pushNamed(
                                context,
                                CommentScreen.routeName,
                                arguments: CommentScreenArgs(postModel: post),
                              ),
                              child: CachedNetworkImage(
                                imageUrl: post.imageUrl,
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                          childCount: profileState.posts.length,
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final post = profileState.posts[index];
                            final likedPostState = context.watch<LikePostCubit>().state;
                            final isLiked = likedPostState.likedPostIds.contains(post.id);
                            return PostView(
                              postModel: post,
                              isLiked: isLiked,
                              onLike: () {
                                if (isLiked) {
                                  context.read<LikePostCubit>().unLikePost(postModel: post);
                                } else {
                                  context.read<LikePostCubit>().likePost(postModel: post);
                                }
                              },
                            );
                          },
                          childCount: profileState.posts.length,
                        ),
                      ),
              ],
            ),
          ),
        );
    }
  }
}
