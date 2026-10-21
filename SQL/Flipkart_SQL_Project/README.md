# Flipkart Analytics - SQL Project (MySQL 8+)

A complete SQL project built from the SQL Daily Questions document. One database,
sample data, and 11 scripts that cover every topic from SELECT to triggers.
Tested end to end (MariaDB 10.11 / MySQL 8 syntax).

## How to run

```bash
cd Flipkart_SQL_Project
mysql -u root -p < run_all.sql          # builds schema, data, views, procedures, triggers
mysql -u root -p < 03_basic_queries.sql # then run any query module you want
```

In MySQL Workbench: open each file and run it in the order of the numbers.
Procedures and triggers need the mysql client or Workbench (they use `DELIMITER`).

## Files and topics covered

| File | Topics |
|------|--------|
| 01_schema.sql | Database, 7 tables, primary and foreign keys, defaults |
| 02_sample_data.sql | Realistic data with deliberate gaps (customers with no orders, orphan delivery, unreviewed products) |
| 03_basic_queries.sql | SELECT, aliases, comments, LIKE, BETWEEN, IN, DISTINCT, ORDER BY, LIMIT, Search and Filter Engine, Top Products Dashboard |
| 04_aggregation.sql | COUNT, SUM, AVG, MIN, MAX, GROUP BY, HAVING, Business Summary Report |
| 05_joins.sql | INNER, LEFT, RIGHT, FULL (simulated), SELF, CROSS joins, orphan records, Data Quality Audit, Customer Coverage Report |
| 06_union_subqueries.sql | UNION, UNION ALL, User Directory, scalar / correlated / derived subqueries, IN, EXISTS, ANY, ALL, all 20 extra questions |
| 07_cte_window_ranking.sql | CTEs, recursive CTE, KPI layer, window functions, ROW_NUMBER, RANK, DENSE_RANK, Top-N per group |
| 08_date_string_case.sql | Date functions, recency analysis, string cleaning, CASE WHEN, segmentation, scorecards |
| 09_views_indexes.sql | Views, reporting layer, secure view, KPI view, indexes, EXPLAIN, query optimization |
| 10_procedures_triggers.sql | Stored procedures (IN, OUT, IF), all 18 trigger practicals, audit and reward automation, test block |
| 11_final_reports.sql | 10 management reports that combine every topic |
| run_all.sql | Builds the whole project in order |

## Tables

customers, sellers, products, orders, deliveries, reviews, employees
(plus log tables created in script 10).

## Notes

- Order dates are generated relative to today, so "last 15 days" and recency queries always return rows.
- The trigger test block runs inside a transaction and rolls back, so your data stays unchanged.
- Statements that are meant to be blocked by triggers are commented out. Run them one at a time to see the error messages.
- Thresholds (fast delivery = 3 days or less, active customer = ordered in last 90 days) are easy to change.
