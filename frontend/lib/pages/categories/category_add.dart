import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/constants/fonts.dart';
import 'package:frontend/constants/icons.dart';
import 'package:frontend/constants/values.dart';
import 'package:frontend/pages/categories/categories.dart';
import 'package:frontend/services/profile_service.dart';
import 'package:frontend/widgets/button.dart';
import 'package:frontend/widgets/button_transparent_container.dart';
import 'package:frontend/widgets/categories/category_color_selector.dart';
import 'package:frontend/widgets/categories/category_icon.dart';
import 'package:frontend/widgets/categories/category_icon_select.dart';
import 'package:frontend/widgets/categories/category_toggle_black.dart';
import 'package:frontend/widgets/header.dart';
import 'package:dio/dio.dart';
import 'package:frontend/widgets/input_fields/input_field.dart';
import 'package:provider/provider.dart';

import '../../models/color.dart';
import '../../models/icon.dart';
import '../../services/initial_service.dart';
import '../../widgets/text_google.dart';

class CategoryAdd extends StatefulWidget {
  const CategoryAdd({super.key, this.lastPage});
  // final Function updateCategoryList;

  final String? lastPage;

  @override
  State<CategoryAdd> createState() => _CategoryAddState();
}

class _CategoryAddState extends State<CategoryAdd> {
  String bgColor = '';
  bool isWhite = false;
  String icon = '';
  String? label;
  bool? border;
  List<IconModel> icons = [];
  List<ColorModel> colors = [];

  void _updateSelectedColor(String color) {
    setState(() {
      border = false;
      bgColor = color;
    });
  }

  void _updateSelectedIcon(String icon) {
    setState(() {
      border = false;
      this.icon = icon;
    });
  }

  void _updateIsBlack() {
    setState(() {
      isWhite = !isWhite;
    });
  }

  bool _isFocused = false;
  void onTextFieldFocusChanged(bool isFocused) {
    setState(() {
      _isFocused = isFocused;
    });
  }

  Dio dio = Dio();
  TextInputFormatter letters = FilteringTextInputFormatter.allow(
      RegExp(r"[a-zA-Z0-9#+:'()&/^\-{2}|\s]"));
  TextInputType text = TextInputType.text;
  TextEditingController controllerCategoryName = TextEditingController();

  bool isFormValid() {
    return controllerCategoryName.text != "" && bgColor != "" && icon != "";
  }

  @override
  Widget build(BuildContext context) {
    colors = context.watch<InitialService>().getColors();
    icons = context.watch<InitialService>().getIcons();
    return Scaffold(
      appBar: Header(
        onTap: () {
          Navigator.pop(context);
        },
        element: TextGoogle(
          align: TextAlign.center,
          text: "Kategorie hinzufügen".toUpperCase(),
          style: Fonts.text400,
        ),
      ),
      backgroundColor: AppColor.backgroundFullScreen,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              child: Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      child: CategoryIcon(
                        bgColor: bgColor != ""
                            ? AppColor.getColorFromString(bgColor)
                            : AppColor.neutral600,
                        isWhite: isWhite,
                        icon: icon != ""
                            ? AppIcons.getIconFromString(icon)
                            : null,
                        isSmall: false,
                        border: border ?? true,
                      ),
                    ),
                    InputField(
                      onFocusChanged: onTextFieldFocusChanged,
                      lblText: "KATEGORIENAME",
                      reqFormatter: letters,
                      keyboardType: text,
                      controller: controllerCategoryName,
                      maxLength: 30,
                      hidePassword: false,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ColorSelector(
                      onColorSelected: _updateSelectedColor,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    CategoryToggleBlack(onToggleChange: _updateIsBlack),
                    const SizedBox(
                      height: 10,
                    ),
                    CategoryIconSelect(
                      onIconSelected: _updateSelectedIcon,
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
          ButtonTransparentContainer(
            child: Container(
              margin: Values.buttonPadding,
              child: Button(
                  isTransparent: true,
                  btnText: "KATEGORIE HINZUFÜGEN",
                  onTap: isFormValid()
                      ? () async {
                          await _createCategory(
                            controllerCategoryName.text,
                            bgColor,
                            isWhite,
                            icon,
                          );

                          if (widget.lastPage == "ManualEntry") {
                            Navigator.pop(context);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Categories(),
                              ),
                            ); // Navigate back to the previous screen
                          }
                        }
                      : () {},
                  theme: isFormValid()
                      ? ButtonColorTheme.secondaryLight
                      : ButtonColorTheme.disabled),
            ),
          ),
        ],
      ),
    );
  }

  Future _createCategory(
    String label,
    String colorName,
    bool is_white,
    String iconName,
  ) async {
    IconModel desiredIcon = icons.firstWhere((icon) => icon.name == iconName);
    ColorModel desiredColor =
        colors.firstWhere((color) => color.name == colorName);

    Map<String, dynamic> formData = {
      "category_name": label,
      "color_id": desiredColor.color_id,
      "is_white": is_white,
      "icon_id": desiredIcon.icon_id,
      "user_id": context.read<ProfileService>().getUser().id
    };

    var response = await dio.post(
      "${Values.serverURL}/categories/input",
      data: formData,
    );
  }
}
