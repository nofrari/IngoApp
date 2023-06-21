import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/constants/fonts.dart';
import 'package:frontend/constants/strings.dart';
import 'package:frontend/constants/values.dart';
import 'package:frontend/models/category.dart';
import 'package:frontend/models/budget.dart';
import 'package:frontend/services/initial_service.dart';
import 'package:frontend/services/budget_service.dart';
import 'package:frontend/start.dart';
import 'package:frontend/widgets/button.dart';
import 'package:frontend/widgets/button_transparent_container.dart';
import 'package:frontend/widgets/header.dart';
import 'package:frontend/widgets/input_fields/input_field.dart';
import 'package:frontend/widgets/input_fields/datepicker_field.dart';
import 'package:dio/dio.dart';
import 'package:frontend/widgets/popup.dart';
import 'package:frontend/widgets/round_button.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../services/profile_service.dart';
import '../../widgets/input_fields/dropdown_field_multi.dart';
import '../../widgets/tag.dart';

class BudgetAdd extends StatefulWidget {
  BudgetAdd({super.key, this.isEditMode = false});
  bool isEditMode;

  @override
  State<BudgetAdd> createState() => _BudgetAddState();
}

class _BudgetAddState extends State<BudgetAdd> {
  TextInputFormatter digits = FilteringTextInputFormatter.digitsOnly;
  TextInputFormatter letters = FilteringTextInputFormatter.allow(
      RegExp(r"[a-zA-Z0-9ÄÖÜäöüß#+:'()&/^\-{2}|\s\.,€?=]"));
  TextInputType numeric = TextInputType.number;
  TextInputType text = TextInputType.text;

  TextEditingController controllerTitle = TextEditingController();
  TextEditingController controllerLimit = TextEditingController();
  TextEditingController controllerCurrAmount = TextEditingController();
  TextEditingController controllerStartDate = TextEditingController();
  TextEditingController controllerEndDate = TextEditingController();

  final DatepickerField startDatePicker = DatepickerField(
    controller: TextEditingController(),
    errorMsgBgColor: AppColor.neutral500,
  );
  final DatepickerField endDatePicker = DatepickerField(
    controller: TextEditingController(),
    errorMsgBgColor: AppColor.neutral500,
  );

  String? Function(String?) required = (value) {
    if (value == null) {
      return 'Das Feld darf nicht leer sein';
    }
    return null;
  };

  final _formKey = GlobalKey<FormState>();

  List<String> versuch = ["kat1", "kat2", "kat3"];
  List<CategoryModel> categories = [];
  List<String> selectedCategoryTags = [];
  String? selectedCategory;
  CategoryModel? selectedCategoryModel;
  List<CategoryModel> allCategories = [];
  List<CategoryModel> selectedCategories = [];

  Map<String, dynamic> BudgetAdd = {};
  List<String>? _initialCategories;
  String? _loadedBudgetId;
  bool optionChosen = true;
  Dio dio = Dio();

  bool _isFocused = false;
  void onTextFieldFocusChanged(bool isFocused) {
    setState(() {
      _isFocused = isFocused;
    });
    updateCurrentBudget();
  }

  void onCategorySelected(List<String> values) {
    setState(() {
      for (var value in values) {
        if (!selectedCategoryTags.contains(value)) {
          selectedCategoryTags.add(value);
        }
      }
      selectedCategories = allCategories
          .where((category) => selectedCategoryTags.contains(category.label))
          .toList();
    });
  }

  void handleCategoryTagsChanged(List<String> tags) {
    setState(() {
      if (selectedCategoryTags.isNotEmpty) {
        final List<String> newTags = List.from(selectedCategoryTags)
          ..addAll(tags);
        selectedCategories = allCategories
            .where((category) => newTags.contains(category.label))
            .toList();
        selectedCategoryTags = newTags
            .toSet()
            .toList(); // Convert to set to remove duplicates, then convert back to list
      } else {
        selectedCategories = allCategories
            .where((category) => tags.contains(category.label))
            .toList();
        selectedCategoryTags = tags;
      }
    });
  }

