# Code Conventions

## Variablen
- Englisch
- camelCase
- zwischen Deklarationen keine Leerzeilen

## Funktionen
- camelCase
- Klammer in der selben Zeile aufmachen
- Klammern in selber Zeile schließen wie aufgemacht
- innerhalb von Funktionen eine Leerzeile, zwischen Funktionen 2 Leerzeilen

## String / Konstanten
- UPPERCASE
- in eigenem lang file

## Kommentare
- Englisch
- Darüber kommentieren
- "FixMe" für fehlerhafte Funktionalitäten

## Files benennen:
- wird noch entschieden (learning by doing)

## Klassen
- PascalCase

## Git
- Summary: If you pull, this commit will...
- Erlaubte Verben in Summary:
    * Add: Programmierer/USer kann jetzt etwas machen was man vorher nicht konnte
    * Fix: Bug wurde gefixed
    * Edit: Etwas wurde geändert, das in die andren Kategorien nicht passt :D
    * Remove/Drop: Programmierer/User kann etwas nicht mehr machen was vorher ging
    * Refactor: Es wurde etwas verändert, was Experience nicht verändert
    * Document: Was kommentiert, was ins README, was ins CHANGELOG
    * Redraw/Relayout: Designarbeit, Farbe geändert, Layoutgeändert
    * Optimize: Code wurde schneller gemacht
    * Formatting: Code wurde schöner gemacht

- Branches
    * main: stable build
    * dev: wird idealerweise zu Sprintende in den main gemerged
    * feature: für einzelne Features wie zB Scanner
    * "offline rumpfusch branches": lokale Branches die nicht hochgeladen werden, sondern immer wenn sie "fertig" sind in den feature branch mergen und den dann pushen


# Setup Entwicklungsumgebung

## Visual Studio
- Flutter Extention installieren
- Unter File > Preferences > Settings:
    * Format on Save aktivieren
    * Editor: Tab Size 4

## Flutter Setup Windows
1. Download SDK https://docs.flutter.dev/get-started/install/windows
2. Den Ordner entpacken und dann den Pfad zu Flutter/bin kopieren
3. In der Suche "env" eingeben, auf "Umgebungsvariablen" klicken, dann "Path" auswählen und auf bearbeiten, dann auf Neu und den kopierten Pfad einfügen

## Android Studio
1. Download Android Studio https://developer.android.com/studio?gclid=CjwKCAjw5dqgBhBNEiwA7PryaDp3iobEElUQNejkYfuenjy1r9zsPfH_0quwyFSSsRB_u0fxDfpn1xoCYKIQAvD_BwE&gclsrc=aw.ds
2. Beim Setup Wizard die Standardeinstellungen verwenden
3. Unter "Costumize" > all Settings nach "SDK" suchen, in der Naviagtion auf "Andriod SDK" klicken, Tab zu "SDK Tools" wechseln und "Android SDK Command-line Tools" installieren
4. Dann unter Projects > more Actions > Virtual Device Manager ein Emulator hinzufügen
5. Pixel 5 auswählen, System-Image "R" herunterladen und Emulator starten
6. In der commandline zum \flutter ordner navigieren und "flutter doctor" ausführen
7. "flutter doctor --android-licenses" ausführen und alles bestätigen

# Setup Backend

## Server Verbindung
### Putty (nur bei Windows benötigt, Linux/MacOS geht glaub ich über terminal)
1. Putty herunterladen https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html
2. PuttyGEN öffnen und "RSA" auswählen, bit-Länge auf 4096 und generate
3. Save public key, irgendeinen Ordner auswählen und "public" als Namen vergeben, ohne Dateiendung
4. Save private key, Passwort braucht man nicht

### jetzt wieder für alle
1. Zu jemanden gehen der SSH Verbindungen bereits eingerichtet hat
2. Am Server ins Directory /root/.ssh/ gehen und in authorized_keys den OpenSSH public key aus puttyGEN kopieren
3. Download mobaXterm https://mobaxterm.mobatek.net/download-home-edition.html
4. Entpacken und .exe öffnen
5. Auf "Session" und auf "user Session", dann IP adresse und "root" eingeben
6. Unter Advanced den private key auswählen
7. Auf Verbinden und fertig

## Nach erstem Repo Pull

### Programm commands
1. npm init --yes
2. npm install express
3. npm i -D typescript @types/express @types/node
4. npx tsc --init
5. npm i prisma --save
6. npx prisma
7. npx prisma init
8. npm install @prisma/client
9. npm i zod
10. npm i bcrypt
11. npm i --save-dev @types/bcrypt
12. npm i ts-node
13. npm i ts-node-dev
14. npm i jsonwebtoken
15. npm i --save-dev @types/jsonwebtoken
16. npm i --save-dev mocha chai
17. npm i --save-dev @types/mocha @types/chai
18. npm i mindee
19. npm i multer
20. npm i --save-dev @types/multer

