import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cahubshot/screens/home/screens/create/create_cubit/create_cubit.dart';
import 'package:cahubshot/screens/home/screens/create/create_screen.dart';
import 'package:cahubshot/screens/home/screens/feed/feed_screen.dart';
import 'package:cahubshot/screens/home/screens/notifications/notifications_screen.dart';
import 'package:cahubshot/screens/home/screens/profile/profile_screen.dart';
import 'package:cahubshot/screens/home/screens/search/search_screen.dart';
import 'package:cahubshot/blocs/blocs.dart';
import 'package:cahubshot/configuration/custom_router.dart';
import 'package:cahubshot/cubit/like_cubit/like_post_cubit.dart';
import 'package:cahubshot/enums/navbar_items.dart';
import 'package:cahubshot/repositories/repositories.dart';
import 'package:cahubshot/screens/home/screens/feed/feed_bloc/feed_bloc.dart';
import 'package:cahubshot/screens/home/screens/search/search_cubit/search_cubit.dart';

class TabNavigator extends StatelessWidget {
  static const String tabNavigatorRoot = "/";

  final GlobalKey<NavigatorState> navigatorKey;
  final BottomNavItem item;

  const TabNavigator({Key key, this.navigatorKey, this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final routeBuilders = _routeBuilders();
    return WillPopScope(
        child: Navigator(
          key: navigatorKey,
          initialRoute: tabNavigatorRoot,
          onGenerateInitialRoutes: (_, initialRoute) {
            return [
              MaterialPageRoute(
                settings: RouteSettings(name: tabNavigatorRoot),
                builder: (context) => routeBuilders[initialRoute](context),
              ),
            ];
          },
          onGenerateRoute: CustomRoute.onGenerateNestedRoute,
        ),
        onWillPop: () async => false);
  }

  Map<String, WidgetBuilder> _routeBuilders() {
    return {tabNavigatorRoot: (context) => _getScreen(context, item)};
  }

  Widget _getScreen(BuildContext context, BottomNavItem item) {
    switch (item) {
      case BottomNavItem.feed:
        return BlocProvider(
          create: (context) => FeedBloc(
            postRepository: context.read<PostRepository>(),
            authBloc: context.read<AuthBloc>(),
            likePostCubit: context.read<LikePostCubit>(),
          )..add(FeedFetchPostsEvent()),
          child: FeedScreen(),
        );

      case BottomNavItem.search:
        return BlocProvider<SearchCubit>(
          create: (context) => SearchCubit(
            userRepo: context.read<UserRepo>(),
          ),
          child: SearchScreen(),
        );

      case BottomNavItem.create:
        return BlocProvider<CreateCubit>(
          create: (context) => CreateCubit(
            authBloc: context.read<AuthBloc>(),
            postRepository: context.read<PostRepository>(),
            storageRepo: context.read<StorageRepo>(),
          ),
          child: CreateScreen(),
        );

      case BottomNavItem.notification:
        return BlocProvider<NotificationBloc>(
          create: (context) => NotificationBloc(
            notificationRepo: context.read<NotificationRepo>(),
            authBloc: context.read<AuthBloc>(),
          ),
          child: NotificationScreen(),
        );

      case BottomNavItem.profile:
        return BlocProvider<ProfileBloc>(
          create: (_) => ProfileBloc(
            userRepo: context.read<UserRepo>(),
            authBloc: context.read<AuthBloc>(),
            postRepository: context.read<PostRepository>(),
            likePostCubit: context.read<LikePostCubit>(),
          )..add(
              ProfileLoadEvent(
                userId: context.read<AuthBloc>().state.user.uid,
              ),
            ),
          child: ProfileScreen(),
        );

      default:
        return Scaffold();
    }
  }
}
