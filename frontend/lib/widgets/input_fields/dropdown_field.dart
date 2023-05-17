import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:frontend/constants/fonts.dart';
import 'package:frontend/constants/values.dart';
import 'package:frontend/customIcons/dropdown_arrows_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/colors.dart';
import '../../constants/strings.dart';
import '../../pages/home.dart';
import 'package:control_style/control_style.dart';

class Dropdown extends StatefulWidget {
  const Dropdown(
      {super.key,
      required this.dropdownItems,
      required this.label,
      required this.needsNewCategoryButton,
      this.setValue,
      this.initialValue,
      required this.validator});

  final List<String> dropdownItems;
  final String label;
  final bool needsNewCategoryButton;
  final String? initialValue;
  final ValueChanged<String>? setValue;
  final FormFieldValidator<String>? validator;

  @override
  State<Dropdown> createState() => _DropdownState();
}

class _DropdownState extends State<Dropdown> {
  String? selectedValue;

  @override
  void initState() {
    super.initState();
    setState(() {
      (widget.initialValue != null)
          ? selectedValue = widget.initialValue
          : WidgetsBinding.instance
              .addPostFrameCallback((_) => selectedValue = null);
    });
  }

  late TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.only(top: 10, bottom: 15),
      child: DropdownButtonFormField2(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        value: selectedValue,
        decoration: InputDecoration(
          label: Text(widget.label, style: Fonts.text300),
          labelStyle: TextStyle(color: AppColor.neutral100),
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
              ]),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Values.inputRadius),
              borderSide: BorderSide(
                  color: AppColor.blueActive, width: Values.inputBorder)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Values.inputRadius),
              borderSide: const BorderSide(
                  color: Colors.red, width: Values.inputBorder)),
          filled: true,
          fillColor: AppColor.backgroundInputField,
          errorStyle: Fonts.errorMessage,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        ),
        isExpanded: true,
        items: (widget.needsNewCategoryButton == true)
            ? List.generate(
                widget.dropdownItems.length + 1,
                (index) => index < widget.dropdownItems.length
                    ? DropdownMenuItem(
                        value: widget.dropdownItems[index],
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            widget.dropdownItems[index],
                            style: GoogleFonts.josefinSans(
                              fontSize: 18,
                              color:
                                  selectedValue == widget.dropdownItems[index]
                                      ? AppColor.blueActive
                                      : AppColor.textColor,
                            ),
                          ),
                        ),
                      )
                    : DropdownMenuItem(
                        value: '',
                        child: TextButton(
                            style: TextButton.styleFrom(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(0),
                            ),
                            child: Text(
                              '+ neue Kategorie hinzufügen',
                              style: GoogleFonts.josefinSans(
                                fontSize: 18,
                                color: AppColor.blueActive,
                              ),
                            ),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Home(),
                                ),
                              );
                            }),
                      ),
              )
            : List.generate(
                widget.dropdownItems.length,
                (index) => DropdownMenuItem(
                  value: widget.dropdownItems[index],
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.dropdownItems[index],
                      style: GoogleFonts.josefinSans(
                        fontSize: 18,
                        color: selectedValue == widget.dropdownItems[index]
                            ? AppColor.blueActive
                            : AppColor.textColor,
                      ),
                    ),
                  ),
                ),
              ),
        // validator: (value) {
        //   if (value == null || value.isEmpty) {
        //     return 'Das Feld darf nicht leer sein';
        //   }
        //   return null;
        // },
        validator: widget.validator,
        onChanged: (value) {
          debugPrint('changed');
          setState(() => selectedValue = value!);
          if (widget.setValue != null && value != null) {
            widget.setValue!(value);
          }
        },
        onSaved: (value) {
          debugPrint('saved');
          selectedValue = value.toString();
        },
        selectedItemBuilder: (BuildContext context) {
          return widget.dropdownItems.map<Widget>((String item) {
            return Container(
              alignment: Alignment.centerLeft,
              constraints: const BoxConstraints(minWidth: 100),
              child: Text(
                item,
                textAlign: TextAlign.left,
                style: GoogleFonts.josefinSans(
                  fontSize: 18,
                  color: AppColor.textColor,
                ),
              ),
            );
          }).toList();
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
          width: MediaQuery.of(context).size.width -
              Values.bigCardPadding.horizontal -
              Values.bigCardMargin.horizontal,
          offset: const Offset(-10, -6),
          maxHeight: 200,
          decoration: BoxDecoration(
            border: Border.all(
              width: 2,
              color: AppColor.activeMenu,
            ),
            borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(Values.inputRadius),
                bottomLeft: Radius.circular(Values.inputRadius)),
            color: AppColor.backgroundGray,
          ),
        ),
      ),
    );
  }
}
