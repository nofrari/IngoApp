import 'package:dio/dio.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/pages/userauth.dart';
import 'package:frontend/widgets/linkIntern.dart';

import '../constants/fonts.dart';
import '../constants/strings.dart';
import '../widgets/button.dart';
import '../widgets/input_fields/input_field.dart';
import '../widgets/popup.dart';

import '../constants/colors.dart';
import '../constants/values.dart';

class PasswordReset extends StatefulWidget {
  @override
  _PasswordResetState createState() => _PasswordResetState();
}

class _PasswordResetState extends State<PasswordReset> {
  final _formKey = GlobalKey<FormState>();
  late bool userExists;

  TextInputFormatter mail = FilteringTextInputFormatter.allow(
      RegExp(r"[a-zA-Z0-9#+:'()&/^\-{2}|\s@.]"));
  TextInputType text = TextInputType.text;
  TextEditingController controllerMail = TextEditingController();

  Dio dio = Dio();

  @override
  void initState() {
    super.initState();
    controllerMail.text = "lehner.selina9@gmail.com";
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: AppColor.backgroundFullScreen,
        body: Form(
          key: _formKey,
          child: Container(
            padding: Values.bigCardPadding,
            child: SingleChildScrollView(
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
                    height: MediaQuery.of(context).size.height * 0.7,
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: AppColor.neutral500, style: BorderStyle.solid),
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      color: AppColor.backgroundGray,
                    ),
                    child: Container(
                        margin: Values.bigCardMargin,
                        child: Column(children: <Widget>[
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.only(top: 60, bottom: 20),
                              child: Text(
                                Strings.passwordForgot.toUpperCase(),
                                style: Fonts.text400,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 40),
                            child: Text(Strings.passwordForgotInfo,
                                style: Fonts.text300),
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
                          LinkIntern(
                              linkInternTo: Auth(),
                              linkInternText: Strings.notRegistered),
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Button(
                                btnText: Strings.btnPasswordReset.toUpperCase(),
                                onTap: () async {
                                  if (_formKey.currentState!.validate() !=
                                      false) {
                                    await _sendData(controllerMail.text);
                                    if (userExists == true) {
                                      showPopup(context);
                                    } else {
                                      debugPrint('da passt was nicht');
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Keinen User gefunden, bitte überprüfe deine Eingaben.')),
                                      );
                                    }
                                  }
                                },
                                theme: ButtonColorTheme.secondaryLight,
                              ),
                            ),
                          )
                        ])),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<dynamic> showPopup(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) =>
            PopUp(content: Strings.passwordForgotPopup, actions: [
              Container(
                  margin: Values.buttonPadding,
                  child: Button(
                    btnText: Strings.btnBackToLogin.toUpperCase(),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Auth(),
                        ),
                      );
                    },
                    theme: ButtonColorTheme.secondaryLight,
                  )),
            ]));
  }

  Future _sendData(String email) async {
    Map<String, dynamic> formData = {
      "email": email,
    };
    try {
      await dio.post("${Values.serverURL}/users/reset-password",
          data: formData);
      debugPrint('wir sind dabei');
      setState(() {
        userExists = true;
      });
    } on DioError catch (dioError) {
      debugPrint(dioError.toString());
      if (dioError.response != null) {
        switch (dioError.response!.statusCode) {
          case 404:
            debugPrint('error: 404 - keinen User gefunden');
            setState(() {
              userExists = false;
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

  // Future _resetPassword(String email) async {
  //   Map<String, dynamic> formData = {
  //     "email": email,
  //   };

  //   try {
  //     await dio.post("http://localhost:5432/users/edit", data: formData);
  //     debugPrint('wir sind dabei');
  //     setState(() {
  //       userExists = true;
  //     });
  //   } on DioError catch (dioError) {
  //     debugPrint(dioError.toString());
  //     if (dioError.response != null) {
  //       switch (dioError.response!.statusCode) {
  //         case 404:
  //           debugPrint('error: 404 - keinen User gefunden');
  //           setState(() {
  //             userExists = false;
  //           });
  //           break;
  //         default:
  //           debugPrint(
  //               'error: ${dioError.response!.statusCode} - Something went wrong while trying to connect with the server');
  //           break;
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint('error: Something went wrong : $e');
  //   }
  // }
}