### Setup für lokale Datenbank
1. schema.prisma auf mysql ändern
2. Docker installieren https://www.docker.com/products/docker-desktop/
3. "docker pull mysql" ausführen
4. "docker run --name ingo -p 3306:3306 --env MYSQL_ROOT_PASSWORD=dummypasswort -d mysql" ausführen --> es muss Port 3306 sein!
5. In docker auf den ingo container gehen, terminal öffnen, "mysql -u root -p" ausführen und passwort eingeben"
6. Nacheinander ausführen: "CREATE DATABASE ingodb;"
7. sample env auf ".env" umbenennen env database url ändern auf "mysql://root:dummypasswort@localhost:3306/ingodb?schema=public"
10. mit npx prisma db push das schema zur datenbank pushen
11. mit npm run start den server starten
12. postman herunterladen https://www.postman.com/downloads/
13. mit localhost/ testen ob verbindung funktioniert
14. in docker "USE ingodb" eingeben und mit SELECT * from User schauen ob ein post an localhost/users einen user erzeugt

## Code auf Server laden
1. in scanner.dart "http://10.0.2.2:3000/upload" auf "https://data.ingoapp.at/upload" ändern
2. Falls die .env kopiert werden muss, in der DATABASE_URL root auf ingouser ändern
3. Backup der Ordnerstruktur am Server machen
4. prisma ordner, src ordner, package-lock.json, package.json, eventuell .env, tsconfig.json auf den Server kopieren und Dateien überschreiben
5. pm2 restart node-server ausführen

## Datenbank statements
INSERT INTO `Type` VALUES ("1", "Einnahme");
INSERT INTO `Type` VALUES ("2", "Ausgabe");
INSERT INTO `Type` VALUES ("3", "Transfer");

INSERT INTO `Interval` VALUES ("1", "Nie");
INSERT INTO `Interval` VALUES ("2", "Wöchentlich");
INSERT INTO `Interval` VALUES ("3", "Monatlich");
INSERT INTO `Interval` VALUES ("4", "Quartalsweise");
INSERT INTO `Interval` VALUES ("5", "Halbjährlich");
INSERT INTO `Interval` VALUES ("6", "Jährlich");

INSERT INTO `IntervalSubtype` VALUES ("1", "Tag");
INSERT INTO `IntervalSubtype` VALUES ("2", "Wochentag");

INSERT INTO `Icon` VALUES ("1", "gift");
INSERT INTO `Icon` VALUES ("2", "dollarSign");
INSERT INTO `Icon` VALUES ("3", "train");
INSERT INTO `Icon` VALUES ("4", "babyCarriage");
INSERT INTO `Icon` VALUES ("5", "shoppingBag");
INSERT INTO `Icon` VALUES ("6", "suitcase");
INSERT INTO `Icon` VALUES ("7", "scissors");
INSERT INTO `Icon` VALUES ("8", "eating");
INSERT INTO `Icon` VALUES ("9", "car");
INSERT INTO `Icon` VALUES ("10", "baby");
INSERT INTO `Icon` VALUES ("11", "shirt");
INSERT INTO `Icon` VALUES ("12", "plane");
INSERT INTO `Icon` VALUES ("13", "paw");
INSERT INTO `Icon` VALUES ("14", "parking");
INSERT INTO `Icon` VALUES ("15", "music");
INSERT INTO `Icon` VALUES ("16", "dumbbell");
INSERT INTO `Icon` VALUES ("17", "driking");
INSERT INTO `Icon` VALUES ("18", "wine");
INSERT INTO `Icon` VALUES ("19", "beer");
INSERT INTO `Icon` VALUES ("20", "smoking");
INSERT INTO `Icon` VALUES ("21", "graduation");
INSERT INTO `Icon` VALUES ("22", "home");
INSERT INTO `Icon` VALUES ("23", "phone");
INSERT INTO `Icon` VALUES ("24", "people");
INSERT INTO `Icon` VALUES ("25", "amazon");
INSERT INTO `Icon` VALUES ("26", "spotify");
INSERT INTO `Icon` VALUES ("27", "video");
INSERT INTO `Icon` VALUES ("28", "book");
INSERT INTO `Icon` VALUES ("29", "gasPump");
INSERT INTO `Icon` VALUES ("30", "coffee");
INSERT INTO `Icon` VALUES ("31", "wrench");
INSERT INTO `Icon` VALUES ("32", "medical");
INSERT INTO `Icon` VALUES ("33", "running");
INSERT INTO `Icon` VALUES ("34", "swimming");
INSERT INTO `Icon` VALUES ("35", "shoppingCart");
INSERT INTO `Icon` VALUES ("36", "star");


INSERT INTO `Color` VALUES ("1", "blueDark");
INSERT INTO `Color` VALUES ("2", "blueLight");
INSERT INTO `Color` VALUES ("3", "yellowDark");
INSERT INTO `Color` VALUES ("4", "greenLight");
INSERT INTO `Color` VALUES ("5", "greenAcid");
INSERT INTO `Color` VALUES ("6", "redDark");
INSERT INTO `Color` VALUES ("7", "pink");
INSERT INTO `Color` VALUES ("8", "orange");
INSERT INTO `Color` VALUES ("9", "violett");
INSERT INTO `Color` VALUES ("10", "greenKadmium");
INSERT INTO `Color` VALUES ("11", "greenNavy");
INSERT INTO `Color` VALUES ("12", "gray");
