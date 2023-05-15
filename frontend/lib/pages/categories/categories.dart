import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/constants/fonts.dart';
import 'package:frontend/pages/categories/category_add.dart';
import 'package:frontend/pages/categories/category_edit.dart';
import 'package:frontend/pages/profile.dart';
import 'package:frontend/services/initial_service.dart';
import 'package:frontend/widgets/button.dart';
import 'package:frontend/widgets/button_transparent_container.dart';
import 'package:frontend/widgets/categories/category_item.dart';
import 'package:frontend/widgets/header.dart';
import 'package:dio/dio.dart';
import 'package:frontend/widgets/text_google.dart';
import 'package:frontend/models/category.dart';
import 'package:frontend/models/color.dart';
import 'package:provider/provider.dart';

import '../../models/icon.dart';

class Categories extends StatefulWidget {
  const Categories({super.key});

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  Dio dio = Dio();
  List<CategoryModel> categories = [];
  List<IconModel> icons = [];
  List<ColorModel> colors = [];

  @override
  void initState() {
    super.initState();
  }

  List<CategoryModel> categoryList = [];

  Future<List<CategoryModel>> getData() async {
    try {
      var response = await dio.get("http://localhost:5432/categories/1");
      List<CategoryModel> categoryList = []; // move the declaration here
      if (response.data['categories'] != null) {
        for (var category in response.data['categories']) {
          IconModel desiredIcon =
              icons.firstWhere((icon) => icon.icon_id == category['icon_id']);
          ColorModel desiredColor = colors
              .firstWhere((color) => color.color_id == category['color_id']);
          categoryList.add(
            CategoryModel(
              category_id: category['category_id'],
              bgColor: desiredColor.name,
              isBlack: category['is_black'],
              icon: desiredIcon.name,
              label: category['category_name'],
            ),
          );
        }
        context.read<InitialService>().setCategories(categoryList);
      }

      return categoryList;
    } catch (e) {
      debugPrint(e.toString());
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    // context.read<InitialService>().setCategories(categoryList);
    colors = context.watch<InitialService>().getColors();
    icons = context.watch<InitialService>().getIcons();

    return Scaffold(
      appBar: Header(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Profile(),
            ),
          );
        },
        element: TextGoogle(
          align: TextAlign.center,
          text: "Kategorien".toUpperCase(),
          style: Fonts.text400,
        ),
      ),
      backgroundColor: AppColor.backgroundFullScreen,
      body: FutureBuilder<List<CategoryModel>>(
        future: getData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<CategoryModel> categories = snapshot.data!;
            return Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: SingleChildScrollView(
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: AppColor.neutral500,
                                  width: 0,
                                  style: BorderStyle.solid),
                              borderRadius: BorderRadius.circular(30),
                              color: AppColor.neutral500,
                            ),
                            child: Column(
                              children: <Widget>[
                                ...categories
                                    .map(
                                      (categoryItemsData) => CategoryItem(
                                        onTap: () async {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  CategoryEdit(
                                                category: categoryItemsData,
                                              ),
                                            ),
                                          );
                                        },
                                        bgColor: categoryItemsData.bgColor,
                                        isBlack: categoryItemsData.isBlack,
                                        icon: categoryItemsData.icon,
                                        label: categoryItemsData.label,
                                        isSmall: true,
                                      ),
                                    )
                                    .toList(),
                              ],
                            ),
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
                ButtonTransparentContainer(
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 20),
                    child: Button(
                        isTransparent: true,
                        btnText: "KATEGORIE HINZUFÜGEN",
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CategoryAdd(),
                            ),
                          );
                        },
                        theme: ButtonColorTheme.secondary),
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
