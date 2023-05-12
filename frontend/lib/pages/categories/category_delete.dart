import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/constants/fonts.dart';
import 'package:frontend/start.dart';
import 'package:frontend/widgets/button.dart';
import 'package:frontend/widgets/button_transparent_container.dart';
import 'package:frontend/widgets/header.dart';
import 'package:dio/dio.dart';
import '../../widgets/categories/category_item.dart';
import '../../widgets/text_google.dart';

class CategoryDelete extends StatefulWidget {
  CategoryDelete({this.numberTransactions, super.key});
  int? numberTransactions;

  @override
  State<CategoryDelete> createState() => _CategoryDeleteState();
}

class _CategoryDeleteState extends State<CategoryDelete> {
  List<Map<String, dynamic>> categoryItemsData = [
    {
      'bgColor': 'pink',
      'isBlack': true,
      'icon': 'cookie',
      'label': "Auto",
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

  String? selectedCategory;

  void _selectNewCategory(String label) {
    setState(() {
      selectedCategory = label;
    });
    debugPrint(selectedCategory);
  }

  void initState() {
    super.initState();
    selectedCategory = "Coffee";
  }

  Dio dio = Dio();

  @override
  Widget build(BuildContext context) {
    int? transactionNumbers = widget.numberTransactions;
    return Scaffold(
      appBar: Header(
        onTap: () {
          Navigator.pop(context);
        },
        element: TextGoogle(
          align: TextAlign.center,
          text: "Kategorie löschen".toUpperCase(),
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
                      padding: const EdgeInsets.symmetric(horizontal: 48),
                      margin: const EdgeInsets.only(bottom: 15),
                      child: Text(
                        "Du bist dabei eine Kategorie zu löschen, der $transactionNumbers Einträge zugeordnet sind!",
                        textAlign: TextAlign.center,
                        style: Fonts.text300,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 42),
                      margin: const EdgeInsets.only(bottom: 15),
                      child: Text(
                        "Wähle bitte eine neue Kategorie für die Einträge aus, um forzufahren",
                        textAlign: TextAlign.center,
                        style: Fonts.text300,
                      ),
                    ),
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
                          ...categoryItemsData
                              .map((categoryItemsData) => CategoryItem(
                                    onTap: () => _selectNewCategory(
                                      categoryItemsData['label'],
                                    ),
                                    bgColor: categoryItemsData['bgColor'],
                                    isBlack: categoryItemsData['isBlack'],
                                    icon: categoryItemsData['icon'],
                                    label: categoryItemsData['label'],
                                    isSmall: true,
                                  ))
                              .toList(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 150),
                  ],
                ),
              ),
            ),
          ),
          ButtonTransparentContainer(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
              height: 120,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    child: Button(
                      isTransparent: true,
                      btnText: "ABBRECHEN",
                      onTap: () {
                        Navigator.pop(context);
                      },
                      theme: ButtonColorTheme.secondary,
                    ),
                  ),
                  Button(
                    isTransparent: true,
                    btnText: "SPEICHERN",
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Start(),
                        ),
                      );
                    },
                    theme: ButtonColorTheme.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future _createCategory(
    String label,
    String color,
    bool isBlack,
    String icon,
  ) async {
    Map<String, dynamic> formData = {
      "category_name": label,
      "color": color,
      "isBlack": isBlack,
      "icon": icon,
      "user_id": "1234"
    };

    var response = await dio.post("http://localhost:5432/categories/input",
        data: formData);

    debugPrint(response.toString());
  }
}
