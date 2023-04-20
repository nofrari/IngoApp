import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/colors.dart';
import '../../constants/fonts.dart';
import '../../constants/values.dart';
import 'package:google_fonts/google_fonts.dart';

class InputField extends StatefulWidget {
  const InputField(
      {super.key,
      required this.lblText,
      required this.formatter,
      required this.keyboardType});

  final String lblText;
  final TextInputFormatter formatter;
  final TextInputType keyboardType;

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  //late FocusNode _focusNode;
  late TextEditingController controller = TextEditingController();

  // @override
  // void initState() {
  //   super.initState();
  //   _focusNode = FocusNode();
  //   _focusNode.addListener(_onFocusChange);
  // }

  // @override
  // void dispose() {
  //   _focusNode.dispose();
  //   _focusNode.removeListener(_onFocusChange);
  //   super.dispose();
  // }

  // void _onFocusChange() {
  //   debugPrint("Focus: ${_focusNode.hasFocus.toString()}");
  // }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.only(top: 10, bottom: 15),
      child: SizedBox(
        width: 350,
        height: 40,
        child: Material(
          elevation: 5,
          borderRadius: BorderRadius.circular(5),
          child: TextFormField(
            //focusNode: _focusNode,
            controller: controller,
            style: Fonts.text300,
            cursorColor: Colors.white,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(12),
              label: Text(widget.lblText,
                  style: GoogleFonts.josefinSans(fontSize: 18)),
              labelStyle: TextStyle(color: AppColor.neutral100),
              filled: true,
              fillColor: AppColor.neutral400,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Values.inputRadius),
                  borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Values.inputRadius),
                  borderSide: BorderSide(
                      color: AppColor.blueLight, width: Values.inputBorder)),
            ),
            inputFormatters: [widget.formatter],
            keyboardType: widget.keyboardType,
          ),
        ),
      ),
    );
  }
}
