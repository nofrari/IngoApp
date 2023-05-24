import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/constants/values.dart';
import 'package:frontend/services/profile_service.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';

//import constants

import 'package:frontend/constants/fonts.dart';
import 'package:frontend/widgets/input_fields/input_field.dart';
import 'package:frontend/widgets/button.dart';

import 'package:frontend/start.dart';
import 'package:provider/provider.dart';

class StartAccount extends StatefulWidget {
  const StartAccount({super.key});

  @override
  State<StartAccount> createState() => _StartAccountState();
}

class _StartAccountState extends State<StartAccount> {
  TextInputFormatter letters = FilteringTextInputFormatter.allow(
      RegExp(r"[a-zA-Z0-9#+:'()&/^\-{2}|\s]"));

  TextEditingController controllerTitle = TextEditingController();
  TextEditingController controllerAmount = TextEditingController();

  TextInputType numeric = TextInputType.number;
  TextInputType text = TextInputType.text;

  bool _isFocused = false;
  void onTextFieldFocusChanged(bool isFocused) {
    setState(() {
      _isFocused = isFocused;
    });
  }

  Dio dio = Dio();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: AppColor.backgroundFullScreen,
        body: Container(
          padding: Values.bigCardPadding,
          child: SingleChildScrollView(
            child: Column(
              children: [
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
                    borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(20),
                        bottomRight: Radius.circular(11),
                        bottomLeft: Radius.circular(11)),
                    color: AppColor.backgroundGray,
                  ),
                  child: Form(
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.15,
                            child: Center(
                              child: Text(
                                  "Erstelle dein Startkonto".toUpperCase(),
                                  style: Fonts.text400),
                            ),
                          ),
                          InputField(
                            lblText: "Kontoname",
                            reqFormatter: letters,
                            keyboardType: text,
                            controller: controllerTitle,
                            maxLines: 1,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Das Feld darf nicht leer sein';
                              }
                              return null;
                            },
                            maxLength: 50,
                            onFocusChanged: onTextFieldFocusChanged,
                            hidePassword: false,
                          ),
                          InputField(
                            lblText: "Startkapital (Betrag)",
                            reqFormatter: currencyFormatter,
                            keyboardType: numeric,
                            controller: controllerAmount,
                            maxLines: 1,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Das Feld darf nicht leer sein';
                              }
                              return null;
                            },
                            maxLength: 15,
                            onFocusChanged: onTextFieldFocusChanged,
                            hidePassword: false,
                          ),
                          //(_isFocused == false)
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Button(
                                  btnText: "Startkonto erstellen".toUpperCase(),
                                  onTap: () async {
                                    await _sendData(
                                        controllerTitle.text,
                                        currencyToDouble(
                                            controllerAmount.text));
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const Start(),
                                      ),
                                    );
                                  },
                                  theme: ButtonColorTheme.secondaryLight),
                            ),
                          )
                          //: Container(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future _sendData(String name, double amount) async {
    Map<String, dynamic> formData = {
      "account_name": name,
      "account_balance": amount,
      "user_id": context.read<ProfileService>().getUser().id
    };

    var response =
        await dio.post("${Values.serverURL}/accounts/input", data: formData);
    debugPrint(response.toString());
  }
}
