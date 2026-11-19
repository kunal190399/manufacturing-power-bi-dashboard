# Commercial & Operations Transformation Dashboard

**Planned build · Power BI Desktop, Power Query, SQL and DAX**

**Decision.** A sales director sees a promising coated-fabric order. Finance needs its expected margin, while production needs to see which line would carry the work. The executive view should let them investigate both questions without confusing open opportunities with booked sales.

| Milestone | Work | Acceptance check |
|---|---|---|
| 1. Agree definitions | Draft a KPI dictionary with grain, units, exclusions and business owner. Hand-work one invoice, one opportunity and one shift. | A second reader can reproduce the expected figures from the example rows. |
| 2. Model the sources | Generate ERP invoice lines, daily stock balances and production runs, plus CRM opportunity snapshots. Build date, customer, product and line dimensions. Use only dimensions applicable to each fact. | Keys are unique at the declared grain. Unmatched keys, duplicate invoices and inconsistent units appear in an exception report. |
| 3. Reconcile the pipeline | Stage raw records, standardise units and dates, then load the star schema. Re-run from the same inputs. | Row counts and invoice totals reconcile to source. A second refresh produces identical results. |
| 4. Build and demonstrate | Create an executive page, a sales and margin drill-through, and a line-performance page. Document one management decision with the report filters used. | Publish the Power BI file, screenshots, reconciliation checks and a one-page refresh and handover guide. |

## Measures to validate

| Measure | Proposed definition |
|---|---|
| Gross margin % | (Net invoiced sales less cost of goods sold) divided by net invoiced sales. Aggregate amounts before calculating the percentage. |
| Weighted pipeline | Sum of open opportunity value multiplied by stage probability, using one snapshot per opportunity at the reporting date. |
| Overall equipment effectiveness (OEE) | Availability × performance × quality. Use run time, planned production time, ideal cycle time, total output and good output in consistent units. |
| Inventory turns | Period cost of goods sold divided by average daily inventory value for the same period, both at cost. Label the reporting period. |
| Production yield | First-pass good metres divided by input metres for a specified stage. Keep reworked output separately identifiable. |

**First session.** Draft the five dictionary entries and a small reconciliation fixture. Check credit notes, zero denominators and an opportunity repeated across two snapshots before designing the visuals.
