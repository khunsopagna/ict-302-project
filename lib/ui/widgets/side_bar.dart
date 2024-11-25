import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:task_flow/models/menu.dart';
import 'package:task_flow/ui/screens/side_bar_entry/calendar.dart';
import 'package:task_flow/ui/screens/side_bar_entry/entry_point.dart';
import 'package:task_flow/ui/screens/side_bar_entry/highlight.dart';
import 'package:task_flow/ui/screens/side_bar_entry/search.dart';
import 'package:task_flow/utils/rive_utils.dart';
import 'package:task_flow/utils/theme.dart';

import 'info_card.dart';
import 'side_menu.dart';

class SideBar extends StatefulWidget {
  const SideBar({super.key});

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  Menu selectedSideMenu = sidebarMenus.first;
  int currentIndex = 0;

  void onIndexChanged(int index) {
    setState(() {
      currentIndex = index;
      Get.to(pages[index]);
    });
  }

  List pages = [
    const EntryPoint(),
    const Calendar(),
    const Search(),
    const Highlight(),
  ];

  TextEditingController nameController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    bioController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    nameController.text = "ICT 302 Dev";
    bioController.text = "Group Project";
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: 288,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF17203A),
          borderRadius: BorderRadius.all(
            Radius.circular(30),
          ),
        ),
        child: DefaultTextStyle(
          style: const TextStyle(color: Colors.white),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InfoCard(
                name: TextFormField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Edit Name'),
                        content: TextFormField(
                          controller: nameController,
                          style: const TextStyle(color: Colors.black),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              setState(() {});
                              Navigator.of(context).pop();
                            },
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                bio: TextFormField(
                  controller: bioController,
                  style: const TextStyle(color: Colors.grey),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Edit Bio'),
                        content: TextFormField(
                          controller: bioController,
                          style: const TextStyle(color: Colors.black),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              setState(() {});
                              Navigator.of(context).pop();
                            },
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24, top: 32, bottom: 16),
                child: Text(
                  "Browse".toUpperCase(),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: Colors.white70),
                ),
              ),
              ...sidebarMenus
                  .map((menu) => SideMenu(
                        menu: menu,
                        selectedMenu: selectedSideMenu,
                        press: () {
                          RiveUtils.changeSMIBoolState(menu.rive.status!);
                          setState(() {
                            int index;
                            selectedSideMenu = menu;
                            if (selectedSideMenu.title == "Home") {
                              index = 0;
                            } else if (selectedSideMenu.title == "My day") {
                              index = 1;
                            } else if (selectedSideMenu.title == "Search") {
                              index = 2;
                            } else if (selectedSideMenu.title == "Favorites") {
                              index = 3;
                            } else {
                              index = -1;
                            }
                            onIndexChanged(index);
                          });
                        },
                        riveOnInit: (artboard) {
                          menu.rive.status = RiveUtils.getRiveInput(artboard,
                              stateMachineName: menu.rive.stateMachineName);
                        },
                      ))
                  .toList(),
            ],
          ),
        ),
      ),
    );
  }
}
