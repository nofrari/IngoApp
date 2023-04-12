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

## Programm commands
1. npm init --yes
2. npm install express
3. npm i -D typescript @types/express @types/node
4. npx tsc --init
5. npm i prisma --save
6. npx prisma
7. npx prisma init
8. npm install @prisma/client
9. npm i zod
10. npm i bcryrpt
11. npm i --save-dev @types/bcrypt
12. npm i ts-node
13. npm i ts-node-dev
14. npm i jsonwebtoken
15. npm i --save-dev @types/jsonwebtoken
16. npm i --save-dev mocha chai
17. npm i --save-dev @types/mocha @types/chai

## Setup für lokale Datenbank
1. schema.prisma auf mysql ändern
2. Docker installieren https://www.docker.com/products/docker-desktop/
3. "docker pull mysql" ausführen
4. "docker run --name ingo -p 3306:3306 --env MYSQL_ROOT_PASSWORD=dummypasswort -d mysql" ausführen
5. In docker auf den ingo container gehen, terminal öffnen, "mysql -u root -p" ausführen und passwort eingeben"
6. Nacheinander ausführen: "CREATE DATABASE ingodb;" (Side note: ziemlich sicher, dass man nur den ersten braucht) "CREATE USER 'ingouser' IDENTIFIED BY 'dummypasswort';" "GRANT ALL PRIVILEGES ON ingodb.* TO 'ingouser';"
7. sample env auf ".env" umbenennen env database url ändern auf "mysql://root:dummypasswort@localhost:3306/ingodb?schema=public"
8. src/index.ts und src/routes/users.ts von ecampus-beispiel kopieren und jwt zeug rauslöschen
9. in package json "start": "ts-node --transpile-only src/index.ts" als script hinzufügen
10. mit npx prisma db push das schema zur datenbank pushen
11. mit npm run start den server starten
12. postman herunterladen https://www.postman.com/downloads/
13. mit localhost/ testen ob verbindung funktioniert
14. in docker "USE ingodb" eingeben und mit SELECT * from User schauen ob ein post an localhost/users einen user erzeugt

