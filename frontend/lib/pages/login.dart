import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:email_validator/email_validator.dart';
import 'package:dio/dio.dart';
import 'package:frontend/constants/values.dart';
import 'package:frontend/pages/password_reset.dart';

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
      RegExp(r"[a-zA-Z0-9#+:'()&/^\-{2}|\s]"));
  TextInputFormatter mail = FilteringTextInputFormatter.allow(
      RegExp(r"[a-zA-Z0-9#+:'()&/^\-{2}|\s@.]"));
  TextInputFormatter password = FilteringTextInputFormatter.allow(
      RegExp(r"[a-zA-Z0-9#+:'()&/^\-{2}|\s@.!?]"));
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
  late bool credentialsMatch;

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
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PasswordReset(),
                  ),
                ),
                child: Text(
                  Strings.passwordForgot,
                  style: Fonts.textLink,
                ),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Button(
                    btnText: Strings.btnLogin.toUpperCase(),
                    onTap: () async {
                      if (_formKey.currentState!.validate() != false) {
                        await _sendData(
                            controllerMail.text, controllerPassword.text);
                        if (userExists == true) {
                          debugPrint('los gehts');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Start(),
                            ),
                          );
                        } else {
                          debugPrint('da passt was nicht');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
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
      await dio.post("${Values.serverURL}/users/login", data: formData);
      debugPrint('user hat sich eingeloggt');
      setState(() {
        userExists = true;
      });
    } on DioError catch (dioError) {
      debugPrint(dioError.toString());
      if (dioError.response != null) {
        switch (dioError.response!.statusCode) {
          case 404:
            debugPrint('error: 404 - User does not exist');
            setState(() {
              userExists = false;
            });
            break;
          case 401:
            debugPrint('error: 401 - Wrong email or password');
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
}
