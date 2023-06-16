import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:email_validator/email_validator.dart';
import 'package:dio/dio.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/constants/values.dart';
import 'package:frontend/models/interval_subtype.dart';
import 'package:frontend/pages/accounts/startaccount.dart';
import 'package:frontend/pages/login.dart';
import 'package:frontend/pages/userauth.dart';
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
import '../widgets/popup.dart';
import 'data_protection.dart';

class Register extends StatefulWidget {
  Register({
    this.focus,
    super.key,
  });
  bool? focus = false;

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
      RegExp(r"[a-zA-Z0-9ÄÖÜäöüß#+:'()&/^\-{2}|\s@.?%*$!]"));

  TextInputType numeric = TextInputType.number;
  TextInputType text = TextInputType.text;

  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerLastName = TextEditingController();
  TextEditingController controllerMail = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();
  TextEditingController controllerPasswordRepeat = TextEditingController();

  // bool firstRegister = false;

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
      debugPrint(e.toString());
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
      debugPrint(e.toString());
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
      debugPrint(e.toString());
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

  void changeVisibility(bool isFocused) {
    setState(() {
      widget.focus = isFocused;
    });
  }

  @override
  void initState() {
    super.initState();
    // controllerName.text = "selina";
    // controllerLastName.text = "lehner";
    // controllerMail.text = "lehner.selina9@gmail.com";
    // controllerPassword.text = "123selina";
    // controllerPasswordRepeat.text = "123selina";

    _getIntervals();
    _getTypes();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: GestureDetector(
        onTap: () {
          setState(() {
            widget.focus = false;
          });
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
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
                        onFocusChanged: changeVisibility,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return Strings.alertInputfieldEmpty;
                          }
                          return null;
                        },
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      InputField(
                        lblText: Strings.registerLastName,
                        reqFormatter: letters,
                        keyboardType: text,
                        controller: controllerLastName,
                        maxLength: 50,
                        maxLines: 1,
                        hidePassword: false,
                        onFocusChanged: changeVisibility,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return Strings.alertInputfieldEmpty;
                          }
                          return null;
                        },
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      InputField(
                        lblText: Strings.registerMail,
                        reqFormatter: mail,
                        keyboardType: text,
                        controller: controllerMail,
                        maxLength: 50,
                        maxLines: 1,
                        hidePassword: false,
                        onFocusChanged: changeVisibility,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return Strings.alertInputfieldEmpty;
                          } else if (EmailValidator.validate(value) == false) {
                            return Strings.alertMail;
                          }
                          return null;
                        },
                        onChanged: (value) {
                          controllerMail.value = TextEditingValue(
                              text: value.toLowerCase(),
                              selection: controllerMail.selection);
                        },
                      ),
                      InputField(
                        lblText: Strings.registerPassword,
                        reqFormatter: password,
                        keyboardType: text,
                        controller: controllerPassword,
                        maxLength: 50,
                        maxLines: 1,
                        hidePassword: true,
                        onFocusChanged: changeVisibility,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (valuePW) {
                          if (valuePW == null || valuePW.isEmpty) {
                            return Strings.alertInputfieldEmpty;
                          }

                          if (valuePW.length < 8) {
                            return "Dein Passwort muss länger als 8 Zeichen lang \nsein.";
                          }

                          if (!valuePW.contains(RegExp(r'[0-9]'))) {
                            return "Dein Passwort muss eine Zahl enthalten.";
                          }

                          if (!valuePW.contains(RegExp(r'[a-z]'))) {
                            return "Dein Passwort muss mindestens einen \nKleinbuchstaben enthalen.";
                          }

                          if (!valuePW.contains(RegExp(r'[A-Z]'))) {
                            return "Dein Passwort muss mindestens einen \nGroßbuchstaben enthalten.";
                          }

                          if (!valuePW.contains(
                              RegExp(r"[ß#+:'()&/^\-{2}|\s@.?%*$!]"))) {
                            return "Dein Passwort muss ein Sonderzeichen \nenthalten.";
                          }

                          return null;
                        },
                      ),
                      InputField(
                        lblText: Strings.registerPasswordRepeat,
                        reqFormatter: password,
                        keyboardType: text,
                        controller: controllerPasswordRepeat,
                        maxLength: 50,
                        maxLines: 1,
                        hidePassword: true,
                        onFocusChanged: changeVisibility,
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
                    ],
                  ),
                ),
              ),
            ),
            IntrinsicHeight(
              child: Visibility(
                visible: widget.focus != true,
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
                          debugPrint(
                              'existiert diese mail bereits? $mailExists');
                          if (mailExists == false) {
                            showPopup(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  content:
                                      Text('Mailadresse existiert bereits')),
                            );
                          }
                        }
                      },
                      theme: ButtonColorTheme.secondaryLight),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<dynamic> showPopup(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) =>
            PopUp(content: Strings.confirmEmail, actions: [
              Container(
                  margin: Values.buttonPadding,
                  child: Button(
                    btnText: Strings.btnBackToLogin.toUpperCase(),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Auth(showLogin: true),
                        ),
                      );
                    },
                    theme: ButtonColorTheme.secondaryLight,
                  )),
            ]));
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
