import 'package:flutter/material.dart';

//import constants
import 'constants/colors.dart';
import 'constants/strings.dart';
import 'constants/values.dart';
import 'constants/fonts.dart';

//menu-pages import
import 'pages/home.dart';
import 'pages/accounts.dart';
import 'pages/budget.dart';
import 'pages/finances.dart';
import 'pages/profile.dart';
import 'pages/scanner.dart';
import 'pages/scanner/scannerCamera.dart';

import 'package:frontend/models/user.dart';

class Start extends StatefulWidget {
  const Start({super.key});

  @override
  State<Start> createState() => _StartState();
}

class _StartState extends State<Start> {
  final User user = User(
      id: 1,
      firstName: "Klaus",
      lastName: "Temper",
      email: "klaustemper@gmail.com");
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
    const ScannerCamera(),
  ];

  final PageStorageBucket bucket = PageStorageBucket();
  Widget currentScreen = const Home();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            setState(() {
              currentScreen = const Home();
              currentTab = 0;
            });
          }, // Image tapped
          child: Container(
            margin: const EdgeInsets.only(left: 10),
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
              // Fixes border issues
            ),
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
                  shape: const CircleBorder(),
                  backgroundColor: AppColor.blueLight),
              child: Text(
                user.abreviationName,
                style: Fonts.textNormalBlack18,
              ),
            ),
          ),
        ],
        backgroundColor: AppColor.background,
      ),
      body: PageStorage(
        bucket: bucket,
        child: currentScreen,
      ),
      backgroundColor: AppColor.background,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColor.neutral100,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ScannerCamera(),
            ),
          );
          // setState(() {
          //   currentScreen = const ScannerCamera();
          // });
        },
        //Icon of Scanner
        child: Icon(
          Icons.add,
          color: AppColor.neutral600,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        color: AppColor.neutral500,
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
                              ? AppColor.activeMenu
                              : AppColor.neutral100,
                        ),
                        Text(
                          Strings.menuHome,
                          style: TextStyle(
                            color: AppColor.neutral100,
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
                        currentScreen = const Finances();
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat,
                          color: currentTab == 1
                              ? AppColor.activeMenu
                              : AppColor.neutral100,
                        ),
                        Text(
                          Strings.menuFinance,
                          style: TextStyle(
                            color: AppColor.neutral100,
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
                        currentScreen = const Accounts();
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat,
                          color: currentTab == 2
                              ? AppColor.activeMenu
                              : AppColor.neutral100,
                        ),
                        Text(
                          Strings.menuAccounts,
                          style: TextStyle(
                            color: AppColor.neutral100,
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
                        currentScreen = const Budget();
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat,
                          color: currentTab == 3
                              ? AppColor.activeMenu
                              : AppColor.neutral100,
                        ),
                        Text(
                          Strings.menuBudget,
                          style: TextStyle(
                            color: AppColor.neutral100,
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
