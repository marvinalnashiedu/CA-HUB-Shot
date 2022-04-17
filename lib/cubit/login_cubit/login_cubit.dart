import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:cahubshot/models/failure_model.dart';
import 'package:cahubshot/repositories/auth/auth_repo.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepo _authRepo;
  LoginCubit({@required AuthRepo authRepo})
      : _authRepo = authRepo,
        super(LoginState.initial());

  void emailChanged(String email) {
    emit(state.copyWith(
      email: email,
      status: LoginStatus.initial,
    ));
  }

  void passwordChanged(String password) {
    emit(state.copyWith(
      password: password,
      status: LoginStatus.initial,
    ));
  }

  void loginWithCredential() async {
    if (state.status == LoginStatus.progress || !state.isFormValid) return;
    emit(state.copyWith(status: LoginStatus.progress));
    try {
      await _authRepo.logInWithEmailAndPassword(email: state.email, password: state.password);
      emit(state.copyWith(status: LoginStatus.success));
    } on Failure catch (err) {
      emit(state.copyWith(
        status: LoginStatus.error,
        failure: err,
      ));
    }
  }
}
