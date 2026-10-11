-- Referenzloesung. Nach eigenem Versuch verwenden. Nur lesende SELECT-Abfragen.
-- Alle Daten sind synthetisch. Regeln gelten nur fuer dieses Lernprojekt.

-- Gesamtzahl: 100
SELECT COUNT(*) AS total_rows FROM customers_raw;

-- Doppelte ID-Gruppen: 5 Gruppen mit je 2 Zeilen.
SELECT customer_id, COUNT(*) AS occurrences
FROM customers_raw
GROUP BY customer_id
HAVING COUNT(*) > 1
ORDER BY customer_id;

-- R01: 10 betroffene Zeilen
SELECT * FROM customers_raw WHERE customer_id IN (SELECT customer_id FROM customers_raw GROUP BY customer_id HAVING COUNT(*) > 1) ORDER BY source_row;

SELECT COUNT(*) AS affected_rows FROM customers_raw WHERE customer_id IN (SELECT customer_id FROM customers_raw GROUP BY customer_id HAVING COUNT(*) > 1);

-- R02: 5 betroffene Zeilen
SELECT * FROM customers_raw WHERE TRIM(COALESCE(email,'')) = '' ORDER BY source_row;

SELECT COUNT(*) AS affected_rows FROM customers_raw WHERE TRIM(COALESCE(email,'')) = '';

-- R03: 5 betroffene Zeilen
SELECT * FROM customers_raw WHERE COALESCE(country,'') NOT IN ('DE','AT','CH') ORDER BY source_row;

SELECT COUNT(*) AS affected_rows FROM customers_raw WHERE COALESCE(country,'') NOT IN ('DE','AT','CH');

-- R04: 4 betroffene Zeilen
SELECT * FROM customers_raw WHERE order_count IS NULL OR order_count < 0 ORDER BY source_row;

SELECT COUNT(*) AS affected_rows FROM customers_raw WHERE order_count IS NULL OR order_count < 0;

-- R05: 3 betroffene Zeilen
SELECT * FROM customers_raw WHERE TRIM(COALESCE(email,'')) <> '' AND INSTR(email,'@') = 0 ORDER BY source_row;

SELECT COUNT(*) AS affected_rows FROM customers_raw WHERE TRIM(COALESCE(email,'')) <> '' AND INSTR(email,'@') = 0;

-- Uebersicht: Jede Zahl zaehlt Zeilen innerhalb einer Regel.
SELECT 'R01' AS rule_id, COUNT(*) AS affected_rows FROM customers_raw WHERE customer_id IN (SELECT customer_id FROM customers_raw GROUP BY customer_id HAVING COUNT(*) > 1)
UNION ALL
SELECT 'R02' AS rule_id, COUNT(*) AS affected_rows FROM customers_raw WHERE TRIM(COALESCE(email,'')) = ''
UNION ALL
SELECT 'R03' AS rule_id, COUNT(*) AS affected_rows FROM customers_raw WHERE COALESCE(country,'') NOT IN ('DE','AT','CH')
UNION ALL
SELECT 'R04' AS rule_id, COUNT(*) AS affected_rows FROM customers_raw WHERE order_count IS NULL OR order_count < 0
UNION ALL
SELECT 'R05' AS rule_id, COUNT(*) AS affected_rows FROM customers_raw WHERE TRIM(COALESCE(email,'')) <> '' AND INSTR(email,'@') = 0;

-- Verschiedene betroffene Zeilen ueber alle Regeln: 27
SELECT COUNT(*) AS distinct_affected_rows FROM customers_raw
WHERE (customer_id IN (SELECT customer_id FROM customers_raw GROUP BY customer_id HAVING COUNT(*) > 1))
   OR (TRIM(COALESCE(email,'')) = '')
   OR (COALESCE(country,'') NOT IN ('DE','AT','CH'))
   OR (order_count IS NULL OR order_count < 0)
   OR (TRIM(COALESCE(email,'')) <> '' AND INSTR(email,'@') = 0);

-- Normalisierungsvorschlag. Rohdaten unveraendert lassen.
-- Mapping-Tabelle wurde fuer die Uebung fachlich vorgegeben.
SELECT c.source_row, c.customer_id, c.country AS original_country,
       m.standard_country AS proposed_country,
       CASE WHEN m.standard_country IS NULL THEN 'Klaerung notwendig'
            WHEN c.country <> m.standard_country THEN 'Normalisieren'
            ELSE 'Unveraendert' END AS action
FROM customers_raw AS c
LEFT JOIN country_mapping AS m ON c.country = m.raw_country
ORDER BY c.source_row;

-- 3 bekannte Schreibweisen normalisieren, 2 Faelle bleiben ungeklaert.
SELECT COUNT(*) AS unresolved_country_rows
FROM customers_raw AS c
LEFT JOIN country_mapping AS m ON c.country = m.raw_country
WHERE m.standard_country IS NULL;
