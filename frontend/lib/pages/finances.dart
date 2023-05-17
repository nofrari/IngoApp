import 'package:flutter/material.dart';
import 'package:frontend/models/category.dart';
import 'package:frontend/models/color.dart';
import 'package:frontend/models/icon.dart';
import 'package:frontend/widgets/input_fields/multiselect_dropdown.dart';

import 'package:frontend/widgets/transactions/transaction_list.dart';
import 'package:provider/provider.dart';

import '../constants/strings.dart';
import '../models/transaction.dart';
import '../services/initial_service.dart';
import '../services/transaction_service.dart';
import '../widgets/input_fields/datepicker_field.dart';
import '../widgets/input_fields/dropdown_field.dart';

class Finances extends StatefulWidget {
  const Finances({super.key});

  @override
  State<Finances> createState() => _FinancesState();
}

class _FinancesState extends State<Finances> {
  List<TransactionModel> transactions = [];
  List<ColorModel> colors = [];
  List<IconModel> icons = [];
  List<CategoryModel> categories = [];
  List<String> selectedCategories = [];
  String? selectedCategory;
  String? selectedStartDate;

  void onCategorySelected(String category) {
    setState(() {
      selectedCategory = category;
    });
    debugPrint("${selectedCategory}");
  }

  void onStartDateSelected(String startDate) {
    setState(() {
      selectedStartDate = startDate;
    });
  }
  // void onCategorySelected(String category) {
  //   setState(() {
  //     if (selectedCategories.contains(category)) {
  //       selectedCategories.remove(category);
  //     } else {
  //       selectedCategories.add(category);
  //     }
  //   });
  //   debugPrint(selectedCategories.toString());
  // }

  String _selectedType = "";
  void setSelectedType(String type) {
    setState(() {
      _selectedType = type;
    });
  }

  TextEditingController controllerStartDate = TextEditingController();
  TextEditingController controllerEndDate = TextEditingController();

  @override
  Widget build(BuildContext context) {
    transactions = context.watch<TransactionService>().getTransactions();
    categories = context.watch<InitialService>().getCategories();
    colors = context.watch<InitialService>().getColors();
    icons = context.watch<InitialService>().getIcons();

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            DatepickerField(
              label: "Start",
              controller: controllerStartDate,
            ),
            DatepickerField(
              label: "End",
              controller: controllerEndDate,
            ),
            Dropdown(
              label: Strings.dropdownFinancesCategories,
              setValue: (value) {
                onCategorySelected(value);
              },
              dropdownItems:
                  categories.map((category) => category.label).toList(),
              needsNewCategoryButton: false,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Das Feld darf nicht leer sein';
                }
                return null;
              },
            ),
            MultiSelectDropdownField(
              dropdownItems:
                  categories.map((category) => category.label).toList(),
              label: "Kategorien",
            ),

            // MultipleDropdown(
            //   label: Strings.dropdownFinancesCategories,
            //   setValue: (value) {
            //     onCategorySelected(value);
            //   },
            //   dropdownItems:
            //       categories.map((category) => category.label).toList(),
            //   validator: (value) {
            //     if (value == null || value.isEmpty) {
            //       return 'Das Feld darf nicht leer sein';
            //     }
            //     return null;
            //   },
            // ),
            // Dropdown(
            //   label: Strings.dropdownFinancesAccount,
            //   dropdownItems:
            //       categories.map((category) => category.label).toList(),
            //   needsNewCategoryButton: false,
            //   validator: (value) {
            //     if (value == null || value.isEmpty) {
            //       return 'Das Feld darf nicht leer sein';
            //     }
            //     return null;
            //   },
            // ),
            TransactionList(
              selectedCategory: selectedCategory,
              transactions: transactions,
            ),
          ],
        ),
      ),
    );
  }
}
