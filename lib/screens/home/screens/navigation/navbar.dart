import 'package:cahubshot/screens/home/screens/navigation/widgets/nav_bar.dart';
import 'package:cahubshot/screens/home/screens/navigation/widgets/tab_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cahubshot/cubit/nav_btn_cubit/nav_btn_cubit.dart';
import 'package:cahubshot/enums/navbar_items.dart';

class NavBar extends StatelessWidget {
  static const String routeName = "/navbar";

  static Route route() {
    return MaterialPageRoute(
      settings: RouteSettings(name: routeName),
      builder: (context) => BlocProvider<NavBtnCubit>(
        create: (context) => NavBtnCubit(),
        child: NavBar(),
      ),
    );
  }

  final Map<BottomNavItem, GlobalKey<NavigatorState>> navigatorKeys = {
    BottomNavItem.feed: GlobalKey<NavigatorState>(),
    BottomNavItem.search: GlobalKey<NavigatorState>(),
    BottomNavItem.create: GlobalKey<NavigatorState>(),
    BottomNavItem.notification: GlobalKey<NavigatorState>(),
    BottomNavItem.profile: GlobalKey<NavigatorState>(),
  };

  final Map<BottomNavItem, IconData> items = {
    BottomNavItem.feed: Icons.home_outlined,
    BottomNavItem.search: Icons.search_rounded,
    BottomNavItem.create: Icons.add_circle_outline_rounded,
    BottomNavItem.notification: Icons.favorite_border_rounded,
    BottomNavItem.profile: Icons.person_outline_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavBtnCubit, NavBtnState>(
      builder: (context, state) {
        return Scaffold(
          body: Stack(
            children: items
                .map(
                  (item, _) => MapEntry(
                    item,
                    _buildOffstageNavigator(
                      item,
                      item == state.selectedItem,
                    ),
                  ),
                )
                .values
                .toList(),
          ),
          bottomNavigationBar: MainNavBar(
            items: items,
            onTap: (index) {
              final selectedItem = BottomNavItem.values[index];
              _selecteBottomNavItem(
                  context, selectedItem, selectedItem == state.selectedItem);
            },
            selectedItem: state.selectedItem,
          ),
        );
      },
    );
  }

  void _selecteBottomNavItem(
      BuildContext context, BottomNavItem selectedItem, bool isSameItem) {
    if (isSameItem) {
      navigatorKeys[selectedItem]
          .currentState
          .popUntil((route) => route.isFirst);
    }
    context.read<NavBtnCubit>().updateSelectedItem(selectedItem);
  }

  Widget _buildOffstageNavigator(BottomNavItem currentItem, bool isSelecetd) {
    return Offstage(
      offstage: !isSelecetd,
      child: TabNavigator(
        navigatorKey: navigatorKeys[currentItem],
        item: currentItem,
      ),
    );
  }
}
