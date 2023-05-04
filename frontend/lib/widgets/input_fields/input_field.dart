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
      required this.reqFormatter,
      required this.keyboardType,
      required this.controller,
      required this.maxLength,
      required this.onFocusChanged,
      required this.focusNode,
      this.maxLines,
      this.alignLabelLeftCorner,
      this.validator});

  final String lblText;
  final TextInputFormatter reqFormatter;
  final TextInputType keyboardType;
  final TextEditingController controller;
  final int? maxLines;
  final bool? alignLabelLeftCorner;
  final FormFieldValidator<String>? validator;
  final int maxLength;
  final ValueChanged<bool> onFocusChanged;
  final FocusNode focusNode;

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
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
        validator: widget.validator,
        focusNode: widget.focusNode,
        controller: widget.controller,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        style: Fonts.text300,
        cursorColor: Colors.white,
        maxLines: widget.maxLines,
        maxLength: widget.maxLength,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(top: 30, left: 10),
          label: Text(
            widget.lblText,
            style: GoogleFonts.josefinSans(fontSize: 18),
          ),
          labelStyle: TextStyle(color: AppColor.neutral100),
          alignLabelWithHint: widget.alignLabelLeftCorner,
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
            borderSide:
                const BorderSide(color: Colors.red, width: Values.inputBorder),
          ),
          counterText: "",
        ),
        inputFormatters: [widget.reqFormatter],
        keyboardType: widget.keyboardType,
        onTap: () => widget.onFocusChanged(true),
        onEditingComplete: () => widget.onFocusChanged(false),
      ),
    );
  }
}
