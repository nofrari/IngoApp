import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:email_validator/email_validator.dart';
import 'package:dio/dio.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/constants/values.dart';
import 'package:frontend/models/interval_subtype.dart';
import 'package:frontend/pages/accounts/startaccount.dart';
import 'package:frontend/services/profile_service.dart';
import 'package:frontend/widgets/checkbox.dart';
import 'package:provider/provider.dart';

import '../constants/fonts.dart';
import '../models/category.dart';
import '../services/initial_service.dart';
import '../widgets/input_fields/checkbox_field.dart';
import '../widgets/input_fields/input_field.dart';
import '../widgets/button.dart';
import '../models/interval.dart' as transaction_interval;
import '../models/transaction_type.dart';

import '../constants/strings.dart';
import '../start.dart';
import 'data_protection.dart';

class Register extends StatefulWidget {
  const Register({
    super.key,
  });

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String? valuePWValidator;
  TextInputFormatter digits = FilteringTextInputFormatter.digitsOnly;
  TextInputFormatter letters = FilteringTextInputFormatter.allow(
      RegExp(r"[a-zA-Z0-9ÄÖÜäöüß#+:'()&/^\-{2}|\s]"));
  TextInputFormatter mail = FilteringTextInputFormatter.allow(
      RegExp(r"[a-zA-Z0-9ÄÖÜäöüß@#+:'()&/^\-{2}|\s@.]"));
  TextInputFormatter password = FilteringTextInputFormatter.allow(
      RegExp(r"[a-zA-Z0-9ÄÖÜäöüß#+:'()&/^\-{2}|\s@.!?]"));
  TextInputType numeric = TextInputType.number;
  TextInputType text = TextInputType.text;

  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerLastName = TextEditingController();
  TextEditingController controllerMail = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();
  TextEditingController controllerPasswordRepeat = TextEditingController();

  void _getCategories() async {
    try {
      String val = context.read<ProfileService>().getUser().id;
      print("ID $val");
      Response response = await Dio().get(
          '${Values.serverURL}/categories/${context.read<ProfileService>().getUser().id}');
      List<CategoryModel> categories = [];

      for (var i = 0; i < response.data["categories"].length; i++) {
        var iconId = response.data["categories"][i]['icon_id'].toString();
        var colorId = response.data["categories"][i]['color_id'].toString();

        var icon = response.data["icons"]
            .firstWhere((icon) => icon['icon_id'] == iconId);
        var iconName = icon['icon_name'].toString();

        var color = response.data["colors"]
            .firstWhere((color) => color['color_id'] == colorId);
        var colorName = color['color_name'].toString();

        categories.add(CategoryModel(
            category_id:
                response.data["categories"][i]['category_id'].toString(),
            bgColor: colorName,
            isWhite: response.data["categories"][i]['is_white'],
            icon: iconName,
            label: response.data["categories"][i]['category_name'].toString()));
      }
      await context.read<InitialService>().setCategories(categories);
    } catch (error) {
      print(error);
    }
  }

  void _getIntervals() async {
    //Intervals
    try {
      Response response = await Dio().get('${Values.serverURL}/intervals');
      List<transaction_interval.IntervalModel> interval = [];

      for (var i = 0; i < response.data.length; i++) {
        interval.add(transaction_interval.IntervalModel(
          interval_id: response.data[i]['interval_id'].toString(),
          name: response.data[i]['interval_name'].toString(),
        ));
      }

      await context.read<InitialService>().setInterval(interval);
    } catch (e) {
      print(e);
    }
    //Subtypes
    try {
      Response response =
          await Dio().get('${Values.serverURL}/intervalsubtypes');
      List<IntervalSubtypeModel> intervalSubtypes = [];

      for (var i = 0; i < response.data.length; i++) {
        intervalSubtypes.add(IntervalSubtypeModel(
          interval_subtype_id:
              response.data[i]['interval_subtype_id'].toString(),
          name: response.data[i]['interval_subtype_name'].toString(),
        ));
      }

      await context.read<InitialService>().setIntervalSubtype(intervalSubtypes);
    } catch (e) {
      print(e);
    }
  }

  void _getTypes() async {
    try {
      Response response = await Dio().get('${Values.serverURL}/types');
      List<TransactionType> type = [];

      for (var i = 0; i < response.data.length; i++) {
        type.add(TransactionType(
          type_id: response.data[i]['type_id'].toString(),
          name: response.data[i]['type_name'].toString(),
        ));
      }

      await context.read<InitialService>().setTransactionType(type);
    } catch (e) {
      print(e);
    }
  }

  String? Function(String?) required = (value) {
    if (value == null) {
      return Strings.alertInputfieldEmpty;
    }
    return null;
  };

  final _formKey = GlobalKey<FormState>();
  final PageStorageBucket bucket = PageStorageBucket();
  bool _isChecked = false;
  // void onCheckboxChanged(bool isChecked) {
  //   setState(() {
  //     _isChecked = isChecked;
  //   });
  // }

