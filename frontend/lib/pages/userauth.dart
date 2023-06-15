import 'package:flutter/material.dart';

import 'register.dart';
import 'login.dart';

import '../constants/colors.dart';
import '../constants/values.dart';

import '../widgets/toggle_button_selina.dart';

class Auth extends StatefulWidget {
  Auth({this.showLogin, super.key});

  bool? showLogin;

  @override
  _AuthState createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  bool showSignIn = true;

  void toggleView() {
    setState(() => showSignIn = !showSignIn);
  }

  bool _isFocused = false;
  void changeVisibility(bool isFocused) {
    setState(() {
      _isFocused = isFocused;
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.showLogin != null) {
      showSignIn = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();

        setState(() {
          _isFocused = false;
        });
      },
      child: Scaffold(
        backgroundColor: AppColor.backgroundFullScreen,
        body: Container(
          padding: Values.bigCardPadding,
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
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(bottom: 20),
                  // height: MediaQuery.of(context).size.height * 0.7,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: AppColor.neutral500, style: BorderStyle.solid),
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    color: AppColor.backgroundGray,
                  ),
                  child: Container(
                    // color: AppColor.blueActive,
                    child: Column(
                      children: [
                        Toggle(
                          toggleView: toggleView,
                          forceLogin: !showSignIn,
                        ),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.all(20),
                            child: showSignIn
                                ? Register(focus: _isFocused)
                                : Login(focus: _isFocused),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
