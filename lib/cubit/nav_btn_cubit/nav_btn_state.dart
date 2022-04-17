part of 'nav_btn_cubit.dart';

class NavBtnState extends Equatable {
  final BottomNavItem selectedItem;
  const NavBtnState({@required this.selectedItem});

  @override
  List<Object> get props => [selectedItem];
}
