import 'package:flutter/material.dart';
import 'package:frontend/start.dart';
import 'package:frontend/widgets/input_fields/checkbox_field.dart';
import 'package:frontend/widgets/input_fields/input_field.dart';
import '../widgets/toggle_button_selina.dart';
import 'package:flutter/services.dart';
import '../widgets/button.dart';

//Email
import 'package:email_validator/email_validator.dart';

//import constants
import '../constants/colors.dart';
import '../constants/strings.dart';
import '../constants/values.dart';

class Register extends StatefulWidget {
  const Register({super.key});

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
  Widget currentScreen = const Register();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: AppColor.backgroundFullScreen,
        body: Container(
          padding: Values.bigCardPadding,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  //Logo
                  Container(
                    padding: const EdgeInsets.only(top: 60, bottom: 20),
                    child: Image.asset(
                      'assets/images/logo_slogan.png',
                      alignment: Alignment.topCenter,
                      height: 150,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: AppColor.neutral500, style: BorderStyle.solid),
                      borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(20),
                          topLeft: Radius.circular(20),
                          bottomRight: Radius.circular(11),
                          bottomLeft: Radius.circular(11)),
                      color: AppColor.backgroundGray,
                    ),
                    child: Column(children: [
                      const Toggle(),
                      Container(
                        margin: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            InputField(
                              lblText: Strings.registerFirstName,
                              reqFormatter: letters,
                              keyboardType: text,
                              controller: controllerName,
                              maxLength: 50,
                              maxLines: 1,
                              onFocusChanged: (hasFocus) {
                                if (hasFocus) {
                                  // do stuff
                                }
                                ;
                              },
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
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
                              onFocusChanged: (hasFocus) {
                                if (hasFocus) {
                                  // do stuff
                                }
                              },
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
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
                              onFocusChanged: (hasFocus) {
                                if (hasFocus) {
                                  // do stuff
                                }
                                ;
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return Strings.alertInputfieldEmpty;
                                } else if (EmailValidator.validate(value) ==
                                    false) {
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
                              onFocusChanged: (hasFocus) {
                                if (hasFocus) {
                                  // do stuff
                                }
                              },
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
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
                            CheckboxField(
                              validator: (valuePW) {
                                if (valuePW == false) {
                                  return Strings.alertDataProtectionEmpty;
                                }
                                return null;
                              },
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: Button(
                                  btnText: Strings.btnRegister,
                                  onTap: () {
                                    if (_formKey.currentState!.validate() !=
                                        false) {
                                      // ScaffoldMessenger.of(context)
                                      //     .showSnackBar(
                                      //   const SnackBar(
                                      //       content: Text(
                                      //           'Daten werden gespeichert')),
                                      // );
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const Start(),
                                        ),
                                      );
                                    }
                                  },
                                  theme: ButtonColorTheme.primary),
                            ),
                          ],
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
