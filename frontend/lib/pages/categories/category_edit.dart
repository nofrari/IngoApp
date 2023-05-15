import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/constants/fonts.dart';
import 'package:frontend/constants/icons.dart';
import 'package:frontend/constants/values.dart';
import 'package:frontend/pages/categories/category_delete.dart';
import 'package:frontend/start.dart';
import 'package:frontend/widgets/button.dart';
import 'package:frontend/widgets/button_transparent_container.dart';
import 'package:frontend/widgets/categories/category_color_selector.dart';
import 'package:frontend/widgets/categories/category_icon.dart';
import 'package:frontend/widgets/categories/category_icon_select.dart';
import 'package:frontend/widgets/categories/category_toggle_black.dart';
import 'package:frontend/widgets/header.dart';
import 'package:dio/dio.dart';
import 'package:frontend/widgets/input_fields/input_field.dart';
import 'package:frontend/widgets/round_button.dart';
import 'package:frontend/models/category.dart';
import 'package:provider/provider.dart';

import '../../models/color.dart';
import '../../models/icon.dart';
import '../../services/initial_service.dart';
import '../../widgets/text_google.dart';
import 'categories.dart';

class CategoryEdit extends StatefulWidget {
  CategoryEdit({required this.category, Key? key}) : super(key: key);

  CategoryModel category;

  @override
  State<CategoryEdit> createState() => _CategoryEditState();
}

class _CategoryEditState extends State<CategoryEdit> {
  Dio dio = Dio();
  TextInputFormatter letters = FilteringTextInputFormatter.allow(
      RegExp(r"[a-zA-Z0-9#+:'()&/^\-{2}|\s]"));
  TextInputType text = TextInputType.text;
  TextEditingController controllerCategoryName = TextEditingController();
  CategoryModel? editedCategory;
  List<IconModel> icons = [];
  List<ColorModel> colors = [];
  int? transactionCount = 0;

  void getData(BuildContext context) async {
    try {
      var response = await dio.get(
          "http://localhost:5432/categories/transactions/${widget.category.category_id}");
      // move the declaration here
      setState(() {
        transactionCount = response.data;
        debugPrint(transactionCount.toString());
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _updateSelectedColor(String color) {
    setState(() {
      widget.category.bgColor = color;
    });
  }

  void _updateSelectedIcon(String iconSelect) {
    setState(() {
      widget.category.icon = iconSelect;
    });
  }

  void _updateIsBlack() {
    setState(() {
      widget.category.isBlack = !widget.category.isBlack;
    });
  }

  void initState() {
    super.initState();
    getData(context);
    controllerCategoryName.text = widget.category.label;
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
          text: "Kategorie beabeiten".toUpperCase(),
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
                        bgColor: AppColor.getColorFromString(
                            widget.category.bgColor),
                        isBlack: widget.category.isBlack,
                        icon: AppIcons.getIconFromString(widget.category.icon),
                        isSmall: false,
                      ),
                    ),
                    InputField(
                      lblText: "KATEGORIENAME",
                      reqFormatter: letters,
                      keyboardType: text,
                      controller: controllerCategoryName,
                      maxLength: 30,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ColorSelector(
                        onColorSelected: _updateSelectedColor,
                        selectedColor: widget.category.bgColor),
                    const SizedBox(
                      height: 10,
                    ),
                    CategoryToggleBlack(
                      onToggleChange: _updateIsBlack,
                      isBlack: widget.category.isBlack,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    CategoryIconSelect(
                      onIconSelected: _updateSelectedIcon,
                      selectedIcon: widget.category.icon,
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
              child: Row(
                children: [
                  RoundButton(
                    onTap: transactionCount != 0
                        ? () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CategoryDelete(
                                  numberTransactions: transactionCount,
                                  category_id: widget.category.category_id,
                                ),
                              ),
                            );
                          }
                        : () async {
                            _deleteCategory(
                              widget.category.category_id,
                              transactionCount!,
                            );
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Categories(),
                              ),
                            );
                          },
                    icon: Icons.delete,
                    isTransparent: true,
                  ),
                  Expanded(
                    child: Button(
                        isTransparent: true,
                        btnText: "ÄNDERUNGEN SPEICHERN",
                        onTap: () async {
                          await _editCategory(
                            widget.category.category_id,
                            controllerCategoryName.text,
                            widget.category.isBlack,
                            widget.category.bgColor,
                            widget.category.icon,
                          );
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Categories(),
                            ),
                          );
                        },
                        theme: ButtonColorTheme.secondary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future _editCategory(
    String category_id,
    String category_name,
    bool is_black,
    String colorName,
    String iconName,
  ) async {
    IconModel desiredIcon = icons.firstWhere((icon) => icon.name == iconName);
    ColorModel desiredColor =
        colors.firstWhere((color) => color.name == colorName);
    Map<String, dynamic> formData = {
      "category_id": category_id,
      "category_name": category_name,
      "is_black": is_black,
      "color_id": desiredColor.color_id,
      "icon_id": desiredIcon.icon_id,
      "user_id": "1234"
    };

    var response =
        await dio.post("http://localhost:5432/categories/edit", data: formData);

    debugPrint(response.toString());
  }

  Future _deleteCategory(
      String current_category_id, int transactionCount) async {
    Map<String, dynamic> formData = {
      "current_category_id": current_category_id,
      "transactionCount": transactionCount
    };

    var response = await dio.delete(
        "http://localhost:5432/categories/${current_category_id}",
        data: formData);

    debugPrint(response.toString());
  }
}
