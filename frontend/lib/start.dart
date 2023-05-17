import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:frontend/services/profile_service.dart';
import 'package:provider/provider.dart';

//import constants
import 'constants/colors.dart';
import 'constants/strings.dart';
import 'constants/values.dart';
import 'constants/fonts.dart';

//menu-pages import
import 'pages/home.dart';
import 'pages/accounts/accounts.dart';
import 'pages/budget.dart';
import 'pages/finances.dart';
import 'pages/profile.dart';
import 'pages/scanner.dart';
import 'pages/scanner/scanner_camera.dart';
import 'pages/manual_entry.dart';

import 'package:frontend/models/user.dart';

class Start extends StatefulWidget {
  const Start({this.pageId, super.key});
  final int? pageId;

  @override
  State<Start> createState() => _StartState();
}

class _StartState extends State<Start> {
  @override
  void initState() {
    super.initState();
    currentScreen = screens[widget.pageId != null ? widget.pageId! : 0];
    //Just needed for accounts
    currentTab = widget.pageId != null && widget.pageId == 1 ? 2 : 0;
  }

  User user = User(id: "", firstName: " ", lastName: " ", email: " ");

//TODO: löschen falls nicht mehr gebraucht
  void fetchDataFromDatabase() async {
    try {
      Response response = await Dio().get('${Values.serverURL}/users/1');

      setState(() {
        user = User(
          id: response.data['user_id'],
          firstName: response.data['user_name'].toString(),
          lastName: response.data['user_sirname'].toString(),
          email: response.data['email'].toString(),
        );
      });
    } catch (error, stackTrace) {
      print('Error: $error');
      print('Stacktrace: $stackTrace');
    }
  }

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
    const ManualEntry(),
  ];

  final PageStorageBucket bucket = PageStorageBucket();
  Widget currentScreen = const Home();

  @override
  Widget build(BuildContext context) {
    setState(() {
      user = context.read<ProfileService>().getUser();
    });
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
                  backgroundColor: AppColor.blueActive),
              child: Text(
                user.abreviationName,
                // "Test",
                style: Fonts.textNormalBlack18,
              ),
            ),
          ),
        ],
        backgroundColor: AppColor.backgroundFullScreen,
      ),
      body: PageStorage(
        bucket: bucket,
        child: currentScreen,
      ),
      backgroundColor: AppColor.backgroundFullScreen,
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
