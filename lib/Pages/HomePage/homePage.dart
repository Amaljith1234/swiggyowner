import 'package:flutter/material.dart';

import '../DashboardPage.dart';
import '../InventoryItems/InventoryManagement.dart';
import '../MenuPage/MenuManagement.dart';
import '../OrderPage/OrderPage.dart';
import '../Settings/SettingsPage.dart';

class Homepage extends StatefulWidget {
  int selectedIndex = 0;

  Homepage({Key? key,  this.selectedIndex = 0})
      : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    this.selectedIndex = widget.selectedIndex;
  }

  final List<Widget> _screens = [
    DashboardScreen(),
    OrdersScreen(),
    MenuManagementScreen(),
    InventoryManagementScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _screens[selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.orange,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
