import 'package:flutter/material.dart';
import 'package:cahubshot/screens/home/screens/screens.dart';
import 'package:cahubshot/screens/screens.dart';

import '../screens/home/screens/navigation/navbar.dart';

class CustomRoute {
  static Route onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          settings: RouteSettings(name: '/'),
          builder: (_) => InitialRoutePage(),
        );
      case SplashScreen.routeName:
        return SplashScreen.route();
      case LoginScreen.routeName:
        return LoginScreen.route();
      case SignUpScreen.routeName:
        return SignUpScreen.route();
      case NavBar.routeName:
        return NavBar.route();
      case HomePage.routeName:
        return HomePage.route();
      default:
        return _errorRoute();
    }
  }

  static Route onGenerateNestedRoute(RouteSettings settings) {
    switch (settings.name) {
      case EditProfile.routeName:
        return EditProfile.route(args: settings.arguments);
      case ProfileScreen.routeName:
        return ProfileScreen.route(args: settings.arguments);
      case CommentScreen.routeName:
        return CommentScreen.route(args: settings.arguments);
      default:
        return _errorRoute();
    }
  }

  static Route _errorRoute() {
    return MaterialPageRoute(
      settings: RouteSettings(name: '/error'),
      builder: (_) => ErrorRoutePage(),
    );
  }
}

class InitialRoutePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Text(
            'Initial Route',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class ErrorRoutePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Text(
            'Error Route',
            style: TextStyle(
              color: Colors.red,
              fontSize: 20.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
