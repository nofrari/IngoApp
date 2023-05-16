class Strings {
  // Strings._() = private constructor --> prevents Class from being instantiated
  Strings._();
  static const String menuHome = "Home";
  static const String menuBudget = "Budget";
  static const String menuFinance = "Finanzen";
  static const String menuAccounts = "Accounts";

  //Dropdown
  static const String dropdownBudget = "Budget für";
  static const String dropdownFurtherCategory = "Weitere Kategorie auswählen";
  static const String dropdownTypeCategory = "Typ";
  static const String dropdownCategory = "Kategorie";
  static const String dropdownFrequency = "Wiederholen";
  static const String dropdownAccount1 = "Ausgangskonto";
  static const String dropdownAccount2 = "Zu Konto Transferieren";

  //Registrieren / Login
  static const String registerFirstName = "Vorname";
  static const String registerLastName = "Nachname";
  static const String registerMail = "E-Mail";
  static const String registerPassword = "Passwort";
  static const String registerPasswordRepeat = "Passwort wiederholen";
  static const String registerDataProtection =
      "Ich stimme der Datenschutzerklärung zu";

  static const String alertInputfieldEmpty = "Dieses Feld darf nicht leer sein";
  static const String alertMail = "Dies ist keine gültige Mailadresse";
  static const String alertPasswordWrong = "Passwort stimmt nicht überein";
  static const String alertDataProtectionEmpty =
      "Datenschutzerklärung muss akzeptiert werden";
  static const String passwordForgot = "Passwort vergessen?";
  static const String passwordForgotInfo =
      "Gib hier die E-Mail Adresse ein, um dein Passwort zurückzusetzen.";
  static const String passwordForgotPopup =
      "Passwort zurücksetzen wurde angefordert \n \n Wir haben dir gerade eine E-Mail mit einem Link zum Zurücksetzen gesendet. Bitte prüfe deine E-Mail und folge den Anweisungen.";
  static const String notRegistered = "Noch nicht registriert? Klicke hier";

  //Buttons
  static const String btnRegister = "Registrieren";
  static const String btnLogin = "Anmelden";
  static const String btnPasswordReset = "Passwort zurücksetzen";
  static const String btnBackToLogin = "Zurück zur Anmeldung";
}
