# Commercial & Operations Transformation Dashboard

Which coated-fabric orders protect gross margin, and can the production line deliver them? This portfolio project uses synthetic manufacturing data. The first milestone establishes five reference figures for the future Power BI report.

## Reproduce the reference figures

Run the following command from the repository root with SQLite 3.25 or later. The query runs in memory and includes all sample rows.

```sh
sqlite3 -header -column :memory: < sql/reconcile.sql
```

The reporting period covers 1–2 April 2026 inclusive. All money values are in GBP. The owner column gives the proposed business owner for each definition.

| KPI | Owner and grain | Calculation for the sample |
|---|---|---|
| Gross margin % | Finance · posted invoice or credit line | The £1,000 invoice carries £600 of cost. A £100 credit reverses £60 of cost. Net sales are £900 and cost is £540, giving (£900 − £540) / £900 = **40%**. Exclude open orders. |
| Weighted pipeline | Sales · one latest snapshot per opportunity as of 2 April | Deal A contributes £8,000 × 50% = **£4,000**. Ignore its older 25% snapshot and its later closure. Deal B was already won at the cutoff and contributes zero. |
| Overall equipment effectiveness | Production · one coating line and shift | Availability is 420/480 minutes. Performance is 756/(420 × 2 metres per minute). Quality is 720/756 first-pass good metres. Multiplying the three gives **75%**. Exclude recovered metres from good output. |
| Inventory turns | Supply chain · closing stock at cost per day across the same scope as invoiced cost | Average the two daily balances, (£500 + £580)/2 = £540. Period cost of £540 / £540 = **1.0 turn over two days**, without annualising. |
| Production yield | Production · input and first-pass output at the coating stage per shift | 720 first-pass good metres / 800 input metres = **90%**. The shift recovered another 12 metres through rework, tracked separately. |

Ratios return SQL NULL when their denominator is zero. The OEE example uses a single shift. A future multi-shift report must aggregate the underlying times and quantities before deriving percentages.

[View the SQL example](sql/reconcile.sql) · [Read the dashboard roadmap](ROADMAP.md)
