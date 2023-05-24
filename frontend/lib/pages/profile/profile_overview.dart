import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/constants/fonts.dart';
import 'package:frontend/constants/strings.dart';
import 'package:frontend/constants/values.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/pages/userauth.dart';
import 'package:frontend/services/profile_service.dart';
import 'package:frontend/start.dart';
import 'package:frontend/widgets/button.dart';
import 'package:frontend/widgets/header.dart';
import 'package:frontend/widgets/input_fields/input_field.dart';
import 'package:frontend/widgets/popup.dart';
import 'package:provider/provider.dart';

class ProfileOverview extends StatefulWidget {
  const ProfileOverview({super.key});

  @override
  State<ProfileOverview> createState() => _ProfileOverviewState();
}

class _ProfileOverviewState extends State<ProfileOverview> {
  User user = User(id: "", firstName: " ", lastName: " ", email: " ");
  TextInputFormatter letters = FilteringTextInputFormatter.allow(
      RegExp(r"[a-zA-Z0-9#+:'()&/^\-{2}|\s]"));

  TextEditingController controllerFirstName = TextEditingController();
  TextEditingController controllerLastName = TextEditingController();
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerPasswordOld = TextEditingController();
  TextEditingController controllerPasswordNew = TextEditingController();
  TextEditingController controllerPasswordNew2 = TextEditingController();

  TextInputType text = TextInputType.text;

  bool _isFocused = false;
  bool _isDeletingAccount = false;
  String _newPassword = "";
  void onTextFieldFocusChanged(bool isFocused) {
    setState(() {
      _isFocused = isFocused;
      _newPassword = controllerPasswordNew.text;
    });
  }

  void disposeController(TextEditingController controller) {
    controller.dispose();
  }

  Dio dio = Dio();

