import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {

  final List<Widget> appScreens = [
    const Center(child: Text("Home")),
    const Center(child: Text("Search")),
    const Center(child: Text("Tickets")),
    const Center(child: Text("Profiles")),
  ];

  // change
  int selectedIndex = 0;
  void _onItemTapped(int index){
    setState(() {
      selectedIndex = index ;
    });
  }


  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar:AppBar(
        title: Text("My Ticket"),
        centerTitle: true ,
      ),
      body:  appScreens[selectedIndex],
      bottomNavigationBar:  BottomNavigationBar(
        currentIndex : selectedIndex,
        onTap : _onItemTapped ,
        selectedItemColor : Colors.blueGrey ,
        unselectedItemColor : const Color(0xFF526400),
        showSelectedLabels: false ,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(FluentIcons.home_24_regular),
            activeIcon: Icon(FluentIcons.home_24_filled),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(FluentIcons.search_24_regular),
            activeIcon: Icon(FluentIcons.search_24_filled),
            label: "Search",
          ),
          BottomNavigationBarItem(
            icon: Icon(FluentIcons.ticket_diagonal_24_regular),
            activeIcon: Icon(FluentIcons.ticket_diagonal_24_filled),
            label: "Tickets",
          ),
          BottomNavigationBarItem(
            icon: Icon(FluentIcons.person_24_regular),
            activeIcon: Icon(FluentIcons.person_24_filled),
            label: "Profile",
          ),
        ],
      )
    );
  }
}
