import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/fonts.dart';

class CheckboxField extends FormField<bool> {
  CheckboxField(
      {Widget? title,
      FormFieldSetter<bool>? onSaved,
      FormFieldValidator<bool>? validator,
      bool initialValue = false,
      bool autovalidate = false,
      bool checkbox = false})
      : super(
            onSaved: onSaved,
            validator: validator,
            initialValue: initialValue,
            builder: (FormFieldState<bool> state) {
              return CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: state.value,
                title: Text(
                  'Ich stimme der Datenschutzerklärung zu',
                  style: Fonts.text150,
                ),
                activeColor: AppColor.activeMenu,
                visualDensity: const VisualDensity(horizontal: -4),
                side: MaterialStateBorderSide.resolveWith((states) =>
                    BorderSide(width: 1.0, color: AppColor.activeMenu)),
                onChanged: state.didChange,
                subtitle: state.hasError
                    ? Builder(
                        builder: (BuildContext context) => Text(
                          state.errorText ?? "",
                          style: Fonts.errorMessage,
                        ),
                      )
                    : null,
                controlAffinity: ListTileControlAffinity.leading,
              );
            });
}
