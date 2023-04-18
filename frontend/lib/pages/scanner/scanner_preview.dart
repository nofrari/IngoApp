import 'package:flutter/material.dart';

//import constants
import '../../constants/colors.dart';
import '../../constants/strings.dart';
import '../../constants/values.dart';
import './scannerCamera.dart';

class Start extends StatefulWidget {
  const Start({super.key});

  @override
  State<Start> createState() => _StartState();
}

class _StartState extends State<Start> {
  //variable for current Tab
  int currentTab = 0;

  final PageStorageBucket bucket = PageStorageBucket();
  // Widget currentScreen = const Home();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            setState(() {
              //           currentScreen = const Home();
              currentTab = 0;
            });
          }, // Image tapped
          child: BackButton(
            color: AppColor.neutral100,
          ),
          // Image.asset(
          //   'assets/images/logo.png',
          //   fit: BoxFit.cover, // Fixes border issues
        ),
        leadingWidth: Values.leadingWidth,
        actions: [
          SizedBox(
            width: Values.actionsWidth,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  //              currentScreen = const Profile();
                  currentTab = 4;
                });
              },
              style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  backgroundColor: AppColor.blueLight),
              child: const Text("AH"),
            ),
          ),
        ],
        backgroundColor: AppColor.background,
      ),
      //   body: PageStorage(
      //    bucket: bucket,
      //      child: currentScreen,
      //   ),
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
    );
  }
}
