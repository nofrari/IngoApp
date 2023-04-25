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
  Dropdown({super.key, required this.dropdownItems});

  List<String> dropdownItems;

  @override
  State<Dropdown> createState() => _DropdownState();
}

class _DropdownState extends State<Dropdown> {
  String? selectedValue;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => {selectedValue = null});
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
      child: SizedBox(
        width: Values.inputWidth,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButtonFormField2(
              value: selectedValue,
              decoration: InputDecoration(
                label: Text(Strings.dropdownCategory, style: Fonts.text300),
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
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 10.0),
              ),
              isExpanded: true,
              items: List.generate(
                widget.dropdownItems.length + 1,
                (index) => index < widget.dropdownItems.length
                    ? DropdownMenuItem(
                        value: widget.dropdownItems[index],
                        child: Container(
                          width: Values.inputWidth,
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    width: 2,
                                    color: selectedValue ==
                                            widget.dropdownItems[index]
                                        ? AppColor.backgroundInputField
                                        : Colors.transparent),
                                top: const BorderSide(
                                    width: 2, color: Colors.transparent)),
                          ),
                          child: Text(
                            widget.dropdownItems[index],
                            style: GoogleFonts.josefinSans(
                              fontSize: 16,
                              color: AppColor.textColor,
                            ),
                          ),
                        ),
                      )
                    : DropdownMenuItem(
                        value: '',
                        child: TextButton(
                            style:
                                const ButtonStyle(alignment: Alignment.center),
                            child: Text(
                              'neue Kategorie hinzufügen',
                              style: GoogleFonts.josefinSans(
                                fontSize: 16,
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
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Das Feld darf nicht leer sein';
                }
                return null;
              },
              onChanged: (value) {
                debugPrint('changed');
                setState(() => selectedValue = value!);
              },
              onSaved: (value) {
                debugPrint('saved');
                selectedValue = value.toString();
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
                offset: const Offset(-10, -6),
                width: Values.inputWidth,
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
                ), /* 
                    scrollbarTheme: ScrollbarThemeData(
                      thickness: MaterialStateProperty.all<double>(5),
                      radius: Radius.circular(10),
                      thumbColor:
                          MaterialStateProperty.all<Color>(AppColor.activeMenu),
                      thumbVisibility: MaterialStateProperty.all(true),
                    ), */
              ),
            ),
          ],
        ),
      ),
    );
  }
}