  bool _enableExitPopUp() {
    if (controllerTitle.text.isNotEmpty ||
        controllerLimit.text.isNotEmpty ||
        controllerCurrAmount.text.isNotEmpty ||
        controllerStartDate.text.isNotEmpty ||
        controllerEndDate.text.isNotEmpty ||
        controllerEndDate.text.isNotEmpty ||
        selectedCategory != null) {
      return true;
    }
    return false;
  }

  BudgetModel _currentBudget = BudgetModel(
    budget_id: "",
    budget_name: "",
    budget_amount: 0,
    startdate: DateTime.now(),
    enddate: DateTime.now(),
    categoryIds: [],
  );

  void updateCurrentBudget() async {
    setState(() {
      _currentBudget = BudgetModel(
        budget_id: _loadedBudgetId ?? "",
        budget_name: controllerTitle.text,
        budget_amount: currencyToDouble(controllerLimit.text),
        startdate: controllerStartDate.text != ""
            ? DateFormat("dd / MM / yyyy").parse(controllerStartDate.text)
            : DateTime(2000),
        enddate: controllerEndDate.text != ""
            ? DateFormat("dd / MM / yyyy").parse(controllerEndDate.text)
            : DateTime(2000),
        categoryIds: selectedCategories.isNotEmpty
            ? selectedCategories
                .map((selectedCategory) => selectedCategory.category_id)
                .toList()
            : [],
      );
    });
    await context.read<BudgetService>().setBudget(_currentBudget);
  }

  void loadBudget() {
    BudgetModel? loadedBudget = context.read<BudgetService>().getBudget();
    if (loadedBudget == null) return;
    setState(() {
      _currentBudget = loadedBudget;
      _loadedBudgetId = loadedBudget.budget_id;
      controllerTitle.text = loadedBudget.budget_name;
      controllerLimit.text = loadedBudget.budget_amount != null
          ? NumberFormat.currency(locale: 'de', name: "EUR", symbol: '€')
              .format(loadedBudget.budget_amount)
          : "";
      controllerStartDate.text = loadedBudget.startdate != null
          ? DateFormat("dd / MM / yyyy").format(loadedBudget.startdate)
          : "";
      controllerEndDate.text = loadedBudget.enddate != null
          ? DateFormat("dd / MM / yyyy").format(loadedBudget.enddate)
          : "";

      allCategories = context.read<InitialService>().getCategories();

      if (loadedBudget.categoryIds.isNotEmpty) {
        selectedCategories = allCategories
            .where((category) =>
                loadedBudget.categoryIds.contains(category.category_id))
            .toList();

        setState(() {
          selectedCategoryTags = selectedCategories
              .map((selectedCategory) => selectedCategory.label)
              .toList();
        });
      }
    });
  }

  List<Widget> generateTags() {
    final List<String> uniqueTags = [];
    final List<Widget> tags = [];
    for (var selectedCategoryTag in selectedCategoryTags) {
      if (!uniqueTags.contains(selectedCategoryTag)) {
        uniqueTags.add(selectedCategoryTag);
        tags.add(
          Tag(
            btnText: selectedCategoryTag,
            isSmall: true,
            noIcon: false,
            onTap: () async {
              setState(() {
                selectedCategoryTags.remove(selectedCategoryTag);
                handleCategoryTagsChanged(selectedCategoryTags);
              });
              await updateCurrentBudget;
            },
          ),
        );
      }
    }

    return tags;
  }

