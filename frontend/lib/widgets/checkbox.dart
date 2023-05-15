import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../constants/fonts.dart';
import '../start.dart';

class CheckboxDataProtection extends StatefulWidget {
  const CheckboxDataProtection(
      {super.key,
      required this.onCheckboxTapped,
      required this.value,
      required this.validator});

  final ValueChanged<bool?>? onCheckboxTapped;
  final String? Function(bool?)? validator;
  final bool value;

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

    return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      FormField<bool>(
        validator: widget.validator,
        builder: (state) {
          return Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Checkbox(
                      fillColor: MaterialStateProperty.resolveWith(getColor),
                      focusColor: AppColor.activeMenu,
                      checkColor: AppColor.activeMenu,
                      value: widget.value,
                      onChanged: widget.onCheckboxTapped),
                  Text(
                    'Ich stimme der ',
                    style: Fonts.text200,
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Start(),
                      ),
                    ),
                    child: Text(
                      'Datenschutzerklärung ',
                      style: Fonts.textLink,
                    ),
                  ),
                  Text(
                    'zu',
                    style: Fonts.text200,
                  ),
                ],
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
      )
    ]);
  }
}
