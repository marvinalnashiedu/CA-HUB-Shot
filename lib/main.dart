import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cahubshot/blocs/blocs.dart';
import 'package:cahubshot/configuration/custom_router.dart';
import 'package:cahubshot/cubit/like_cubit/like_post_cubit.dart';
import 'package:cahubshot/repositories/repositories.dart';
import 'package:cahubshot/screens/screens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseFirestore.instance.settings =
      Settings(cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<UserRepo>(
          create: (_) => UserRepo(),
        ),
        RepositoryProvider<AuthRepo>(
          create: (_) => AuthRepo(),
        ),
        RepositoryProvider<StorageRepo>(
          create: (_) => StorageRepo(),
        ),
        RepositoryProvider<PostRepository>(
          create: (_) => PostRepository(),
        ),
        RepositoryProvider<NotificationRepo>(
          create: (_) => NotificationRepo(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authRepo: context.read<AuthRepo>(),
            ),
          ),
          BlocProvider<LikePostCubit>(
            create: (context) => LikePostCubit(
              authBloc: context.read<AuthBloc>(),
              postRepository: context.read<PostRepository>(),
            ),
          ),
          BlocProvider(
            create: (_) => UserNameChangeBloc(),
          ),
          BlocProvider(
            create: (_) => EmailChangeBloc(),
          ),
          BlocProvider(
            create: (_) => PasswordChangeBloc(),
          ),
          BlocProvider(
            create: (_) => PasswordShowHideToggleBtn(),
          ),
        ],
        child: MaterialApp(
          title: 'CodeArise HUB Shot',
          debugShowCheckedModeBanner: false,
          builder: BotToastInit(), //1. call BotToastInit
          navigatorObservers: [
            BotToastNavigatorObserver(),
          ],

          theme: ThemeData(
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.grey[50],
            appBarTheme: AppBarTheme(
              color: Colors.white,
              iconTheme: const IconThemeData(
                color: Colors.black,
              ), systemOverlayStyle: SystemUiOverlayStyle.dark, toolbarTextStyle: const TextTheme(
                headline6: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w600,
                ),
              ).bodyText2, titleTextStyle: const TextTheme(
                headline6: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w600,
                ),
              ).headline6,
            ),
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          onGenerateRoute: CustomRoute.onGenerateRoute,
          // initialRoute: "/",
          initialRoute: SplashScreen.routeName,
        ),
      ),
    );
  }
}
