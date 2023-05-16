import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../constants/fonts.dart';
import '../pages/data_protection.dart';
import '../start.dart';

class CheckboxDataProtection extends StatefulWidget {
  const CheckboxDataProtection(
      {super.key,
      required this.onCheckboxTapped,
      required this.validator,
      required this.value,
      this.linkTo,
      this.linkText,
      this.text});

  final ValueChanged<bool?>? onCheckboxTapped;
  final String? Function(bool?)? validator;
  final bool value;
  final String? text;
  final Function()? linkTo;
  final String? linkText;

  @override
  State<CheckboxDataProtection> createState() => _CheckboxDataProtectionState();
}

class _CheckboxDataProtectionState extends State<CheckboxDataProtection> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
      };
      return AppColor.activeMenu;
    }

    return FormField<bool>(
      validator: widget.validator,
      builder: (state) {
        return Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: Checkbox(
                          fillColor:
                              MaterialStateProperty.resolveWith(getColor),
                          focusColor: AppColor.activeMenu,
                          value: widget.value,
                          onChanged: widget.onCheckboxTapped),
                    ),
                  ),
                  Text(
                    widget.text != null ? widget.text! : "",
                    style: Fonts.text100,
                  ),
                  GestureDetector(
                    onTap: widget.linkTo,
                    child: Text(
                      widget.linkText != null ? widget.linkText! : "",
                      style: Fonts.textLink,
                    ),
                  ),
                ],
              ),
            ),
            Align(
                alignment: Alignment.topLeft,
                child: Text(
                  state.errorText ?? '',
                  style: Fonts.errorMessage,
                )),
          ],
        );
      },
    );
  }
}
