import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:cahubshot/enums/navbar_items.dart';

part 'nav_btn_state.dart';

class NavBtnCubit extends Cubit<NavBtnState> {
  NavBtnCubit()
      : super(
          NavBtnState(
            selectedItem: BottomNavItem.feed,
          ),
        );

  void updateSelectedItem(BottomNavItem item) {
    if (item != state.selectedItem) {
      emit(NavBtnState(selectedItem: item));
    }
  }
}
