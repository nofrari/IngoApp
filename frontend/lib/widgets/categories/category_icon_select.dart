import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/constants/fonts.dart';
import 'package:frontend/constants/icons.dart';
import 'package:frontend/widgets/text_google.dart';
import 'package:provider/provider.dart';

import '../../models/icon.dart';
import '../../services/initial_service.dart';

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
  String currentIcon = "";

  List<IconModel> icons = [];

  void changeIcon(String icon) {
    setState(() {
      currentIcon = icon;
    });

    widget.onIconSelected(currentIcon);
  }

  @override
  Widget build(BuildContext context) {
    icons = context.watch<InitialService>().getIcons();
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
            height: 400,
            width: double.infinity,
            child: GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              itemCount: icons.length,
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
                      color: currentIcon == icons[index].name ||
                              widget.selectedIcon == icons[index].name
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
                          currentIcon = icons[index].name;
                        });
                        changeIcon(icons[index].name);
                      },
                      icon: FaIcon(
                        AppIcons.getIconFromString(icons[index].name),
                        size: 25,
                      ),
                      color: currentIcon == icons[index].name ||
                              widget.selectedIcon == icons[index].name
                          ? AppColor.blueActive
                          : Colors.white,
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
