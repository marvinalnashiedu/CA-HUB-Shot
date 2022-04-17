import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cahubshot/assets/assets.dart';
import 'package:cahubshot/blocs/credentials_bloc/credentials_blocs.dart';
import 'package:cahubshot/constants/const_size_boxes.dart';
import 'package:cahubshot/cubit/login_cubit/login_cubit.dart';
import 'package:cahubshot/repositories/auth/auth_repo.dart';
import 'package:cahubshot/screens/screens.dart';
import 'package:cahubshot/styles/decorations/custom_decoration.dart';
import 'package:cahubshot/widgets/error_dialog.dart';
import 'package:cahubshot/widgets/loading_dialog.dart';

import '../home/screens/navigation/navbar.dart';

class LoginScreen extends StatelessWidget {
  static const String routeName = "/login";

  static Route route() {
    return PageRouteBuilder(
      settings: RouteSettings(name: routeName),
      transitionDuration: const Duration(seconds: 0),
      pageBuilder: (context, __, ___) => BlocProvider<LoginCubit>(
        create: (context) => LoginCubit(
          authRepo: context.read<AuthRepo>(),
        ),
        child: LoginScreen(),
      ),
    );
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameTextEditingController = TextEditingController();
  final TextEditingController _passwordTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final EdgeInsets defaultPadding = EdgeInsets.symmetric(horizontal: 20.0);

    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, loginState) {
        if (loginState.status == LoginStatus.error) {
          Navigator.of(context, rootNavigator: true).pop();
          BotToast.closeAllLoading();
          BotToast.showText(text: loginState.failure.message);
          showDialog(
            context: context,
            builder: (context) {
              return ErrorDialog(
                title: "Error logging in",
                message: loginState.failure.message,
              );
            },
          );
        } else if (loginState.status == LoginStatus.success) {
          BotToast.closeAllLoading();
          BotToast.showText(text: "You were successfully logged in");
          Navigator.pushReplacementNamed(context, NavBar.routeName);
        } else if (loginState.status == LoginStatus.progress) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return LoadingDialog(
                loadingMessage: "Logging you in...",
              );
            },
          );
        } else if (loginState.status == LoginStatus.initial) {}
      },
      builder: (context, loginState) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            body: WillPopScope(
              onWillPop: () async {
                return await _resetAllBloc(context);
              },
              child: SafeArea(
                child: GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: Container(
                    padding: defaultPadding,
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        children: [
                          sbH200,
                          _buildInstaImg(),
                          sbH40,
                          _buildFormFields(context),
                          sbH20,
                          _buildLogInBtn(context, loginState.status == LoginStatus.progress),
                          sbH10,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            bottomSheet: _buildBottomSheetText(context),
          ),
        );
      },
    );
  }

  _resetAllBloc(BuildContext context) {
    BlocProvider.of<EmailChangeBloc>(context).add(null);
    BlocProvider.of<PasswordChangeBloc>(context).add(null);
    BlocProvider.of<PasswordShowHideToggleBtn>(context).add(true);
  }

  Widget _buildBottomSheetText(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _resetAllBloc(context);
        Navigator.pushNamed(context, SignUpScreen.routeName);
      },
      child: Material(
        elevation: 10.0,
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: 15.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: 'Don\'t have an account? ',
                  style: Theme.of(context).textTheme.caption,
                  children: [
                    TextSpan(
                      text: "Sign up.",
                      style: Theme.of(context).textTheme.caption.copyWith(
                            fontSize: 14.0,
                            color: Theme.of(context).textTheme.subtitle2.color,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogInBtn(BuildContext context, bool isSubmitting) {
    return BlocBuilder<EmailChangeBloc, bool>(
      builder: (context, emailState) {
        return BlocBuilder<PasswordChangeBloc, bool>(
          builder: (context, passwordState) {
            return FractionallySizedBox(
              widthFactor: 1,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  onPrimary: Colors.white,
                  onSurface: !(emailState && passwordState) ? Colors.blue : null,
                  padding: EdgeInsets.symmetric(vertical: 14.0),
                ),
                child: Text(
                  "Log In",
                ),
                onPressed: !(emailState && passwordState)
                    ? null
                    : () {
                        if (_formKey.currentState.validate() && !isSubmitting) {
                          context.read<LoginCubit>().loginWithCredential();
                        }
                      },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFormFields(BuildContext context) {
    final node = FocusScope.of(context);
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _usernameTextEditingController,
            validator: (value) {
              if (value.isEmpty || value == null || value.length < 3 || !value.contains("@")) {
                return "The entered e-mail is invalid";
              } else
                return null;
            },
            decoration: customInputDecoration.copyWith(
              hintText: "E-mail",
              hintStyle: Theme.of(context).textTheme.caption,
            ),
            onChanged: (email) {
              BlocProvider.of<EmailChangeBloc>(context).add(email);
              context.read<LoginCubit>().emailChanged(email);
            },
            onEditingComplete: () => node.nextFocus(),
          ),
          sbH20,
          BlocBuilder<PasswordShowHideToggleBtn, bool>(
            builder: (context, passwordState) {
              return TextFormField(
                controller: _passwordTextEditingController,
                obscureText: passwordState ? true : false,
                validator: (value) {
                  if (value.isEmpty || value == null || value.length < 6) {
                    return "The entered password is invalid";
                  } else
                    return null;
                },
                decoration: customInputDecoration.copyWith(
                  hintText: "Password",
                  hintStyle: Theme.of(context).textTheme.caption,
                  suffixIcon: IconButton(
                    icon: Icon(
                      passwordState ? Icons.visibility_off : Icons.visibility,
                      color: passwordState ? Colors.grey : null,
                    ),
                    onPressed: () {
                      BlocProvider.of<PasswordShowHideToggleBtn>(context).add(!passwordState);
                    },
                  ),
                ),
                onChanged: (password) {
                  BlocProvider.of<PasswordChangeBloc>(context).add(password);
                  context.read<LoginCubit>().passwordChanged(password);
                },
                onEditingComplete: () => node.unfocus(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInstaImg() {
    return Center(
      child: Image.asset(
        Assets.hubShotLogo,
        height: 86.0,
      ),
    );
  }
}
