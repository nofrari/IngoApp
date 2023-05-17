import 'package:flutter/material.dart';
import 'package:frontend/models/category.dart';
import 'package:frontend/models/color.dart';
import 'package:frontend/models/icon.dart';
import 'package:frontend/services/accounts_service.dart';
import 'package:frontend/widgets/input_fields/multiselect_dropdown.dart';

import 'package:frontend/widgets/transactions/transaction_list.dart';
import 'package:provider/provider.dart';

import '../constants/strings.dart';
import '../models/account.dart';
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
  List<Account> accounts = [];
  String? selectedCategory;
  String? selectedAccount;
  String? selectedStartDate;

  void onStartDateSelected(String startDate) {
    setState(() {
      selectedStartDate = startDate;
    });
  }

  void onCategorySelected(List<String> values) {
    setState(() {
      selectedCategory = values.join(", ");
    });
    debugPrint(selectedCategory);
  }

  void onAccountSelected(List<String> values) {
    setState(() {
      selectedAccount = values.join(", ");
    });
    debugPrint(selectedAccount);
  }

  TextEditingController controllerStartDate = TextEditingController();
  TextEditingController controllerEndDate = TextEditingController();

  @override
  Widget build(BuildContext context) {
    transactions = context.watch<TransactionService>().getTransactions();
    categories = context.watch<InitialService>().getCategories();
    colors = context.watch<InitialService>().getColors();
    icons = context.watch<InitialService>().getIcons();
    accounts = context.watch<AccountsService>().getAccounts();

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

            MultiSelectDropdownField(
              dropdownItems:
                  categories.map((category) => category.label).toList(),
              setValues: (value) {
                onCategorySelected(value);
              },
              label: "Kategorie",
            ),
            MultiSelectDropdownField(
              dropdownItems: accounts.map((account) => account.name).toList(),
              setValues: (value) {
                onAccountSelected(value);
              },
              label: "Konto",
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
                accounts: selectedAccount),
          ],
        ),
      ),
    );
  }
}
