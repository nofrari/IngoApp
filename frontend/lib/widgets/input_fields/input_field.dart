import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../constants/colors.dart';
import '../../constants/fonts.dart';
import '../../constants/values.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:control_style/control_style.dart';

TextInputFormatter currencyFormatter =
    TextInputFormatter.withFunction((oldValue, newValue) {
  String cleanText = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
  int value = int.tryParse(cleanText) ?? 0;
  final formatter =
      NumberFormat.currency(locale: 'de', name: "EUR", symbol: '€');
  String newText = formatter.format(value / 100);
  int cursorPos = newText.length;
  if (newValue.selection.baseOffset == newValue.selection.extentOffset) {
    cursorPos = formatter.format(value / 100).length - 2;
  }
  return TextEditingValue(
    text: newText,
    selection: TextSelection.collapsed(offset: cursorPos),
  );
});

double currencyToDouble(String currency) {
  final refactoredAmount =
      currency.replaceAll("€", "").replaceAll(" ", "").replaceAll(",", ".");

  final amount = double.tryParse(refactoredAmount);
  return amount ?? 0;
}

class InputField extends StatefulWidget {
  const InputField(
      {super.key,
      required this.lblText,
      required this.reqFormatter,
      required this.keyboardType,
      required this.controller,
      required this.maxLength,
      required this.onFocusChanged,
      this.maxLines,
      this.alignLabelLeftCorner,
      this.validator,
      this.autovalidateMode});

  final String lblText;
  final TextInputFormatter reqFormatter;
  final TextInputType keyboardType;
  final TextEditingController controller;
  final int? maxLines;
  final bool? alignLabelLeftCorner;
  final FormFieldValidator<String>? validator;
  final int maxLength;
  final AutovalidateMode? autovalidateMode;
  final ValueChanged<bool> onFocusChanged;

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
          controller: widget.controller,
          onEditingComplete: () {
            FocusScope.of(context).unfocus();
            widget.onFocusChanged(false); // Tastatur schließen
          },
          style: Fonts.text300,
          cursorColor: Colors.white,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          autovalidateMode: widget.autovalidateMode,
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
              borderSide: const BorderSide(
                  color: Colors.red, width: Values.inputBorder),
            ),
            counterText: "",
          ),
          inputFormatters: [widget.reqFormatter],
          keyboardType: widget.keyboardType,
          onTap: () => widget.onFocusChanged(true)),
    );
  }
}
