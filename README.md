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
3. Dann unter Projects > more Actions > Virtual Device Manager ein Emulator hinzufügen
4. Pixel 5 auswählen, System-Image "R" herunterladen und Emulator starten
5. In der commandline zum \flutter ordner navigieren und "flutter doctor" ausführen
6. "flutter doctor --android-licenses" ausführen und alles bestätigen