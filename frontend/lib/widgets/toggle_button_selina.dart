import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/fonts.dart';

class Toggle extends StatefulWidget {
  const Toggle({super.key});

  //final List<Widget> selectedScreen;

  @override
  State<Toggle> createState() => _ToggleState();
}

const double height = 40.0;
const double loginAlign = -1;
const double signInAlign = 1;
//Color selectedColor = AppColor.backgroundFullScreen;
//Color normalColor = AppColor.backgroundFullScreen;

class _ToggleState extends State<Toggle> {
  double xAlign = loginAlign;
  //Color loginColor = selectedColor;
  //Color signInColor = normalColor;

  @override
  void initState() {
    super.initState();
    xAlign = loginAlign;
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
              alignment: Alignment(xAlign, 0),
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
                setState(() {
                  xAlign = loginAlign;
                  //selectedScreen[index] = !selectedScreen[index];
                  //loginColor = selectedColor;
                  //signInColor = normalColor;
                });
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
                setState(() {
                  xAlign = signInAlign;
                  //signInColor = selectedColor;
                  //loginColor = normalColor;
                });
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
