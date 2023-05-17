import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';

class MultiSelectDropdownField extends StatefulWidget {
  const MultiSelectDropdownField({
    Key? key,
    required this.dropdownItems,
    required this.label,
    this.setValues,
    this.initialValues,
    this.validator,
  }) : super(key: key);

  final List<String> dropdownItems;
  final String label;
  final List<String>? initialValues;
  final ValueChanged<List<String>>? setValues;
  final FormFieldValidator<List<String>>? validator;

  @override
  _MultiSelectDropdownFieldState createState() =>
      _MultiSelectDropdownFieldState();
}

class _MultiSelectDropdownFieldState extends State<MultiSelectDropdownField> {
  late TextEditingController _textEditingController;
  List<String> _selectedValues = [];

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    _selectedValues = widget.initialValues ?? [];
    _updateTextFieldValue();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  void _openDropdownMenu(BuildContext context) {
    final button = context.findRenderObject() as RenderBox?;
    final buttonPosition = button!.localToGlobal(Offset.zero);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        buttonPosition.dx,
        buttonPosition.dy + button.size.height,
        buttonPosition.dx + button.size.width,
        buttonPosition.dy + button.size.height * 2,
      ),
      items: widget.dropdownItems.map((item) {
        return CheckedPopupMenuItem<String>(
          value: item,
          checked: _selectedValues.contains(item),
          child: Text(item),
        );
      }).toList(),
    ).then((value) {
      if (value != null) {
        setState(() {
          if (_selectedValues.contains(value)) {
            _selectedValues.remove(value);
          } else {
            _selectedValues.add(value);
          }
          _updateTextFieldValue();
        });

        if (widget.setValues != null) {
          widget.setValues!(_selectedValues);
        }
      }
    });
  }

  void _updateTextFieldValue() {
    _textEditingController.text = _selectedValues.join(", ");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColor.neutral400,
      alignment: Alignment.center,
      margin: const EdgeInsets.only(top: 10, bottom: 15),
      child: GestureDetector(
        onTap: () {
          _openDropdownMenu(context);
        },
        child: AbsorbPointer(
          child: TextFormField(
            controller: _textEditingController,
            decoration: InputDecoration(
              labelText: widget.label,
              border: OutlineInputBorder(),
              suffixIcon: const Icon(Icons.arrow_drop_down),
            ),
            validator: widget.validator != null
                ? (value) {
                    if (value != null) {
                      final List<String> selectedValues =
                          value.split(',').map((item) => item.trim()).toList();
                      return widget.validator!(selectedValues);
                    }
                    return null;
                  }
                : null,
          ),
        ),
      ),
    );
  }
}
