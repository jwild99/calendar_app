import 'package:calendar_app/const/constant.dart';
import 'package:calendar_app/data/side_menu_data.dart';
import 'package:flutter/material.dart';

class SideMenuWidget extends StatefulWidget {
  const SideMenuWidget({super.key});

  @override
  State<SideMenuWidget> createState() => _SideMenuWidgetState();
}

class _SideMenuWidgetState extends State<SideMenuWidget> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final data = SideMenuData();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      color: const Color(0xFF171821),
      child: ListView.builder(
        itemCount: data.menu.length,
        itemBuilder: (context, index) => buildMenuEntry(data, index),
      ),
    );
  }

  Widget buildMenuEntry(SideMenuData data, int index) {
  final isSelected = selectedIndex == index;

  return Container(
    margin: const EdgeInsets.symmetric(vertical: 5),
    decoration: BoxDecoration(
      borderRadius: const BorderRadius.all(
        Radius.circular(6.0),
      ),
      color: isSelected ? selectionColor : Colors.transparent,
    ),
    child: InkWell(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => data.menu[index].screen,
          ),
        );
      },
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
            child: Icon(
              data.menu[index].icon,
              color: isSelected ? Colors.white : Colors.grey,
            ),
          ),
          Text(
            data.menu[index].title,
            style: TextStyle(
              fontSize: 16,
              color: isSelected ? const Color.fromARGB(255, 255, 192, 213) : Colors.grey,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          )
        ],
      ),
    ),
    );
  }

}
