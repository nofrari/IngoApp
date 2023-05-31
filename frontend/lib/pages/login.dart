import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:email_validator/email_validator.dart';
import 'package:dio/dio.dart';
import 'package:frontend/constants/values.dart';
import 'package:frontend/pages/accounts/startaccount.dart';
import 'package:frontend/pages/password_reset.dart';
import 'package:frontend/services/profile_service.dart';
import 'package:provider/provider.dart';
import 'package:frontend/widgets/linkIntern.dart';

import '../constants/fonts.dart';
import '../start.dart';
import '../constants/strings.dart';
import '../widgets/input_fields/input_field.dart';
import '../widgets/button.dart';

class Login extends StatefulWidget {
  const Login({
    super.key,
  });

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String? valuePWValidator;
  TextInputFormatter digits = FilteringTextInputFormatter.digitsOnly;
  TextInputFormatter letters = FilteringTextInputFormatter.allow(
      RegExp(r"[a-zA-Z0-9ÄÖÜäöüß#+:'()&/^\-{2}|\s\.]"));
  TextInputFormatter mail = FilteringTextInputFormatter.allow(
      RegExp(r"[a-zA-Z0-9ÄÖÜäöüß@#+:'()&/^\-{2}|\s\.]"));
  TextInputFormatter password = FilteringTextInputFormatter.allow(
      RegExp(r"[a-zA-Z0-9ÄÖÜäöüß#+:'()&/^\-{2}|\s\.]"));
  TextInputType numeric = TextInputType.number;
  TextInputType text = TextInputType.text;

  TextEditingController controllerMail = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();

  String? Function(String?) required = (value) {
    if (value == null) {
      return Strings.alertInputfieldEmpty;
    }
    return null;
  };

  final _formKey = GlobalKey<FormState>();
  final PageStorageBucket bucket = PageStorageBucket();
  late bool userExists;
  late bool emailVerified;
  late bool credentialsMatch;
  bool hasAccounts = true;

  Dio dio = Dio();

  @override
  void initState() {
    super.initState();
    // controllerMail.text = "lehner.selina9@gmail.com";
    // controllerPassword.text = "123selina";
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
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
            //TODO: Link Passwort vergessen
            LinkIntern(
                linkInternTo: PasswordReset(),
                linkInternText: Strings.passwordForgot),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Button(
                    btnText: Strings.btnLogin.toUpperCase(),
                    onTap: () async {
                      if (_formKey.currentState!.validate() != false) {
                        await _sendData(
                            controllerMail.text, controllerPassword.text);
                        if (userExists == true && emailVerified == true) {
                          debugPrint('los gehts');
                          //Navigate to Start
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  hasAccounts ? Start() : StartAccount(),
                            ),
                          );
                        } else if (userExists == true &&
                            emailVerified == false) {
                          debugPrint('email nicht verifiziert');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Bitte verifiziere zuerst deine E-Mail-Adresse.')),
                          );
                        } else if (userExists == false) {
                          debugPrint('da passt was nicht');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                behavior: SnackBarBehavior.floating,
                                content: Text(
                                    'Keinen User gefunden, bitte überprüfe deine Eingaben.')),
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

  Future _sendData(String email, String password) async {
    Map<String, dynamic> formData = {
      "email": email,
      "password": password,
    };

    try {
      dynamic response =
          await dio.post("${Values.serverURL}/users/login", data: formData);
      debugPrint('user hat sich eingeloggt: ${response.data}');
      await context.read<ProfileService>().setUser(
          id: response.data['user_id'],
          firstname: response.data['user_name'].toString(),
          lastname: response.data['user_sirname'],
          email: response.data['email']);
      setState(() {
        userExists = true;
        emailVerified = true;
        response.data['number_accounts'] == 0
            ? hasAccounts = false
            : hasAccounts = true;
      });
    } on DioError catch (dioError) {
      debugPrint(dioError.toString());
      if (dioError.response != null) {
        switch (dioError.response!.statusCode) {
          case 404:
            debugPrint('error: 404 - User does not exist');
            setState(() {
              userExists = false;
              emailVerified = false;
            });
            break;
          case 401:
            debugPrint('error: 401 - Wrong email or password');
            setState(() {
              userExists = false;
              emailVerified = false;
            });
            break;
          case 403:
            debugPrint('error: 403 - Email not verified');
            setState(() {
              userExists = true;
              emailVerified = false;
            });
            break;
          default:
            setState(() {
              userExists = false;
              emailVerified = false;
            });
            debugPrint(
                'error: ${dioError.response!.statusCode} - Something went wrong while trying to connect with the server');
            break;
        }
      }
    } catch (e) {
      setState(() {
        userExists = false;
        emailVerified = false;
      });
      debugPrint('error: Something went wrong : $e');
    }
  }
}
