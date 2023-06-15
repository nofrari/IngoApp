import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:frontend/constants/fonts.dart';
import 'package:frontend/constants/values.dart';
import 'package:frontend/customIcons/dropdown_arrows_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/colors.dart';
import 'package:control_style/control_style.dart';

class DropdownMultiselect extends StatefulWidget {
  DropdownMultiselect({
    super.key,
    required this.dropdownItems,
    //this.label,
    required this.hintText,
    this.width,
    this.setValues,
    this.selectedTags = const [],
    this.onTagsChanged,
  });

  final List<String> dropdownItems;
  //final String? label;
  final String hintText;
  double? width;
  final ValueChanged<List<String>>? setValues;
  final List<String> selectedTags;
  final void Function(List<String> selectedTags)? onTagsChanged;

  @override
  State<DropdownMultiselect> createState() => _DropdownMultiselectState();
}

class _DropdownMultiselectState extends State<DropdownMultiselect> {
  List<String> _selectedValues = [];
  List<String> _selectedTags = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _selectedValues = []);
    setState(() {
      _selectedValues = [];
    });
    _selectedTags = List.from(widget.selectedTags);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.only(top: 10, bottom: 15),
      child: Column(
        children: [
          Form(
            key: _formKey,
            child: DropdownButtonFormField2(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              value: null,
              decoration: InputDecoration(
                label: Text(widget.hintText, style: Fonts.text300),
                labelStyle: TextStyle(color: AppColor.neutral100),
                border: DecoratedInputBorder(
                    child: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Values.inputRadius),
                      borderSide: BorderSide.none,
                    ),
                    shadow: const [
                      BoxShadow(
                        color: Color.fromARGB(60, 0, 0, 0),
                        blurRadius: 4,
                        offset: Offset(0, 3),
                      )
                    ]),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Values.inputRadius),
                  borderSide: BorderSide(
                    color: AppColor.blueActive,
                    width: Values.inputBorder,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Values.inputRadius),
                  borderSide: const BorderSide(
                      color: Colors.red, width: Values.inputBorder),
                ),
                filled: true,
                fillColor: AppColor.backgroundInputField,
                errorStyle: Fonts.errorMessage,
                isDense: true,
                isCollapsed: true,
                // floatingLabelBehavior: FloatingLabelBehavior.never,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 10.0,
                ),
              ),
              isExpanded: true,
              items: List.generate(
                widget.dropdownItems.length,
                (index) => DropdownMenuItem(
                  value: widget.dropdownItems[index].toString(),
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.dropdownItems[index].toString(),
                      style: GoogleFonts.josefinSans(
                        fontSize: 18,
                        color:
                            // color: selectedValue == widget.dropdownItems[index]
                            //     ? AppColor.blueActive
                            AppColor.textColor,
                      ),
                    ),
                  ),
                ),
              ),
              // validator: widget.validator,
              onChanged: (value) {
                setState(() {
                  if (_selectedValues.contains(value)) {
                    _selectedValues.remove(value);
                  } else {
                    _selectedValues.add(value!);
                  }
                });

                if (widget.setValues != null) {
                  widget.setValues!(_selectedValues);
                }
                if (widget.onTagsChanged != null) {
                  widget.onTagsChanged!(
                    _selectedValues,
                  ); // Call the callback function
                }
              },
              onSaved: (value) {},
              selectedItemBuilder: _selectedValues.isNotEmpty
                  ? (BuildContext context) {
                      return [];
                    }
                  : (BuildContext context) {
                      return [];
                    },

              iconStyleData: IconStyleData(
                openMenuIcon: Icon(
                  DropdownArrows.up_open_mini,
                  color: AppColor.textColor,
                ),
                icon: Icon(
                  DropdownArrows.down_open_mini,
                  color: AppColor.textColor,
                ),
                iconSize: 30,
              ),
              dropdownStyleData: DropdownStyleData(
                width: widget.width,
                offset: const Offset(-10, -6),
                maxHeight: 200,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 2,
                    color: AppColor.activeMenu,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(Values.inputRadius),
                    bottomLeft: Radius.circular(Values.inputRadius),
                  ),
                  color: AppColor.backgroundGray,
                ),
              ),
            ),
          ),
          // Visibility(
          //   visible: _selectedValues.isNotEmpty,
          //   child: Container(
          //     margin: const EdgeInsets.only(top: 5),
          //     child: Align(
          //       alignment: Alignment.topLeft,
          //       child: Wrap(
          //         alignment: WrapAlignment.start,
          //         spacing: 8, // Adjust the spacing between tags as needed
          //         children: _selectedValues.map((String item) {
          //           return Tag(
          //             btnText: item,
          //             onTap: () {
          //               setState(() {
          //                 _selectedValues.remove(item);
          //               });
          //               if (widget.setValues != null) {
          //                 widget.setValues!(_selectedValues);
          //               }
          //               if (_selectedValues.isEmpty) {
          //                 setState(() {
          //                   _selectedValues.clear();
          //                 });
          //                 if (widget.setValues != null) {
          //                   widget.setValues!(_selectedValues);
          //                 }
          //                 _formKey.currentState
          //                     ?.reset(); // Reset the form to hide the floating label
          //               }
          //             },
          //           );
          //         }).toList(),
          //       ),
          //     ),
          //   ),
          // )
        ],
      ),
    );
  }
}
