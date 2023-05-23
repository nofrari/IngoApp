class Strings {
  // Strings._() = private constructor --> prevents Class from being instantiated
  Strings._();
  static const String menuHome = "Home";
  static const String menuBudget = "Budget";
  static const String menuFinance = "Finanzen";
  static const String menuAccounts = "Accounts";

//General
  static const String abort = "ABBRECHEN";
  static const String confirm = "FORTFAHREN";

  //Dropdown
  static const String dropdownBudget = "Budget für";
  static const String dropdownFurtherCategory = "Weitere Kategorie auswählen";
  static const String dropdownTypeCategory = "Typ";
  static const String dropdownCategory = "Kategorie";
  static const String dropdownFrequency = "Wiederholen";
  static const String dropdownAccount1 = "Ausgangskonto";
  static const String dropdownAccount2 = "Zu Konto Transferieren";
  static const String dropdownFinancesAccount = "Konto";
  static const String dropdownFinancesCategories = "Kategorie";

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

  //Accounts
  static const String accountsHeading = "KONTENÜBERSICHT";
  static const String accountsButton = "KONTO HINZUFÜGEN";
  static const String accountsDelete = "KONTO LÖSCHEN";

  //Profile
  static const String profileAccount = "KONTO";
  static const String profileName = "NAME";
  static const String profileMail = "E-MAIL";
  static const String profileManage = "VERWALTUNG";
  static const String profileMore = "MEHR";
  static const String profileCategory = "Kategorien";
  static const String profileTransactions = "Wiederkehrende Transaktionen";
  static const String profileGuidelines = "Richtlinien";
  static const String profileDataprotection = "Datenschutzerklärung";
  static const String profileLogout = "ABMELDEN";
  static const String profileEdit = "PROFIL BEARBEITEN";
  static const String profileDelete = "KONTO LÖSCHEN";
  static const String profileEditPassword = "PASSWORT ÄNDERN";
  static const String profileOldPassword = "Altes Passwort";
  static const String profileNewPassword = "Neues Passwort";
  static const String profileNewPassword2 = "Neues Passwort wiederholen";
  static const String profileSave = "Speichern";

  //Transactions
  static const String transactionsReoccuringHeading =
      "Wiederkehrende\nTransaktionen";
  static const String transactionsAdd = "Transaktion hinzuügen";
}
