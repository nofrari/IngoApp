import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:email_validator/email_validator.dart';
import 'package:dio/dio.dart';
import 'package:frontend/constants/values.dart';
import 'package:frontend/models/category.dart';
import 'package:frontend/models/color.dart';
import 'package:frontend/models/icon.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/pages/accounts/startaccount.dart';
import 'package:frontend/pages/password_reset.dart';
import 'package:frontend/pages/userauth.dart';
import 'package:frontend/services/initial_service.dart';
import 'package:frontend/services/profile_service.dart';
import 'package:provider/provider.dart';
import 'package:frontend/widgets/linkIntern.dart';

import '../constants/fonts.dart';
import '../start.dart';
import '../constants/strings.dart';
import '../widgets/input_fields/input_field.dart';
import '../widgets/button.dart';

class Login extends StatefulWidget {
  Login({
    this.focus,
    super.key,
  });
  bool? focus = false;

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
      RegExp(r"[a-zA-Z0-9ÄÖÜäöüß#+:'()&/^\-{2}|\s@.?%*$!]"));
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

  void changeVisibility(bool isFocused) {
    setState(() {
      widget.focus = isFocused;
    });
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
                      reqFormatter: letters,
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
                        return null;
                      },
                    ),
                    LinkIntern(
                      linkInternTo: PasswordReset(),
                      linkInternText: Strings.passwordForgot,
                    ),
                  ],
                ),
              )),
            ),
            IntrinsicHeight(
              child: Visibility(
                visible: widget.focus != true,
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
            ),
          ],
        ),
      ),
    );
  }

  void getData(BuildContext context) async {
    List<ColorModel> colors = [];
    List<IconModel> icons = [];
    User user = context.read<ProfileService>().getUser();
    dio.options.headers['authorization'] = 'Bearer ${user.token}';
    try {
      var response = await dio.get("${Values.serverURL}/categories/${user.id}");

      if (response.data != null) {
        for (var color in response.data['colors']) {
          colors.add(ColorModel.fromJson(color));
        }

        for (var icon in response.data['icons']) {
          icons.add(IconModel.fromJson(icon));
        }

        await context.read<InitialService>().setColors(colors);
        await context.read<InitialService>().setIcons(icons);
      }
      List<CategoryModel> categoryList = [];

      if (response.data['categories'] != null) {
        for (var category in response.data['categories']) {
          IconModel desiredIcon =
              icons.firstWhere((icon) => icon.icon_id == category['icon_id']);

          ColorModel desiredColor = colors
              .firstWhere((color) => color.color_id == category['color_id']);
          categoryList.add(
            CategoryModel(
              category_id: category['category_id'],
              bgColor: desiredColor.name,
              isWhite: category['is_white'],
              icon: desiredIcon.name,
              label: category['category_name'],
            ),
          );
        }
        await context.read<InitialService>().setCategories(categoryList);
      }
    } on DioError catch (dioError) {
      debugPrint(dioError.toString());
      logOut(dioError, context);
    } catch (e) {
      debugPrint(e.toString());
    }
    //response listen zu categorie liste und in shared pref
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
          email: response.data['email'],
          token: response.data['token']);
      getData(context);

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
