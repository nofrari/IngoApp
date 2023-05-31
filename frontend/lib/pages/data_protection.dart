import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/constants/fonts.dart';
import 'package:frontend/constants/strings.dart';
import 'package:frontend/widgets/header.dart';

class DataProtection extends StatelessWidget {
  const DataProtection({super.key});

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
              Strings.profileDataprotection.toUpperCase(),
              style: Fonts.textHeadingBold,
            ),
          ),
          backgroundColor: AppColor.backgroundFullScreen,
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: SingleChildScrollView(
              child: Text(
                "In folgender Datenschutzerklaerung informieren wir Sie ueber die wichtigsten Aspekte der Datenverarbeitung im Rahmen unserer Webseite. Wir erheben und verarbeiten personenbezogene Daten nur auf Grundlage der gesetzlichen Bestimmungen (Datenschutzgrundverordnung, Telekommunikationsgesetz 2003). \n Sobald Sie als Benutzer auf unsere Webseite zugreifen oder diese besuchen wird Ihre IP-Adresse, Beginn sowie Beginn und Ende der Sitzung erfasst. Dies ist technisch bedingt und stellt somit ein berechtigtes Interesse iSv Art 6 Abs 1 lit f DSGVO. \n \nKontakt mit uns \n Wenn Sie uns, entweder ueber unser Kontaktformular auf unserer Webseite, oder per Email kontaktieren, dann werden die von Ihnen an uns uebermittelten Daten zwecks Bearbeitung Ihrer Anfrage oder fuer den Fall von weiteren Anschlussfragen fuer sechs Monate bei uns gespeichert. Es erfolgt, ohne Ihre Einwilligung, keine Weitergabe Ihrer uebermittelten Daten.\n \n Cookies \n Unsere Website verwendet so genannte Cookies. Dabei handelt es sich um kleine Textdateien, die mit Hilfe des Browsers auf Ihrem Endgeraet abgelegt werden. Sie richten keinen Schaden an. Wir nutzen Cookies dazu, unser Angebot nutzerfreundlich zu gestalten. Einige Cookies bleiben auf Ihrem Endgeraet gespeichert, bis Sie diese loeschen. Sie ermoeglichen es uns, Ihren Browser beim naechsten Besuch wiederzuerkennen. Wenn Sie dies nicht wuenschen, so koennen Sie Ihren Browser so einrichten, dass er Sie ueber das Setzen von Cookies informiert und Sie dies nur im Einzelfall erlauben. Bei der Deaktivierung von Cookies kann die Funktionalitaet unserer Website eingeschraenkt sein.\n \nGoogle Fonts \nUnsere Website verwendet Schriftarten von 'Google Fonts'. Der Dienstanbieter dieser Funktion ist:\n\nGoogle Ireland Limited Gordon House, Barrow Street Dublin 4. Ireland \nTel: +353 1 543 1000 \n\nBeim Aufrufen dieser Webseite laedt Ihr Browser Schriftarten und speichert diese in den Cache. Da Sie, als Besucher der Webseite, Daten des Dienstanbieters empfangen kann Google unter Umstaenden Cookies auf Ihrem Rechner setzen oder analysieren.\n\nDie Nutzung von 'Google-Fonts_ dient der Optimierung unserer Dienstleistung und der einheitlichen Darstellung von Inhalten. Dies stellt ein berechtigtes Interesse im Sinne von Art. 6 Abs. 1 lit. f DSGVO dar.\n\nServer-Log Files \nDiese Webseite und der damit verbundene Provider erhebt im Zuge der Webseitennutzung automatisch Informationen im Rahmen sogenannter 'Server-Log Files'. Dies betrifft insbesondere:\n\nIP-Adresse oder Hostname\nden verwendeten Browser\nAufenthaltsdauer auf der Webseite sowie Datum und Uhrzeit\naufgerufene Seiten der Webseite\nSpracheinstellungen und Betriebssystem\n'Leaving-Page' (auf welcher URL hat der Benutzer die Webseite verlassen)\nISP (Internet Service Provider)\nDiese erhobenen Informationen werden nicht personenbezogen verarbeitet oder mit personenbezogenen Daten in Verbindung gebracht.\n\n\nDer Webseitenbetreiber behaelt es sich vor, im Falle von Bekanntwerden rechtswidriger Taetigkeiten, diese Daten auszuwerten oder zu ueberpruefen.\n\nIhre Rechte als Betroffener\nSie als Betroffener haben bezueglich Ihrer Daten, welche bei uns gespeichert sind grundsaetzlich ein Recht auf:\n\nAuskunft\nLoeschung der Daten\nBerichtigung der Daten\nuebertragbarkeit der Daten\nWiederruf und Widerspruch zur Datenverarbeitung\nEinschraenkung\nWenn sie vermuten, dass im Zuge der Verarbeitung Ihrer Daten Verstoesse gegen das Datenschutzrecht passiert sind, so haben Sie die Moeglichkeit sich bei uns (office@ingoapp.at) oder der Datenschutzbehoerde zu beschweren.\n\nSie erreichen uns unter folgenden Kontaktdaten:\nWebseitenbetreiber: INGO\nWebseite: ingoapp.at\nEmail: office@ingoapp.at\n\n",
                textAlign: TextAlign.center,
                style: Fonts.guidelines,
              ),
            ),
          )),
    );
  }
}
