import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../constants/colors.dart';
import '../../constants/fonts.dart';
import '../../constants/strings.dart';
import '../../constants/values.dart';
import '../../models/user.dart';
import '../../services/profile_service.dart';
import '../../widgets/button.dart';
import '../../widgets/header.dart';
import '../userauth.dart';

class DeleteProfile extends StatefulWidget {
  const DeleteProfile({super.key});

  @override
  State<DeleteProfile> createState() => _DeleteProfileState();
}

class _DeleteProfileState extends State<DeleteProfile> {
  User user = User(id: "", firstName: " ", lastName: " ", email: " ");

  Dio dio = Dio();

  @override
  void initState() {
    super.initState();
    setState(() {
      user = context.read<ProfileService>().getUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: Header(
          element: Text(
            Strings.profileDelete,
            style: Fonts.textHeadingBold,
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: AppColor.backgroundFullScreen,
        body: Column(mainAxisSize: MainAxisSize.min, children: [
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
          Expanded(
            child: Container(
              margin: Values.bigCardMargin,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Möchtest du dein Konto wirklich löschen?".toUpperCase(),
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
                                await context.read<ProfileService>().setUser(
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
                                print("funktioniert");
                              } catch (e) {
                                debugPrint(e.toString());
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      behavior: SnackBarBehavior.floating,
                                      content:
                                          Text('Ein Fehler ist aufgetreten.')),
                                );
                              }
                            },
                            theme: ButtonColorTheme.secondaryDark),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
