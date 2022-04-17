import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:cahubshot/models/models.dart';
import 'package:cahubshot/repositories/repositories.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final UserRepo _userRepo;
  SearchCubit({@required UserRepo userRepo})
      : _userRepo = userRepo,
        super(SearchState.initial());

  void searchUser({@required String query}) async {
    emit(state.copyWith(status: SearchStatus.loading));
    try {
      final userList = await _userRepo.searchUsers(query: query);
      emit(
        state.copyWith(userList: userList, status: SearchStatus.loaded),
      );
    } catch (err) {
      emit(state.copyWith(status: SearchStatus.error, failure: Failure(message: "Something went wrong while searching for users.")));
    }
  }

  void clearSearch() {
    emit(state.copyWith(userList: [], status: SearchStatus.initial));
  }
}
