import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:frontend/constants/colors.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:frontend/constants/fonts.dart';
import 'package:frontend/widgets/text_google.dart';

class ColorSelector extends StatefulWidget {
  String? selectedColor;
  final void Function(String color) onColorSelected;

  ColorSelector({this.selectedColor, required this.onColorSelected, super.key});

  @override
  _ColorSelectorState createState() => _ColorSelectorState();
}

class _ColorSelectorState extends State<ColorSelector> {
  Dio dio = Dio();
  String _currentColor = 'pink';
  final List<String> _defaultColors = [
    'blueDark',
    'blueLight',
    'yellowDark',
    'greenLight',
    'greenAcid',
    'redDark',
    'pink',
    'orange',
    'violett',
    'greenKadmium',
    'greenNavy'
  ];

  @override
  void initState() {
    super.initState();
    _getDataForCategory();
  }

  void changeColor(String color) {
    setState(() {
      _currentColor = color;
    });

    widget.onColorSelected(_currentColor);
  }

  @override
  Widget build(BuildContext context) {
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
                  itemCount: _defaultColors.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    return Material(
                      color: AppColor.getColorFromString(_defaultColors[index]),
                      shape: CircleBorder(
                        side: _currentColor == _defaultColors[index] ||
                                widget.selectedColor == _defaultColors[index]
                            ? BorderSide(width: 2, color: AppColor.activeMenu)
                            : BorderSide.none,
                      ),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _currentColor = _defaultColors[index];
                          });
                          changeColor(_defaultColors[index]);
                        },
                        child: AppColor.getColorFromString(_currentColor) ==
                                colors[index]
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

  Future _getDataForCategory() async {
    var response = await dio.get(
      "http://localhost:5432/categories/data",
    );

    debugPrint(response.toString());
  }
}
