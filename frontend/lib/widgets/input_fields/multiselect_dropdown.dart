import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/constants/fonts.dart';
import 'package:frontend/constants/values.dart';
import 'package:frontend/customIcons/dropdown_arrows_icons.dart';
import 'package:frontend/widgets/button.dart';

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
    final button = context.findRenderObject() as RenderBox;
    final buttonPosition = button.localToGlobal(Offset.zero);

    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final RenderBox dropdownButton = context.findRenderObject() as RenderBox;
    final buttonWidth = dropdownButton.size.width;

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        buttonPosition.dx,
        buttonPosition.dy + button.size.height,
        buttonPosition.dx + buttonWidth,
        overlay.size.height,
      ),
      items: widget.dropdownItems.map((item) {
        return PopupMenuItem<String>(
          value: item,
          child: ListTile(
            title: Text(
              item,
              style: Fonts.text300,
            ),
            onTap: () {
              setState(() {
                if (_selectedValues.contains(item)) {
                  _selectedValues.remove(item);
                } else {
                  _selectedValues.add(item);
                }
                _updateTextFieldValue();
              });

              if (widget.setValues != null) {
                widget.setValues!(_selectedValues);
              }
            },
          ),
        );
      }).toList(),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      color: AppColor.neutral500,
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
  // void _openDropdownMenu(BuildContext context) async {
  //   final selectedValues = await showDialog<List<String>>(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return Dialog(
  //         child: Builder(
  //           builder: (BuildContext context) {
  //             return AlertDialog(
  //               contentPadding: EdgeInsets.zero,
  //               content: Container(
  //                 height: MediaQuery.of(context).size.height *
  //                     0.5, // Set a fixed height
  //                 child: SingleChildScrollView(
  //                   child: Column(
  //                     children: [
  //                       ListView.builder(
  //                         shrinkWrap: true,
  //                         itemCount: widget.dropdownItems.length,
  //                         itemBuilder: (BuildContext context, int index) {
  //                           final item = widget.dropdownItems[index];
  //                           final isSelected = _selectedValues.contains(item);

  //                           return CheckboxListTile(
  //                             value: isSelected,
  //                             onChanged: (bool? value) {
  //                               setState(() {
  //                                 if (value != null) {
  //                                   if (value) {
  //                                     _selectedValues.add(item);
  //                                   } else {
  //                                     _selectedValues.remove(item);
  //                                   }
  //                                 }
  //                               });
  //                             },
  //                             title: Text(item),
  //                           );
  //                         },
  //                       ),
  //                       SizedBox(height: 16),
  //                       Button(
  //                         btnText: "DONE",
  //                         theme: ButtonColorTheme.primary,
  //                         onTap: () {
  //                           Navigator.of(context).pop(_selectedValues);
  //                         },
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             );
  //           },
  //         ),
  //       );
  //     },
  //   );

  //   if (selectedValues != null) {
  //     setState(() {
  //       _selectedValues = selectedValues;
  //       _updateTextFieldValue();
  //     });

  //     if (widget.setValues != null) {
  //       widget.setValues!(_selectedValues);
  //     }
  //   }
  // }

  void _updateTextFieldValue() {
    _textEditingController.text = _selectedValues.join(", ");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: 2,
          color: AppColor.activeMenu,
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(Values.inputRadius),
        ),
        color: AppColor.neutral400,
      ),
      alignment: Alignment.center,
      margin: const EdgeInsets.only(top: 10, bottom: 15),
      child: GestureDetector(
        onTap: () {
          _openDropdownMenu(context);
        },
        child: AbsorbPointer(
          child: Container(
            width: double.infinity,
            child: TextFormField(
              style: Fonts.text300,
              controller: _textEditingController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(12, 20, 12, 12),
                labelText: widget.label,
                border: OutlineInputBorder(gapPadding: 0),
                suffixIcon: Icon(
                  DropdownArrows.down_open_mini,
                  color: AppColor.neutral100,
                  size: 30,
                ),
              ),
              validator: widget.validator != null
                  ? (value) {
                      if (value != null) {
                        final List<String> selectedValues = value
                            .split(',')
                            .map((item) => item.trim())
                            .toList();
                        return widget.validator!(selectedValues);
                      }
                      return null;
                    }
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
