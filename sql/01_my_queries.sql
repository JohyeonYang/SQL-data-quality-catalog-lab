-- Mein Lernprojekt: Datenqualitaet mit SQLite
-- Datum: TODO
-- Erst selbst bearbeiten, danach reference/solutions.sql vergleichen.
-- Jede Abfrage einzeln ausfuehren und das Ergebnis notieren.

-- Einstieg: Wie viele Quelldatensaetze gibt es?
SELECT COUNT(*) AS total_rows FROM customers_raw;

-- R01: Welche customer_id kommt mehrfach vor?
-- Nutze GROUP BY customer_id, COUNT(*) und HAVING COUNT(*) > 1.

SELECT customer_id, COUNT(*) AS occurrences
FROM customers_raw
GROUP BY customer_id
HAVING COUNT(*) > 1
ORDER BY customer_id;

-- Ergebnis: 5 Zeilen , mehrfach vorkommende customer_ids und Anzahl der Duplikate

SELECT *
FROM customers_raw
WHERE customer_id IN (
    SELECT customer_id
    FROM customers_raw
    GROUP BY customer_id
    HAVING COUNT(*) > 1
)
ORDER BY customer_id, source_row;

-- Ergebnis: 10 Zeilen mit 5 mehrfach vorkommenden customer_id-Werten.
-- Alle Spalten dieser Zeilen werden zum Vergleich angezeigt.


-- R02: Welche E-Mail fehlt, auch wenn nur Leerzeichen gespeichert sind?
-- Nutze TRIM, COALESCE und eine WHERE-Bedingung.

SELECT source_row, customer_id, email
FROM customers_raw
WHERE TRIM(COALESCE(email, '')) = ''
ORDER BY source_row;

-- Ergebnis: 5 Zeilen mit fehlender E-Mail.
-- Betroffene source_row: 10, 20, 30, 40, 50.

-- R03: Welche Laenderwerte sind nicht exakt DE, AT oder CH?

SELECT source_row, customer_id, country
FROM customers_raw
WHERE country IS NULL
   OR country NOT IN ('DE', 'AT', 'CH')
ORDER BY source_row;

-- Ergebnis: 5 Zeilen mit fehlendem oder nicht erlaubtem Laenderwert.
-- Betroffene source_row: 7, 17, 27, 37, 47.

-- R04: Welche order_count ist NULL oder kleiner als 0? 0 ist erlaubt.

SELECT source_row, customer_id, order_count
FROM customers_raw
WHERE order_count IS NULL
   OR order_count < 0
ORDER BY source_row;

-- Ergebnis: 4 Zeilen mit fehlender oder negativer order_count.
-- Betroffene source_row: 8, 18, 28, 38.
-- Der Wert 0 ist erlaubt und wird nicht als Fehler markiert.

-- R05: Welche nicht leere E-Mail enthaelt kein @?
-- Dies ist nur eine einfache Plausibilitaetspruefung.

SELECT source_row, customer_id, email
FROM customers_raw
WHERE TRIM(COALESCE(email, '')) <> ''
  AND email NOT LIKE '%@%'
ORDER BY source_row;

-- Ergebnis: 3 nicht leere E-Mail-Werte ohne @.
-- Betroffene source_row: 12, 24, 36.
-- Diese Regel prueft nur das Vorhandensein von @.

-- Uebung : LEFT JOIN mit country_mapping. Originalwert und Vorschlag anzeigen.
-- Fehlende Zuordnung als NULL behalten, kein Land raten.

SELECT
    c.source_row,
    c.customer_id,
    c.country AS original_country,
    m.standard_country AS suggested_country
FROM customers_raw AS c
LEFT JOIN country_mapping AS m
    ON c.country = m.raw_country
ORDER BY c.source_row;

-- Ergebnis: 100 Zeilen mit Originalwert und Standardisierungsvorschlag.
-- Bei 2 Zeilen fehlt eine Zuordnung: source_row 37 und 47.

-- Eigene Erweiterung R06: Fehlender Firmenname.
-- Annahme: company_name ist ein Pflichtfeld.
-- NULL, leere Zeichenketten und reine Leerzeichen gelten als Fehler.

SELECT source_row, customer_id, company_name
FROM customers_raw
WHERE TRIM(COALESCE(company_name, '')) = ''
ORDER BY source_row;

-- Ergebnis im Quelldatensatz: 0 Zeilen mit fehlendem Firmennamen.