  final _passwordFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    setState(() {
      user = context.read<ProfileService>().getUser();
      controllerFirstName.text = user.firstName;
      controllerLastName.text = user.lastName;
      controllerEmail.text = user.email;
    });
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      user = context.watch<ProfileService>().getUser();
    });
    return Scaffold(
      appBar: Header(
        onTap: () {
          if (_isDeletingAccount) {
            setState(() {
              _isDeletingAccount = false;
            });
          } else {
            Navigator.pop(context);
          }
        },
        element: Text(
          _isDeletingAccount ? Strings.profileDelete : Strings.profileEdit,
          style: Fonts.textHeadingBold,
        ),
      ),
      backgroundColor: AppColor.backgroundFullScreen,
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 130,
              height: 130,
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: AppColor.blueActive,
                border: null,
              ),
              child: Center(
                child: Text(
                  user.abreviationName,
                  style: Fonts.userIconBig,
                ),
              ),
            ),
            _isDeletingAccount
                ? Container(
                    margin: Values.bigCardMargin,
                    height: MediaQuery.of(context).size.height * 0.63,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Möchtest du dein Konto wirklich löschen?"
                              .toUpperCase(),
                          style: Fonts.text300,
                          textAlign: TextAlign.center,
                        ),
                        Padding(
                          padding: Values.bigCardPadding,
                          child: Text(
                            "Dein Profil, deine Einstellungen und alle Daten der App werden dauerhaft gelöscht.",
                            style: Fonts.text150,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const Spacer(),
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: Values.buttonPadding,
                              child: Button(
                                  btnText: Strings.profileDelete,
                                  onTap: () async {
                                    try {
                                      var response = await dio.get(
                                          "${Values.serverURL}/users/delete/${user.id}");
                                      await context
                                          .read<ProfileService>()
                                          .setUser(
                                              id: "",
                                              firstname: "",
                                              lastname: "",
                                              email: "");
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Auth(),
                                        ),
                                      );
                                    } catch (e) {
                                      debugPrint(e.toString());
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Ein Fehler ist aufgetreten.')),
                                      );
                                    }
                                  },
                                  theme: ButtonColorTheme.secondaryDark),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                : Container(
                    height: MediaQuery.of(context).size.height * 0.63,
                    margin: Values.bigCardMargin,
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: AppColor.neutral500, style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(Values.cardRadius),
                      color: AppColor.backgroundGray,
                    ),
                    child: Form(
                      child: Container(
                        margin: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            InputField(
                              lblText: Strings.registerFirstName,
                              reqFormatter: letters,
                              keyboardType: text,
                              controller: controllerFirstName,
                              maxLines: 1,
                              maxLength: 50,
                              onFocusChanged: onTextFieldFocusChanged,
                              hidePassword: false,
                              onDispose: () {
                                disposeController(controllerFirstName);
                              },
                            ),
                            InputField(
                              lblText: Strings.registerLastName,
                              reqFormatter: letters,
                              keyboardType: text,
                              controller: controllerLastName,
                              maxLines: 1,
                              maxLength: 50,
                              onFocusChanged: onTextFieldFocusChanged,
                              hidePassword: false,
                              onDispose: () {
                                disposeController(controllerLastName);
                              },
                            ),
                            InputField(
                              lblText: Strings.registerMail,
                              reqFormatter: letters,
                              keyboardType: text,
                              controller: controllerEmail,
                              maxLines: 1,
                              maxLength: 50,
                              onFocusChanged: onTextFieldFocusChanged,
                              hidePassword: false,
                              onDispose: () {
                                disposeController(controllerEmail);
                              },
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isDeletingAccount = true;
                                  });
                                },
                                child: Text(
                                  "Konto löschen",
                                  style: Fonts.textLink,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Button(
                                btnText: Strings.profileEditPassword,
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) => PopUp(
                                      actions: [
                                        Container(
                                          margin: Values.buttonPadding,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.8,
                                          child: Column(
                                            children: [
                                              Form(
                                                key: _passwordFormKey,
                                                child: Column(children: [
                                                  InputField(
                                                    lblText: Strings
                                                        .profileOldPassword,
                                                    reqFormatter: letters,
                                                    keyboardType: text,
                                                    controller:
                                                        controllerPasswordOld,
                                                    maxLines: 1,
                                                    maxLength: 50,
                                                    onFocusChanged:
                                                        onTextFieldFocusChanged,
                                                    hidePassword: true,
                                                    onDispose: () {
                                                      disposeController(
                                                          controllerPasswordOld);
                                                    },
                                                  ),
                                                  InputField(
                                                    lblText: Strings
                                                        .profileNewPassword,
                                                    reqFormatter: letters,
                                                    keyboardType: text,
                                                    controller:
                                                        controllerPasswordNew,
                                                    maxLines: 1,
                                                    maxLength: 50,
                                                    onFocusChanged:
                                                        onTextFieldFocusChanged,
                                                    hidePassword: true,
                                                    onDispose: () {
                                                      disposeController(
                                                          controllerPasswordNew);
                                                    },
                                                  ),
                                                  InputField(
                                                    lblText: Strings
                                                        .profileNewPassword2,
                                                    reqFormatter: letters,
                                                    keyboardType: text,
                                                    controller:
                                                        controllerPasswordNew2,
                                                    maxLines: 1,
                                                    maxLength: 50,
                                                    onFocusChanged:
                                                        onTextFieldFocusChanged,
                                                    hidePassword: true,
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty ||
                                                          value !=
                                                              _newPassword) {
                                                        return "Passwörter stimmen nicht überein";
                                                      }
                                                      return null;
                                                    },
                                                    onDispose: () {
                                                      disposeController(
                                                          controllerPasswordNew2);
                                                    },
                                                  ),
                                                ]),
                                              ),
                                              Button(
                                                  btnText: Strings.profileSave
                                                      .toUpperCase(),
                                                  onTap: () async {
                                                    if (_passwordFormKey
                                                            .currentState!
                                                            .validate() !=
                                                        false) {
                                                      await _sendPasswordData(
                                                          controllerPasswordOld
                                                              .text,
                                                          controllerPasswordNew2
                                                              .text);
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                            content: Text(
                                                                'Daten gespeichert.')),
                                                      );
                                                      Navigator.pop(context);
                                                    }
                                                  },
                                                  theme: ButtonColorTheme
                                                      .secondaryLight),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                },
                                theme: ButtonColorTheme.secondaryLight),
                            Button(
                                btnText: Strings.profileSave.toUpperCase(),
                                onTap: () async {
                                  try {
                                    await _sendData(
                                        controllerFirstName.text,
                                        controllerLastName.text,
                                        controllerEmail.text);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Daten gespeichert.')),
                                    );
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const Start(pageId: 4),
                                      ),
                                    );
                                  } catch (e) {
                                    debugPrint(e.toString());
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Ein Fehler ist aufgetreten.')),
                                    );
                                  }
                                },
                                theme: ButtonColorTheme.secondaryLight),
                            //: Container(),
                          ],
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Future _sendData(String firstName, String lastName, String email) async {
    Map<String, dynamic> formData = {
      "user_name": firstName,
      "user_sirname": lastName,
      "email": email,
      "user_id": user.id
    };

    var response =
        await dio.post("${Values.serverURL}/users/edit", data: formData);
    await context.read<ProfileService>().setUser(
        id: user.id, firstname: firstName, lastname: lastName, email: email);
    debugPrint(response.toString());
  }

  Future _sendPasswordData(String oldPassword, String newPassword) async {
    try {
      Map<String, dynamic> formData = {
        "old_password": oldPassword,
        "new_password": newPassword,
        "email": user.email,
        "user_id": user.id
      };

      var response =
          await dio.post("${Values.serverURL}/users/edit", data: formData);
      debugPrint(response.toString());
    } on DioError catch (dioError) {
      debugPrint(dioError.toString());
      if (dioError.response != null) {
        switch (dioError.response!.statusCode) {
          case 401:
            debugPrint('error: 401 - Password doesnt match');
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Passwörter stimmen nicht überein.')));
            break;
          default:
            debugPrint(
                'error: ${dioError.response!.statusCode} - Something went wrong while trying to connect with the server');
            break;
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ein fehler ist aufgetreten.')),
      );
      debugPrint('error: Something went wrong : $e');
    }
  }
}