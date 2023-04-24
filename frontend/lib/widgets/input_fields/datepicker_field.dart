import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../constants/colors.dart';
import '../../constants/fonts.dart';
import '../../constants/values.dart';
import 'package:google_fonts/google_fonts.dart';

class DatepickerField extends StatefulWidget {
  const DatepickerField({super.key});

  @override
  State<DatepickerField> createState() => _DatepickerFieldState();
}

class _DatepickerFieldState extends State<DatepickerField> {
  late TextEditingController dateController = TextEditingController();

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
            controller: dateController,
            style: Fonts.text300,
            cursorColor: Colors.white, //editing controller of this TextField
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.only(
                  top: 15, bottom: 12, left: 12, right: 12),
              label:
                  Text("Datum", style: GoogleFonts.josefinSans(fontSize: 18)),
              labelStyle: TextStyle(color: AppColor.neutral100),
              filled: true,
              fillColor: AppColor.neutral400,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Values.inputRadius),
                borderSide: BorderSide(
                    color: AppColor.blueActive, width: Values.inputBorder),
              ),
              suffixIcon: const Align(
                widthFactor: 1.0,
                heightFactor: 1.0,
                child: Icon(
                  Icons.calendar_month,
                  color: Colors.white,
                ),
              ),
            ),
            readOnly: true, // when true user cannot edit text
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(), //get today's date
                firstDate: DateTime.now(),
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
                    DateFormat('dd / MM / yyyy').format(pickedDate);

                setState(() {
                  dateController.text = formattedDate;
                });
              }
            },
          ),
        ),
      ),
    );
  }
}
