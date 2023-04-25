import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/colors.dart';
import '../../constants/fonts.dart';
import '../../constants/values.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:control_style/control_style.dart';

class InputField extends StatefulWidget {
  const InputField(
      {super.key,
      required this.lblText,
      required this.formatter,
      required this.keyboardType,
      required this.controller});

  final String lblText;
  final TextInputFormatter formatter;
  final TextInputType keyboardType;
  final TextEditingController controller;

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  //late FocusNode _focusNode;

  // @override
  // void initState() {
  //   super.initState();
  //   _focusNode = FocusNode();
  //   _focusNode.addListener(_onFocusChange);
  // }

  // void _onFocusChange() {
  //   debugPrint("Focus: ${_focusNode.hasFocus.toString()}");
  // }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.only(top: 10, bottom: 15),
      color: AppColor.neutral500,
      child: TextFormField(
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Das Feld darf nicht leer sein';
          }
          return null;
        },
        //focusNode: _focusNode,
        controller: widget.controller,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        style: Fonts.text300,
        cursorColor: Colors.white,
        decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
            label: Text(widget.lblText,
                style: GoogleFonts.josefinSans(fontSize: 18)),
            labelStyle: TextStyle(color: AppColor.neutral100),
            filled: true,
            fillColor: AppColor.neutral400,
            errorStyle: Fonts.errorMessage,
            border: DecoratedInputBorder(
              child: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Values.inputRadius),
                  borderSide: BorderSide.none),
              shadow: const [
                BoxShadow(
                  color: Color.fromARGB(60, 0, 0, 0),
                  blurRadius: 4,
                  offset: Offset(0, 3),
                )
              ],
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Values.inputRadius),
              borderSide: BorderSide(
                  color: AppColor.blueActive, width: Values.inputBorder),
            ),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Values.inputRadius),
                borderSide: const BorderSide(
                    color: Colors.red, width: Values.inputBorder))),
        //inputFormatters: [widget.formatter],
        keyboardType: widget.keyboardType,
      ),
    );
  }
}
