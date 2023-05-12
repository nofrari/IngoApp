import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/constants/fonts.dart';
import 'package:frontend/pages/categories/category_add.dart';
import 'package:frontend/pages/categories/category_edit.dart';
import 'package:frontend/pages/profile.dart';
import 'package:frontend/widgets/button.dart';
import 'package:frontend/widgets/button_transparent_container.dart';
import 'package:frontend/widgets/categories/category_item.dart';
import 'package:frontend/widgets/header.dart';
import 'package:dio/dio.dart';
import 'package:frontend/widgets/text_google.dart';
import 'package:frontend/models/category.dart';

class Categories extends StatefulWidget {
  const Categories({super.key});

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  Dio dio = Dio();

  List<Map<String, dynamic>> categoryItemsData = [
    {
      'bgColor': 'pink',
      'isBlack': true,
      'icon': 'cookie',
      'label': "Auto",
    },
    {
      'bgColor': 'pink',
      'isBlack': false,
      'icon': 'cookie',
      'label': "Bildung",
    },
    {
      'bgColor': 'pink',
      'isBlack': true,
      'icon': 'delete',
      'label': "Essen",
    },
    {
      'bgColor': 'pink',
      'isBlack': false,
      'icon': 'add',
      'label': "Studium",
    },
    {
      'bgColor': 'pink',
      'isBlack': false,
      'icon': 'delete',
      'label': "Running",
    },
    {
      'bgColor': 'pink',
      'isBlack': true,
      'icon': 'add',
      'label': "Auto",
    },
  ];

  List<Category> categories = [
    Category(
        category_id: "1",
        bgColor: 'pink',
        isBlack: true,
        icon: 'add',
        label: 'Essen'),
    Category(
        category_id: "2",
        bgColor: 'orange',
        isBlack: false,
        icon: 'delete',
        label: 'Uni')
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
    //liste categorien von der datenbank fetchen und in preferences schmeißen
  }

  void getData() async {
    var response = await dio.get("http://localhost:5432/categories/data");
    //response listen zu categorie liste und in shared pref
  }

  @override
  Widget build(BuildContext context) {
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
                              .map((categoryItemsData) => CategoryItem(
                                    onTap: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CategoryEdit(
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
                                  ))
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
              margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
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
      ),
    );
  }
}
