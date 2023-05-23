import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/constants/fonts.dart';
import 'package:frontend/constants/values.dart';

class CustomDropdownField extends StatefulWidget {
  final FormFieldValidator<String>? validator;
  final String label;
  final bool isFocused;
  final ValueChanged<bool> onFocusChanged;
  final FocusNode focusNode;

  const CustomDropdownField(
      {Key? key,
      this.validator,
      required this.label,
      required this.isFocused,
      required this.onFocusChanged,
      required this.focusNode})
      : super(key: key);

  @override
  State<CustomDropdownField> createState() => _CustomDropdownFieldState();
}

class _CustomDropdownFieldState extends State<CustomDropdownField> {
  //late bool _hasFocus;
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    //_hasFocus = widget.focusNode.hasFocus;
    _isExpanded = false;
    //widget.focusNode.addListener(_handleFocusChanged);
  }

  @override
  void dispose() {
    //widget.focusNode.removeListener(_handleFocusChanged);
    super.dispose();
  }

  // void _handleFocusChanged() {
  //   if (widget.focusNode.hasFocus != _hasFocus) {
  //     setState(() {
  //       _hasFocus = widget.focusNode.hasFocus;
  //     });
  //   }
  //   debugPrint("focus changed");
  // }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: widget.validator,
      builder: (FormFieldState state) {
        return Focus(
          focusNode: widget.focusNode,
          child: InkWell(
            onTap: () {
              // if (!widget.isFocused) {
              //   setState(() {
              //     _isExpanded = false;
              //   });
              // } else {
              // }
              setState(() {
                _isExpanded = !_isExpanded;
              });

              widget.onFocusChanged(!widget.isFocused);
              debugPrint("expanded: $_isExpanded");
              debugPrint("focues: ${widget.isFocused}");
              // debugPrint("focus node: ${widget.focusNode.hasFocus}");
              //widget.focusNode.requestFocus();
            },
            // onTapCancel: () {
            //   debugPrint("cancel");
            //   // widget.focusNode.unfocus();
            //   // setState(() {
            //   //   _isExpanded = false;
            //   // });
            // },
            child: Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(top: 10, bottom: 15),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Values.popupRadius),
                color: AppColor.neutral400,
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromARGB(60, 0, 0, 0),
                    blurRadius: 4,
                    offset: Offset(0, 3),
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.label,
                  ),
                  Icon(
                    widget.isFocused
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColor.neutral100,
                    size: 30,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
