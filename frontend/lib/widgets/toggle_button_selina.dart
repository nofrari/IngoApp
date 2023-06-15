import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frontend/pages/register.dart';

import '../constants/colors.dart';
import '../constants/fonts.dart';
import '../pages/userauth.dart';

class Toggle extends StatefulWidget {
  Toggle({super.key, required this.toggleView, this.forceLogin = false});
  final Function toggleView;

  //final List<Widget> selectedScreen;
  final Register register = Register();

  bool forceLogin;

  @override
  State<Toggle> createState() => _ToggleState();
}

const double height = 40.0;
// const double loginAlign = -1;
// const double signInAlign = 1;
//Color selectedColor = AppColor.backgroundFullScreen;
//Color normalColor = AppColor.backgroundFullScreen;

class _ToggleState extends State<Toggle> {
  bool showLogIn = false;
  //double xAlign = loginAlign;
  //Color loginColor = selectedColor;
  //Color signInColor = normalColor;

  @override
  void initState() {
    super.initState();
    showLogIn = widget.forceLogin;
    // if (widget.register.firstRegister) {
    //   xAlign = signInAlign;
    //   widget.register.firstRegister = false;
    // } else {
    //   xAlign = loginAlign;
    // }

    //xAlign = loginAlign;

    //loginColor = selectedColor;
    //signInColor = normalColor;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Container(
      alignment: Alignment.center,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColor.blueInactive,
          borderRadius: const BorderRadius.all(
            Radius.circular(50.0),
          ),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              alignment: Alignment(showLogIn ? 1 : -1, 0),
              duration: const Duration(milliseconds: 300),
              child: Container(
                width: width * 0.5,
                height: height,
                decoration: BoxDecoration(
                  color: AppColor.activeMenu,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(50.0),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                if (showLogIn) {
                  widget.toggleView();
                  setState(() {
                    showLogIn = false;
                  });
                }
              },
              child: Align(
                alignment: Alignment(-1, 0),
                child: Container(
                  width: width * 0.5,
                  color: Colors.transparent,
                  alignment: Alignment.center,
                  child: Text(
                    'REGISTRIEREN',
                    style: Fonts.toggleButton,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                if (!showLogIn) {
                  widget.toggleView();
                  setState(() {
                    showLogIn = true;
                  });
                }
              },
              child: Align(
                alignment: Alignment(1, 0),
                child: Container(
                  width: width * 0.5,
                  color: Colors.transparent,
                  alignment: Alignment.center,
                  child: Text(
                    'ANMELDEN',
                    style: Fonts.toggleButton,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
