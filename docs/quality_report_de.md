# Datenqualitaetspruefung: synthetische Kundendaten

- Status: Pruefergebnisse dokumentiert; Korrekturvorschlaege noch nicht umgesetzt.
- Bearbeitet von: JohyeonYang
- Datum: 2026-10-11

## Ziel und Daten

Ziel dieses Lernprojekts ist es, Datenqualitaetsprobleme zu erkennen, mit SQL und Excel zu vergleichen und nachvollziehbar zu dokumentieren.
Geprueft wurden 100 synthetische Kundendatensaetze aus `data/customers_raw.csv` bzw. der Tabelle `customers_raw` in `data/data_quality.sqlite` mit SQLite und Excel.

## Festgestellte Auffaelligkeiten

| Regel | Betroffene Zeilen | Beispiel | Moegliche Auswirkung |
|---|---:|---|---|
| R01: Doppelte customer_id | 10 | Fuenf IDs kommen jeweils zweimal vor, z. B. C0005 in source_row 5 und 96. | Kunden koennten mehrfach gezaehlt oder Informationen falsch zugeordnet werden. |
| R02: E-Mail fehlt | 5 | Vier NULL-Werte und ein Wert mit nur Leerzeichen, z. B. source_row 30. | Eine Kontaktaufnahme per E-Mail waere nicht moeglich. |
| R03: Land nicht exakt DE, AT oder CH | 5 | Germany, Deutschland, `" DE "`, XX und NULL. | Laenderauswertungen koennten unvollstaendig oder uneinheitlich sein. |
| R04: order_count fehlt oder ist negativ | 4 | Drei negative Werte und ein NULL-Wert, z. B. -1 in source_row 8. | Summen und Durchschnittswerte koennten irrefuehrend sein. |
| R05: Nicht leere E-Mail ohne @ | 3 | `customer12.example.invalid` in source_row 12. | Die Adresse ist bereits nach dieser einfachen Formatpruefung auffaellig. |

Bei R01 sind **10 betroffene Datenzeilen** zu unterscheiden von **5 mehrfach vorkommenden IDs**.
Ein `order_count` von 0 ist erlaubt und wird bei R04 nicht als Fehler gezaehlt.

## Korrekturvorschlag

Die Laenderwerte Germany, Deutschland und `" DE "` koennen anhand der bereitgestellten Tabelle `country_mapping` auf DE vereinheitlicht werden.
Der LEFT JOIN zeigt dazu den Originalwert und den Vorschlag in getrennten Spalten an.

Fuer XX und NULL gibt es keine Zuordnung. Diese beiden Faelle bleiben zur fachlichen Klaerung offen; ein Land wird nicht geraten.
Die Rohdaten bleiben unveraendert. Die Abfrage zeigt Vorschlaege an und fuehrt kein UPDATE aus.

Mehrfach vorkommende Kunden-IDs sollten vor einer Loeschung oder Zusammenfuehrung fachlich geklaert werden.
Fehlende E-Mail-Adressen und fehlende oder negative Bestellanzahlen sollten ebenfalls anhand der Quelle geklaert werden; fehlende Bestellanzahlen werden nicht pauschal durch 0 ersetzt.

## Validierung

Die gespeicherten Excel-Ergebnisse im Blatt `Uebungen` von `data-quality-workbook.xlsm` stimmen mit den SQL-Ergebnissen ueberein:

| Regel | Excel: betroffene Zeilen | SQL: betroffene Zeilen |
|---|---:|---:|
| R01 | 10 | 10 |
| R02 | 5 | 5 |
| R03 | 5 | 5 |
| R04 | 4 | 4 |
| R05 | 3 | 3 |

Auch die markierten Datensaetze im Blatt `Kundendaten` stimmen anhand von `source_row` mit den SQL-Treffern ueberein.

Fuer die Laendernormalisierung ergibt sich folgender Vorher-/Vorschlagsvergleich:

| source_row | Originalwert | Vorgeschlagener Wert | Bewertung |
|---|---|---|---|
| 7 | Germany | DE | Zuordnung vorhanden |
| 17 | Deutschland | DE | Zuordnung vorhanden |
| 27 | `" DE "` | DE | Zuordnung vorhanden |
| 37 | XX | NULL | Klaerung notwendig |
| 47 | NULL | NULL | Klaerung notwendig |

Die Anfuehrungszeichen bei `" DE "` machen die Leerzeichen sichtbar und gehoeren nicht zum gespeicherten Wert.
Bei Umsetzung der drei bekannten Zuordnungen in einer separaten bereinigten Fassung wuerde die Zahl der R03-Auffaelligkeiten von 5 auf 2 sinken.
Dies ist ein erwartetes Ergebnis, kein bereits ausgefuehrter Bereinigungsschritt; im unveraenderten Rohdatensatz bleiben es 5.
Eine vollstaendige Bereinigung wurde nicht durchgefuehrt.

## Eigener Beitrag und Grenzen

Ich habe die SQL-Abfragen mit Unterstuetzung ergaenzt und ausgefuehrt, Ergebnisse als Kommentare festgehalten und die Excel-Pruefungen auf alle 100 Zeilen angewendet.
Zusaetzlich habe ich das Datenwoerterbuch und den Dateikatalog ergaenzt.

Als weitere Uebungsregel wurde R06 aufgenommen: `company_name` gilt als Pflichtfeld und darf weder NULL noch leer sein oder nur aus Leerzeichen bestehen.
Im vorhandenen Datensatz findet diese Abfrage 0 auffaellige Zeilen.
Die zwei Fehlerfaelle und das Gegenbeispiel fuer R06 sind noch nicht als Testabfragen in `sql/01_my_queries.sql` dokumentiert.

Die E-Mail-Pruefung R05 kontrolliert nur das Vorhandensein von @, nicht die vollstaendige Syntax oder Erreichbarkeit.
R04 prueft fehlende und negative Werte, aber nicht gesondert Texte oder Dezimalzahlen.
Die Ursache der mehrfach vorkommenden IDs und die sachlich richtigen Ersatzwerte lassen sich aus diesen synthetischen Daten allein nicht bestimmen.

Das Projekt basiert auf bereitgestellten Vorlagen und Testdaten.
KI-Unterstuetzung (ChatGPT) wurde fuer Erklaerungen, SQL-Abfragen, Excel-Formeln und die Formulierung dieses Berichts genutzt.
Einzelfaelle lassen sich ueber `source_row` in den Rohdaten und den SQL-Ergebnissen zur manuellen Nachpruefung auffinden.