  @override
  void initState() {
    super.initState();
    loadBudget();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> tags = generateTags();
    setState(() {
      allCategories = context.watch<InitialService>().getCategories();
    });
    List<String> categoryNames =
        allCategories.map((category) => category.label).toList();

    return WillPopScope(
      onWillPop: () async => false,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isFocused = false;
          });
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          appBar: Header(
            onTap: () async {
              if (_enableExitPopUp()) {
                // warning dialog
                showDialog(
                  context: context,
                  builder: (BuildContext context) => PopUp(
                    content: widget.isEditMode == false
                        ? "Wenn du diese Seite verlässt, verliest du den Fortschritt mit dieser Eingabe. Bist du sicher, dass du zurück zur Budgetübersicht möchtest?"
                        : "Bist du sicher, dass du die Änderungen verwefen möchtest?",
                    actions: [
                      Container(
                        margin: Values.buttonPadding,
                        child: Column(
                          children: [
                            Button(
                                btnText: "ABBRECHEN",
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                theme: ButtonColorTheme.secondaryLight),
                            Button(
                                btnText: "FORTFAHREN",
                                onTap: () async {
                                  if (context.mounted) {
                                    try {
                                      await DefaultCacheManager().emptyCache();
                                      await context
                                          .read<BudgetService>()
                                          .clearBudget();
                                    } catch (e) {
                                      debugPrint(e.toString());
                                    }
                                  }
                                  if (widget.isEditMode) {
                                    // ignore: use_build_context_synchronously
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Start(pageId: 4),
                                      ),
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Start(
                                          pageId: 4,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                theme: ButtonColorTheme.primary),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Start(pageId: 4),
                  ),
                );
              }
            },
            element: Text(
              (controllerTitle.text.isNotEmpty)
                  ? controllerTitle.text.toUpperCase()
                  : "NEUES BUDGET",
              style: Fonts.textHeadingBold,
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
                    padding: Values.bigCardPadding,
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: AppColor.neutral500,
                            width: 0,
                            style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(11),
                        color: AppColor.neutral500),
                    margin: Values.bigCardMargin,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          InputField(
                            lblText: "Titel",
                            reqFormatter: letters,
                            keyboardType: text,
                            controller: controllerTitle,
                            maxLines: 1,
                            hidePassword: false,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Das Feld darf nicht leer sein';
                              }
                              return null;
                            },
                            maxLength: 50,
                            onFocusChanged: onTextFieldFocusChanged,
                          ),
                          InputField(
                            lblText: "Budgetlimit in €",
                            reqFormatter: currencyFormatter,
                            keyboardType: numeric,
                            controller: controllerLimit,
                            maxLines: 1,
                            hidePassword: false,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Das Feld darf nicht leer sein';
                              }
                              return null;
                            },
                            maxLength: 15,
                            onFocusChanged: onTextFieldFocusChanged,
                          ),
                          DropdownMultiselect(
                              dropdownItems: categoryNames,
                              setValues: (value) {
                                onCategorySelected(value);
                              },
                              hintText: Strings.budgetCategory,
                              width: (MediaQuery.of(context).size.width -
                                  Values.bigCardMargin.horizontal -
                                  Values.bigCardPadding.horizontal),
                              selectedTags: selectedCategoryTags,
                              onTagsChanged: handleCategoryTagsChanged,
                              error: optionChosen == true ? false : true),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Wrap(
                              spacing: 8,
                              children: tags,
                            ),
                          ),
                          //only if tags are selected
                          if (tags.length > 0)
                            const SizedBox(
                              height: 15,
                            ),
                          DatepickerField(
                            label: Strings.budgetStart,
                            controller: controllerStartDate,
                            serverDate: controllerStartDate.text.isNotEmpty
                                ? DateFormat("dd / MM / yyyy")
                                    .parse(controllerStartDate.text)
                                    .toIso8601String()
                                : null,
                            errorMsgBgColor: AppColor.neutral500,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Das Feld darf nicht leer sein';
                              } else if (controllerEndDate.text.isNotEmpty &&
                                  value != "") {
                                String startDateString =
                                    DateFormat('yyyy-MM-dd').format(
                                        DateFormat('dd / MM / yyyy')
                                            .parse(value!));
                                String endDateString = DateFormat('yyyy-MM-dd')
                                    .format(DateFormat('dd / MM / yyyy')
                                        .parse(controllerEndDate.text));

                                DateTime startDate =
                                    DateTime.parse(startDateString);
                                DateTime endDate =
                                    DateTime.parse(endDateString);

                                if (endDate.isBefore(startDate)) {
                                  return "Startdatum darf nicht nach \ndem Enddatum liegen";
                                } else {
                                  return null;
                                }
                              }
                              return null;
                            },
                          ),
                          DatepickerField(
                            label: Strings.budgetEnd,
                            controller: controllerEndDate,
                            serverDate: controllerEndDate.text.isNotEmpty
                                ? DateFormat("dd / MM / yyyy")
                                    .parse(controllerEndDate.text)
                                    .toIso8601String()
                                : null,
                            errorMsgBgColor: AppColor.neutral500,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Das Feld darf nicht leer sein';
                              } else if (controllerStartDate.text.isNotEmpty &&
                                  value != "") {
                                String startDateString =
                                    DateFormat('yyyy-MM-dd').format(
                                        DateFormat('dd / MM / yyyy')
                                            .parse(controllerStartDate.text));
                                String endDateString = DateFormat('yyyy-MM-dd')
                                    .format(DateFormat('dd / MM / yyyy')
                                        .parse(value!));

                                DateTime startDate =
                                    DateTime.parse(startDateString);
                                DateTime endDate =
                                    DateTime.parse(endDateString);

                                if (endDate.isBefore(startDate)) {
                                  return "Enddatum darf nicht vor \ndem Startdatum liegen";
                                } else {
                                  return null;
                                }
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              (_isFocused == false)
                  ? ButtonTransparentContainer(
                      child: Container(
                        margin: Values.buttonPadding,
                        child: Row(
                          children: [
                            if (widget.isEditMode)
                              RoundButton(
                                onTap: () async {
                                  await dio.delete(
                                      "${Values.serverURL}/budgets/delete/${_currentBudget.budget_id}");

                                  await context
                                      .read<BudgetService>()
                                      .clearBudget();
                                  await DefaultCacheManager().emptyCache();
                                  //TODO: zurück zum Budget
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Start(
                                        pageId: 4,
                                      ),
                                    ),
                                  );
                                },
                                icon: Icons.delete,
                                isTransparent: true,
                              ),
                            Expanded(
                              child: Button(
                                  isTransparent: true,
                                  btnText: widget.isEditMode
                                      ? "ÄDERUNGEN SPEICHERN"
                                      : "SPEICHERN",
                                  onTap: () async {
                                    setState(() {
                                      if (selectedCategoryTags.isEmpty) {
                                        optionChosen = false;
                                      } else if (selectedCategoryTags
                                          .isNotEmpty) {
                                        optionChosen = true;
                                      }
                                    });
                                    updateCurrentBudget();
                                    if (_formKey.currentState!.validate() &&
                                        optionChosen == true) {
                                      final startdate =
                                          startDatePicker.selectedDate;
                                      final enddate =
                                          endDatePicker.selectedDate;

                                      if (_currentBudget.isCompleted()) {
                                        await _sendData(
                                          _currentBudget,
                                        );
                                      } else {
                                        debugPrint(
                                            "current Budget Id: ${_currentBudget.budget_id} name: ${_currentBudget.budget_name} amount: ${_currentBudget.budget_amount} startdate: ${_currentBudget.startdate} enddate: ${_currentBudget.enddate} category_id: ${_currentBudget.categoryIds}");
                                      }
                                      await DefaultCacheManager().emptyCache();

                                      if (context.mounted) {
                                        await context
                                            .read<BudgetService>()
                                            .clearBudget();
                                      }
                                      // ignore: use_build_context_synchronously
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Start(
                                            pageId: 4,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  theme: ButtonColorTheme.secondaryLight),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  Future _sendData(BudgetModel Budget) async {
    DateTime now = DateTime.now();
    DateTime StartDateTime = Budget.startdate.add(
      Duration(hours: 0, minutes: 0, seconds: 0),
    );
    DateTime EndDatetime = Budget.enddate.add(
      Duration(hours: 0, minutes: 0, seconds: 0),
    );

    Map<String, dynamic> formData = {
      "budget_id": Budget.budget_id,
      "budget_name": Budget.budget_name,
      "budget_amount": Budget.budget_amount,
      "startdate": StartDateTime.toString(),
      "enddate": EndDatetime.toString(),
      "user_id": context.read<ProfileService>().getUser().id.toString(),
      "category_ids": Budget.categoryIds.toList(),
    };
    var response =
        await dio.post("${Values.serverURL}/budget/input", data: formData);
  }
}
