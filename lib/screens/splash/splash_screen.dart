import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cahubshot/blocs/auth_bloc/auth_bloc.dart';
import 'package:cahubshot/screens/auth/login_screen.dart';
import '../home/screens/navigation/navbar.dart';

class SplashScreen extends StatelessWidget {
  static const routeName = '/splash';

  static Route route() {
    return MaterialPageRoute(
      settings: RouteSettings(name: SplashScreen.routeName),
      builder: (_) => SplashScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.authenticated) {
            Navigator.of(context).pushNamed(NavBar.routeName);
          } else if (state.status == AuthStatus.unauthenticated) {
            Navigator.pushNamed(context, LoginScreen.routeName);
          }
        },
        child: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
