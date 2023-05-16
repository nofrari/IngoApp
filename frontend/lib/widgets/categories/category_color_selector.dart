import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:frontend/constants/colors.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:frontend/constants/fonts.dart';
import 'package:frontend/widgets/text_google.dart';
import 'package:provider/provider.dart';
import '../../models/color.dart' as model;
import '../../services/initial_service.dart';

class ColorSelector extends StatefulWidget {
  String? selectedColor;
  final void Function(String color) onColorSelected;

  ColorSelector({this.selectedColor, required this.onColorSelected, super.key});

  @override
  _ColorSelectorState createState() => _ColorSelectorState();
}

class _ColorSelectorState extends State<ColorSelector> {
  String _currentColor = '';
  List<model.ColorModel> colorList = [];

  void changeColor(String color) {
    setState(() {
      _currentColor = color;
    });
    widget.onColorSelected(_currentColor);
  }

  @override
  Widget build(BuildContext context) {
    colorList = context.watch<InitialService>().getColors();
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 15),
            child: TextGoogle(
              align: TextAlign.start,
              text: "Kategoriefarbe:",
              style: Fonts.text300,
            ),
          ),
          Container(
            height: 125,
            width: double.infinity,
            child: BlockPicker(
              onColorChanged: (value) {},
              pickerColor: AppColor.getColorFromString(_currentColor),
              layoutBuilder: (context, colors, child) {
                return GridView.builder(
                  itemCount: colorList.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    return Material(
                      color: AppColor.getColorFromString(colorList[index].name),
                      shape: CircleBorder(
                        side: _currentColor == colorList[index].name ||
                                widget.selectedColor == colorList[index].name
                            ? BorderSide(width: 2, color: AppColor.activeMenu)
                            : BorderSide.none,
                      ),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _currentColor = colorList[index].name;
                          });
                          changeColor(colorList[index].name);
                        },
                        child: AppColor.getColorFromString(_currentColor) ==
                                colorList[index].name
                            ? Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColor.activeMenu,
                                ),
                                child: const SizedBox(
                                  width: 16,
                                  height: 16,
                                ),
                              )
                            : null,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
