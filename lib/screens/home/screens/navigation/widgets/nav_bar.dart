import 'package:flutter/material.dart';
import 'package:cahubshot/enums/navbar_items.dart';

class MainNavBar extends StatelessWidget {
  final Map<BottomNavItem, IconData> items;
  final BottomNavItem selectedItem;
  final Function(int) onTap;

  const MainNavBar({
    @required this.items,
    @required this.selectedItem,
    @required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
        onTap: onTap,
        backgroundColor: Colors.white,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        currentIndex: BottomNavItem.values.indexOf(selectedItem),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: items
            .map((item, icon) {
              return MapEntry(
                item,
                BottomNavigationBarItem(
                  icon: Icon(icon, size: 30.0),
                  label: item.toString(),
                  tooltip: item.toString(),
                ),
              );
            })
            .values
            .toList());
  }
}
