import 'package:flutter/material.dart';

//import constants
import 'constants/colors.dart';
import 'constants/strings.dart';
import 'constants/values.dart';

//menu-pages import
import 'pages/home.dart';
import 'pages/accounts.dart';
import 'pages/budget.dart';
import 'pages/finances.dart';
import 'pages/profile.dart';
import 'pages/scanner.dart';

class Start extends StatefulWidget {
  const Start({super.key});

  @override
  State<Start> createState() => _StartState();
}

class _StartState extends State<Start> {
  //variable for current Tab
  int currentTab = 0;

  //list of all screens
  final List<Widget> screens = [
    const Home(),
    const Accounts(),
    const Budget(),
    const Finances(),
    const Profile(),
    const Scanner(),
  ];

  final PageStorageBucket bucket = PageStorageBucket();
  Widget currentScreen = const Home();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            setState(() {
              currentScreen = const Home();
              currentTab = 0;
            });
          }, // Image tapped
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.cover, // Fixes border issues
          ),
        ),
        leadingWidth: Values.leadingWidth,
        actions: [
          SizedBox(
            width: Values.actionsWidth,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  currentScreen = const Profile();
                  currentTab = 4;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.transparant,
                foregroundColor: AppColor.white,
                elevation: 0,
              ),
              child: const Icon(
                Icons.account_box_rounded,
                size: Values.iconSize,
              ),
            ),
          ),
        ],
        backgroundColor: AppColor.appBarBackgroundColor,
      ),
      body: PageStorage(
        bucket: bucket,
        child: currentScreen,
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          setState(() {
            currentScreen = const Scanner();
          });
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: Values.notchMargin,
        child: SizedBox(
          height: Values.menuBarHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MaterialButton(
                    minWidth: Values.menuBarItemMinWidth,
                    onPressed: () {
                      setState(() {
                        currentTab = 0;
                        currentScreen = const Home();
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat,
                          color: currentTab == 0
                              ? AppColor.currentTab
                              : AppColor.defaultTab,
                        ),
                        const Text(
                          Strings.menuHome,
                          style: TextStyle(
                            color: AppColor.defaultTab,
                          ),
                        )
                      ],
                    ),
                  ),
                  MaterialButton(
                    minWidth: Values.menuBarItemMinWidth,
                    onPressed: () {
                      setState(() {
                        currentTab = 1;
                        currentScreen = const Accounts();
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat,
                          color: currentTab == 1
                              ? AppColor.currentTab
                              : AppColor.defaultTab,
                        ),
                        const Text(
                          Strings.menuAccounts,
                          style: TextStyle(
                            color: AppColor.defaultTab,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MaterialButton(
                    minWidth: Values.menuBarItemMinWidth,
                    onPressed: () {
                      setState(() {
                        currentTab = 2;
                        currentScreen = const Budget();
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat,
                          color: currentTab == 2
                              ? AppColor.currentTab
                              : AppColor.defaultTab,
                        ),
                        const Text(
                          Strings.menuBudget,
                          style: TextStyle(
                            color: AppColor.defaultTab,
                          ),
                        )
                      ],
                    ),
                  ),
                  MaterialButton(
                    minWidth: Values.menuBarItemMinWidth,
                    onPressed: () {
                      setState(() {
                        currentTab = 3;
                        currentScreen = const Finances();
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat,
                          color: currentTab == 3
                              ? AppColor.currentTab
                              : AppColor.defaultTab,
                        ),
                        const Text(
                          Strings.menuFinance,
                          style: TextStyle(
                            color: AppColor.defaultTab,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
