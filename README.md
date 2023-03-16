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

## SCSS
- nach BEM

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