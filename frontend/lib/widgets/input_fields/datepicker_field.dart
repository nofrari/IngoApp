import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/colors.dart';
import '../../constants/fonts.dart';
import '../../constants/values.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:control_style/control_style.dart';

class DatepickerField extends StatefulWidget {
  DatepickerField(
      {super.key,
      this.label,
      required this.controller,
      this.serverDate,
      this.onChanged,
      this.validator,
      this.autovalidateMode,
      required this.errorMsgBgColor});

  final TextEditingController controller;
  String? serverDate;
  DateTime _selectedDate = DateTime.now();
  String? label;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final Color errorMsgBgColor;

  final AutovalidateMode? autovalidateMode;

  DateTime get selectedDate => _selectedDate;
  set selectedDate(DateTime value) {
    _selectedDate = value;
  }

  @override
  State<DatepickerField> createState() => _DatepickerFieldState();
}

class _DatepickerFieldState extends State<DatepickerField> {
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
      color: widget.errorMsgBgColor,
      child: TextFormField(
        controller: widget.controller,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: widget.validator,
        style: Fonts.text300,
        cursorColor: Colors.white, //editing controller of this TextField
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.only(top: 15, bottom: 12, left: 12, right: 12),
          label: Text(widget.label ?? "Datum",
              style: GoogleFonts.josefinSans(fontSize: 18)),
          labelStyle: TextStyle(color: AppColor.neutral100),
          filled: true,
          fillColor: AppColor.neutral400,
          errorStyle: Fonts.errorMessage,
          suffixIcon: const Align(
            widthFactor: 1.0,
            heightFactor: 1.0,
            child: Icon(
              Icons.calendar_month,
              color: Colors.white,
            ),
          ),
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
        ),
        readOnly: true,
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: (widget.serverDate != null)
                ? DateFormat("yyyy-MM-dd").parse(widget.serverDate!)
                : widget.selectedDate,
            firstDate: DateTime(2000),
            lastDate: DateTime(2101),
            cancelText: "Schließen",
            confirmText: "Auswählen",
            locale: const Locale('de'),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  dialogBackgroundColor: AppColor.neutral500,
                  colorScheme: ColorScheme.light(
                    primary: AppColor.blueActive,
                    onPrimary: AppColor.neutral600,
                    onSurface: Colors.white,
                  ),
                  textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(
                        foregroundColor: AppColor.blueActive,
                        textStyle: Fonts.text300),
                  ),
                  textTheme: TextTheme(
                    labelSmall: Fonts.text100,
                    headlineMedium: Fonts.text400,
                    titleSmall: Fonts.text300,
                    titleMedium: GoogleFonts.josefinSans(
                        color: Colors.white, fontSize: 18),
                    bodySmall: Fonts.text200,
                    bodyLarge: Fonts.text200,
                  ),
                  dialogTheme: DialogTheme(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11)),
                  ),
                ),
                child: child!,
              );
            },
          );
          if (pickedDate != null) {
            String formattedDate =
                DateFormat("dd / MM / yyyy").format(pickedDate);

            setState(() {
              widget.controller.text = formattedDate;
              widget.selectedDate = pickedDate;
            });
            if (widget.onChanged != null) {
              widget.onChanged!(formattedDate);
            }
          }
        },
      ),
    );
  }
}
