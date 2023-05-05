import 'package:flutter/material.dart';

import 'register.dart';
import 'login.dart';

import '../constants/colors.dart';
import '../constants/values.dart';

import '../widgets/toggle_button_selina.dart';

class Auth extends StatefulWidget {
  @override
  _AuthState createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  bool showSignIn = true;
  void toggleView() {
    setState(() => showSignIn = !showSignIn);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: AppColor.backgroundFullScreen,
        body: Container(
          padding: Values.bigCardPadding,
          child: SingleChildScrollView(
            child: Column(
              children: [
                //Logo
                Container(
                  padding: const EdgeInsets.only(top: 60, bottom: 20),
                  child: Image.asset(
                    'assets/images/logo_slogan.png',
                    alignment: Alignment.topCenter,
                    height: 150,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: AppColor.neutral500, style: BorderStyle.solid),
                    borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(20),
                        bottomRight: Radius.circular(11),
                        bottomLeft: Radius.circular(11)),
                    color: AppColor.backgroundGray,
                  ),
                  child: Column(children: [
                    Toggle(toggleView: toggleView),
                    Container(
                        margin: EdgeInsets.all(20),
                        child: showSignIn ? Register() : Login())
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
