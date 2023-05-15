import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:email_validator/email_validator.dart';
import 'package:dio/dio.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/widgets/checkbox.dart';

import '../constants/fonts.dart';
import '../widgets/input_fields/checkbox_field.dart';
import '../widgets/input_fields/input_field.dart';
import '../widgets/button.dart';

import '../constants/strings.dart';
import '../start.dart';

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
      RegExp(r"[a-zA-Z0-9#+:'()&/^\-{2}|\s]"));
  TextInputFormatter mail = FilteringTextInputFormatter.allow(
      RegExp(r"[a-zA-Z0-9#+:'()&/^\-{2}|\s@.]"));
  TextInputFormatter password = FilteringTextInputFormatter.allow(
      RegExp(r"[a-zA-Z0-9#+:'()&/^\-{2}|\s@.!?]"));
  TextInputType numeric = TextInputType.number;
  TextInputType text = TextInputType.text;

  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerLastName = TextEditingController();
  TextEditingController controllerMail = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();
  TextEditingController controllerPasswordRepeat = TextEditingController();

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

  late bool mailExists;

  Dio dio = Dio();

  @override
  void initState() {
    super.initState();
    controllerLastName.text = "selina";
    controllerName.text = "lehner";
    controllerMail.text = "lehner.selina9@gmail.com";
    controllerPassword.text = "123selina";
    controllerPasswordRepeat.text = "123selina";
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
            //TODO: Datenschutzerklärung verlinken
            CheckboxDataProtection(
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
                    btnText: Strings.btnRegister,
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Start(),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Mailadresse existiert bereits')),
                          );
                        }
                      }
                    },
                    theme: ButtonColorTheme.secondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future _sendData(
      String name, String sirname, String email, String password) async {
    Map<String, dynamic> formData = {
      "user_name": name,
      "user_sirname": sirname,
      "email": email,
      "password": password,
    };

    try {
      await dio.post("http://localhost:5432/users/register", data: formData);

      mailExists = false;
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
