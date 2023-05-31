import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/constants/fonts.dart';
import 'package:frontend/constants/values.dart';
import 'package:frontend/pages/categories/categories.dart';
import 'package:frontend/widgets/button.dart';
import 'package:frontend/widgets/button_transparent_container.dart';
import 'package:frontend/widgets/header.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import '../../models/category.dart';
import '../../services/initial_service.dart';
import '../../widgets/categories/category_item.dart';
import '../../widgets/text_google.dart';

class CategoryDelete extends StatefulWidget {
  CategoryDelete(
      {required this.category_id, this.numberTransactions, super.key});
  int? numberTransactions;
  String category_id;

  @override
  State<CategoryDelete> createState() => _CategoryDeleteState();
}

class _CategoryDeleteState extends State<CategoryDelete> {
  List<CategoryModel> categories = [];
  String? selectedCategoryId;
  bool isFormValid() {
    return selectedCategoryId != null && selectedCategoryId != "";
  }

  void _selectNewCategory(String category_id) {
    setState(() {
      selectedCategoryId = category_id;
    });
    debugPrint(selectedCategoryId);
  }

  void initState() {
    super.initState();
  }

  Dio dio = Dio();

  @override
  Widget build(BuildContext context) {
    categories = context.watch<InitialService>().getCategories();
    final filteredCategories = categories
        .where((category) => category.category_id != widget.category_id)
        .toList();
    int? transactionNumbers = widget.numberTransactions;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
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
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Column(
                            children: <Widget>[
                              ...filteredCategories.map((category) {
                                var isSelected =
                                    category.category_id == selectedCategoryId;

                                return CategoryItem(
                                  onTap: () =>
                                      _selectNewCategory(category.category_id),
                                  bgColor: category.bgColor,
                                  isWhite: category.isWhite,
                                  icon: category.icon,
                                  label: category.label,
                                  isSmall: true,
                                  isSelected: isSelected,
                                );
                              }).toList(),
                            ],
                          ),
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
                margin:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
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
                        theme: ButtonColorTheme.secondaryLight,
                      ),
                    ),
                    Button(
                      isTransparent: true,
                      btnText: "SPEICHERN",
                      onTap: isFormValid()
                          ? () async {
                              _deleteCategory(
                                widget.category_id,
                                selectedCategoryId!,
                                widget.numberTransactions!,
                              );
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Categories(),
                                ),
                              );
                            }
                          : () {},
                      theme: isFormValid()
                          ? ButtonColorTheme.primary
                          : ButtonColorTheme.disabled,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future _deleteCategory(String current_category_id, String new_category_id,
      int transactionCount) async {
    Map<String, dynamic> formData = {
      "current_category_id": current_category_id,
      "new_category_id": new_category_id,
      "transactionCount": transactionCount
    };

    var response = await dio.delete(
        "${Values.serverURL}/categories/${current_category_id}",
        data: formData);

    debugPrint(response.toString());
  }
}