  late bool mailExists = false;

  Dio dio = Dio();

  @override
  void initState() {
    super.initState();
    // controllerName.text = "selina";
    // controllerLastName.text = "lehner";
    // controllerMail.text = "lehner.selina9@gmail.com";
    // controllerPassword.text = "123selina";
    // controllerPasswordRepeat.text = "123selina";

    _getCategories();
    _getIntervals();
    _getTypes();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            InputField(
              lblText: Strings.registerFirstName,
              reqFormatter: letters,
              keyboardType: text,
              controller: controllerName,
              maxLength: 50,
              maxLines: 1,
              hidePassword: false,
              onFocusChanged: (hasFocus) {
                if (hasFocus) {
                  // do stuff
                }
                ;
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return Strings.alertInputfieldEmpty;
                }
                return null;
              },
            ),
            InputField(
              lblText: Strings.registerLastName,
              reqFormatter: letters,
              keyboardType: text,
              controller: controllerLastName,
              maxLength: 50,
              maxLines: 1,
              hidePassword: false,
              onFocusChanged: (hasFocus) {
                if (hasFocus) {
                  // do stuff
                }
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return Strings.alertInputfieldEmpty;
                }
                return null;
              },
            ),
            InputField(
              lblText: Strings.registerMail,
              reqFormatter: mail,
              keyboardType: text,
              controller: controllerMail,
              maxLength: 50,
              maxLines: 1,
              hidePassword: false,
              onFocusChanged: (hasFocus) {
                if (hasFocus) {
                  // do stuff
                }
                ;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return Strings.alertInputfieldEmpty;
                } else if (EmailValidator.validate(value) == false) {
                  return Strings.alertMail;
                }
                return null;
              },
            ),
            InputField(
              lblText: Strings.registerPassword,
              reqFormatter: letters,
              keyboardType: text,
              controller: controllerPassword,
              maxLength: 50,
              maxLines: 1,
              hidePassword: true,
              onFocusChanged: (hasFocus) {
                if (hasFocus) {
                  // do stuff
                }
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (valuePW) {
                if (valuePW == null || valuePW.isEmpty) {
                  return Strings.alertInputfieldEmpty;
                }
                return null;
              },
            ),
            InputField(
              lblText: Strings.registerPasswordRepeat,
              reqFormatter: letters,
              keyboardType: text,
              controller: controllerPasswordRepeat,
              maxLength: 50,
              maxLines: 1,
              hidePassword: true,
              onFocusChanged: (hasFocus) {
                if (hasFocus) {
                  // do stuff
                }
                ;
              },
              validator: (valuePW) {
                if (valuePW == null || valuePW.isEmpty) {
                  return Strings.alertInputfieldEmpty;
                } else if (valuePW != controllerPassword.text) {
                  return Strings.alertPasswordWrong;
                }
                return null;
              },
            ),
            CheckboxDataProtection(
              linkText: 'Ich stimme der Datenschutzbestimmung zu',
              linkTo: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DataProtection(),
                ),
              ),
              value: _isChecked,
              onCheckboxTapped: (bool? value) {
                setState(() {
                  _isChecked = value!;
                });
              },
              validator: (value) {
                if (!_isChecked) {
                  return Strings.alertDataProtectionEmpty;
                } else {
                  return null;
                }
              },
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Button(
                    btnText: Strings.btnRegister.toUpperCase(),
                    onTap: () async {
                      if (_formKey.currentState!.validate() != false) {
                        // createUser();
                        await _sendData(
                          controllerName.text,
                          controllerLastName.text,
                          controllerMail.text,
                          controllerPassword.text,
                        );
                        debugPrint('existiert diese mail bereits? $mailExists');
                        if (mailExists == false) {
                          _showConfirmationDialog(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                behavior: SnackBarBehavior.floating,
                                content: Text('Mailadresse existiert bereits')),
                          );
                        }
                      }
                    },
                    theme: ButtonColorTheme.secondaryLight),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Email'),
          content: Text(
              'Please check your email and confirm your account to log in.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future _sendData(
      String name, String sirname, String email, String password) async {
    Map<String, dynamic> formData = {
      "user_name": name,
      "user_sirname": sirname,
      "email": email,
      "password": password,
      "email_confirmed": false,
    };

    try {
      dynamic response =
          await dio.post("${Values.serverURL}/users/register", data: formData);

      setState(() {
        mailExists = false;
      });
    } on DioError catch (dioError) {
      debugPrint(dioError.toString());
      if (dioError.response != null) {
        switch (dioError.response!.statusCode) {
          case 409:
            debugPrint('error: 409 - Email already exists');
            setState(() {
              mailExists = true;
            });
            break;
          default:
            debugPrint(
                'error: ${dioError.response!.statusCode} - Something went wrong while trying to connect with the server');
            break;
        }
      }
    } catch (e) {
      debugPrint('error: Something went wrong : $e');
    }
  }
}
