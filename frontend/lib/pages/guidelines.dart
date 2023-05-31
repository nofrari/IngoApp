import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/constants/fonts.dart';
import 'package:frontend/constants/strings.dart';
import 'package:frontend/widgets/header.dart';

class Guidelines extends StatelessWidget {
  const Guidelines({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          appBar: Header(
            onTap: () {
              Navigator.pop(context);
            },
            element: Text(
              Strings.profileGuidelines.toUpperCase(),
              style: Fonts.textHeadingBold,
            ),
          ),
          backgroundColor: AppColor.backgroundFullScreen,
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: SingleChildScrollView(
              child: Text(
                "Willkommen bei unserer Finanz-App. Diese App wird von INGO bereitgestellt und ermöglicht es Benutzern, ihre Finanzen zu verwalten, Transaktionen durchzuführen und auf Finanzinformationen zuzugreifen. \nIndem Sie diese App nutzen, stimmen Sie diesen Nutzungsbedingungen und Datenschutzrichtlinien zu. Bitte lesen Sie diese sorgfältig durch, bevor Sie die App nutzen. \nNutzungsbedingungen:\nDiese App ist nur für den persönlichen Gebrauch bestimmt und darf nicht für kommerzielle Zwecke genutzt werden.\nSie sind für die Sicherheit Ihres Kontos verantwortlich und müssen sicherstellen, dass Ihre Anmeldeinformationen sicher aufbewahrt werden.\nWir behalten uns das Recht vor, den Zugang zur App jederzeit zu beschränken oder zu beenden, wenn wir feststellen, dass gegen diese Nutzungsbedingungen verstoßen wurde.\nWir sind nicht für Verluste oder Schäden verantwortlich, die durch die Nutzung dieser App entstehen.",
                textAlign: TextAlign.center,
                style: Fonts.guidelines,
              ),
            ),
          )),
    );
  }
}
