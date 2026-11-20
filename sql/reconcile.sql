-- Synthetic reconciliation fixture. Period: 1–2 April 2026 inclusive.
WITH
invoice_lines(document_line, sales_gbp, cost_gbp) AS (
    VALUES ('INV-01/1', 1000, 600), ('CREDIT-01/1', -100, -60)
),
stock_days(stock_date, closing_cost_gbp) AS (
    VALUES ('2026-04-01', 500), ('2026-04-02', 580)
),
snapshots(deal, snapshot_date, status, value_gbp, probability) AS (
    VALUES ('A', '2026-04-01', 'open', 8000, 0.25),
           ('A', '2026-04-02', 'open', 8000, 0.50),
           ('B', '2026-04-01', 'open', 1000, 0.75),
           ('B', '2026-04-02', 'won', 1000, 1.00),
           ('A', '2026-04-03', 'won', 8000, 1.00)
),
ranked AS (
    SELECT *, ROW_NUMBER() OVER (
        PARTITION BY deal ORDER BY snapshot_date DESC
    ) AS recency
    FROM snapshots
    WHERE snapshot_date <= '2026-04-02'
),
-- One coating shift. The ideal speed is 2 metres per minute.
shift(planned_min, run_min, ideal_m_per_min, input_m, output_m, first_pass_m, recovered_m) AS (
    VALUES (480, 420, 2, 800, 756, 720, 12)
),
sales AS (
    SELECT SUM(sales_gbp) AS revenue, SUM(cost_gbp) AS cost FROM invoice_lines
)
SELECT
    100.0 * (revenue - cost) / NULLIF(revenue, 0) AS gross_margin_pct,
    (SELECT COALESCE(SUM(value_gbp * probability), 0)
     FROM ranked WHERE recency = 1 AND status = 'open') AS weighted_pipeline_gbp,
    100.0 * run_min / NULLIF(planned_min, 0)
        * output_m / NULLIF(run_min * ideal_m_per_min, 0)
        * first_pass_m / NULLIF(output_m, 0) AS oee_pct,
    cost / NULLIF((SELECT AVG(closing_cost_gbp) FROM stock_days), 0) AS period_inventory_turns,
    100.0 * first_pass_m / NULLIF(input_m, 0) AS production_yield_pct
FROM sales CROSS JOIN shift;
