// import 'package:flutter/material.dart';
// import '../../constants/colors.dart';
// import '../../constants/fonts.dart';

// class CheckboxField extends StatefulWidget {
//   const CheckboxField(
//       {super.key, required this.validator, required this.value});

//   final FormFieldValidator<String> validator;
//   final bool value;

//   @override
//   State<CheckboxField> createState() => _CheckboxFieldState();
// }

// class _CheckboxFieldState extends State<CheckboxField> {
//   @override
//   void dispose() {
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         FormField(builder: _CheckboxFieldState state)
//         CheckboxListTile(
//           contentPadding: EdgeInsets.zero,
//           value: widget.value,
//           activeColor: AppColor.activeMenu,
//           visualDensity: const VisualDensity(horizontal: -4),
//           side: MaterialStateBorderSide.resolveWith(
//               (states) => BorderSide(width: 1.0, color: AppColor.activeMenu)),
//           onChanged: widget.didChange,
//           controlAffinity: ListTileControlAffinity.leading,
//         ),
//       ],
//     );
//   }
// }
