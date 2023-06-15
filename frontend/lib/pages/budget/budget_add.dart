import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/constants/fonts.dart';
import 'package:frontend/constants/strings.dart';
import 'package:frontend/constants/values.dart';
import 'package:frontend/models/account.dart';
import 'package:frontend/models/category.dart';
import 'package:frontend/models/interval.dart' as budget_interval;
import 'package:frontend/models/budget.dart';
import 'package:frontend/pages/budget/budget.dart';
import 'package:frontend/services/initial_service.dart';
import 'package:frontend/services/budget_service.dart';
import 'package:frontend/start.dart';
import 'package:frontend/widgets/button.dart';
import 'package:frontend/widgets/button_transparent_container.dart';
import 'package:frontend/widgets/header.dart';
import 'package:frontend/widgets/input_fields/input_field.dart';
import 'package:frontend/widgets/input_fields/dropdown_field.dart';
import 'package:frontend/widgets/input_fields/datepicker_field.dart';
import 'package:dio/dio.dart';
import 'package:frontend/widgets/popup.dart';
import 'package:frontend/widgets/round_button.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../services/profile_service.dart';
import '../../widgets/input_fields/dropdown_field_multi.dart';
import '../../widgets/tag.dart';

class BudgetAdd extends StatefulWidget {
  BudgetAdd({super.key, this.isEditMode = false, this.returnToStart = true});
  bool isEditMode;
  bool returnToStart;

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
      selectedCategory = values.join(", ");
    });
  }

  void handleCategoryTagsChanged(List<String> tags) {
    setState(() {
      selectedCategories = allCategories
          .where((category) => tags.contains(category.label))
          .toList();
    });

    setState(() {
      selectedCategoryTags = tags;
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

      controllerStartDate.text = loadedBudget.startdate == DateTime(2000)
          ? ""
          : DateFormat("dd / MM / yyyy").format(loadedBudget.startdate);
      controllerEndDate.text = loadedBudget.enddate == DateTime(2000)
          ? ""
          : DateFormat("dd / MM / yyyy").format(loadedBudget.enddate);

      allCategories = context.read<InitialService>().getCategories();

      if (loadedBudget.categoryIds.isNotEmpty) {
        selectedCategories = allCategories
            .where((category) =>
                loadedBudget.categoryIds.contains(category.category_id))
            .toList();

        _initialCategories = selectedCategories
            .map((selectedCategory) => selectedCategory.category_id)
            .toList();
      }
    });
  }

  List<Widget> generateTags() {
    List<Widget> tags = [];
    tags.addAll(selectedCategoryTags.map((String item) {
      return Tag(
        btnText: item,
        isCategory: true,
        onTap: () {
          setState(() {
            selectedCategoryTags.remove(item);
          });
          onCategorySelected(selectedCategoryTags);
        },
      );
    }));
    return tags;
  }

  @override
  void initState() {
    super.initState();
    loadBudget();
    //BudgetAdd = context.read<BudgetAddService>().getBudgetAdd();
    if (BudgetAdd.isNotEmpty) {
      controllerTitle.text = BudgetAdd['budget_name'] ?? "";
      controllerLimit.text = BudgetAdd['budget_limit'] != null
          ? NumberFormat.currency(locale: 'de', name: "EUR", symbol: '€')
              .format(BudgetAdd['budget_limit'])
          : "";
      controllerStartDate.text = BudgetAdd['date'] != null
          ? DateFormat("dd / MM / yyyy")
              .format(DateFormat("yyyy-MM-dd").parse(BudgetAdd['date']))
          : "";
      controllerEndDate.text = BudgetAdd['date'] != null
          ? DateFormat("dd / MM / yyyy")
              .format(DateFormat("yyyy-MM-dd").parse(BudgetAdd['date']))
          : "";
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    BudgetAdd = context.watch<BudgetService>().getBudgetEntry();

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
                                      // await context
                                      //     .read<BudgetAddService>()
                                      //     .forgetBudgetAdd();
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
                                        builder: (context) =>
                                            widget.returnToStart
                                                ? Start()
                                                : Start(pageId: 3),
                                      ),
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const Budget(),
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
                //TODO: check if this causes problems
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => const Start(),
                //   ),
                // );
                Navigator.pop(context);
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
                          ),
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
                            //serverDate: manualEntry['date'],
                            errorMsgBgColor: AppColor.neutral500,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Das Feld darf nicht leer sein';
                              }
                              return null;
                            },
                            //TODO: Add callback to call updateCurrentTransaction
                          ),
                          DatepickerField(
                            label: Strings.budgetEnd,
                            controller: controllerEndDate,
                            //serverDate: manualEntry['date'],
                            errorMsgBgColor: AppColor.neutral500,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Das Feld darf nicht leer sein';
                              }
                              return null;
                            },
                            //TODO: Add callback to call updateCurrentTransaction
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
                                  // await context
                                  //     .read<BudgetAddService>()
                                  //     .forgetBudgetAdd();
                                  await context
                                      .read<BudgetService>()
                                      .clearBudget();
                                  await DefaultCacheManager().emptyCache();
                                  //TODO: zurück zum Budget
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Start(),
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
                                    updateCurrentBudget();
                                    if (_formKey.currentState!.validate()) {
                                      // ScaffoldMessenger.of(context).showSnackBar(
                                      //   const SnackBar(
                                      //       content:
                                      //           Text('Daten werden gespeichert')),
                                      // );
                                      final startdate =
                                          startDatePicker.selectedDate;
                                      final enddate =
                                          endDatePicker.selectedDate;

                                      debugPrint(
                                          "is complete: ${_currentBudget.isCompleted()}");
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
                                        // await context
                                        //     .read<BudgetAddService>()
                                        //     .forgetBudgetAdd();
                                        await context
                                            .read<BudgetService>()
                                            .clearBudget();
                                      }
                                      // ignore: use_build_context_synchronously
                                      Navigator.pop(context);
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
    DateTime BudgetStartDateTime = Budget.startdate.add(
      Duration(hours: now.hour, minutes: now.minute, seconds: now.second),
    );
    DateTime BudgetEndDateTime = Budget.enddate.add(
      Duration(hours: now.hour, minutes: now.minute, seconds: now.second),
    );

    Map<String, dynamic> formData = {
      "budget_id": Budget.budget_id,
      "budget_name": Budget.budget_name,
      "budget_amount": Budget.budget_amount,
      "startdate": BudgetStartDateTime.toString(),
      "enddate": BudgetEndDateTime.toString(),
      "user_id": context.read<ProfileService>().getUser().id.toString(),
      "category_ids": Budget.categoryIds.toList(),
    };

    debugPrint(formData.entries.toList().toString());
    var response =
        await dio.post("${Values.serverURL}/budget/input", data: formData);
    debugPrint("send data response: ${response.toString()}");
    print(BudgetStartDateTime);
  }
}
