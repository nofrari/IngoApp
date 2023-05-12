import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/constants/fonts.dart';
import 'package:frontend/constants/icons.dart';
import 'package:frontend/widgets/text_google.dart';

class CategoryIconSelect extends StatefulWidget {
  CategoryIconSelect(
      {this.selectedIcon, required this.onIconSelected, Key? key})
      : super(key: key);
  String? selectedIcon;
  final void Function(String icon) onIconSelected;

  @override
  _CategoryIconSelectState createState() => _CategoryIconSelectState();
}

class _CategoryIconSelectState extends State<CategoryIconSelect> {
  String currentIcon = 'cookie';
  final List<String> _defaultIcons = [
    'cookie',
    'add',
    'delete',
  ];

  void changeIcon(String icon) {
    setState(() {
      currentIcon = icon;
    });

    widget.onIconSelected(currentIcon);
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
                align: TextAlign.start, text: "Icon:", style: Fonts.text300),
          ),
          Container(
            height: 125,
            width: double.infinity,
            child: GridView.builder(
              itemCount: _defaultIcons.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: currentIcon == _defaultIcons[index] ||
                              widget.selectedIcon == _defaultIcons[index]
                          ? AppColor.blueActive
                          : Colors.white,
                      width: 1,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          currentIcon = _defaultIcons[index];
                        });
                        changeIcon(_defaultIcons[index]);
                      },
                      icon: Icon(
                          AppIcons.getIconFromString(_defaultIcons[index])),
                      color: currentIcon == _defaultIcons[index] ||
                              widget.selectedIcon == _defaultIcons[index]
                          ? AppColor.blueActive
                          : Colors.white,
                      iconSize: 35,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
