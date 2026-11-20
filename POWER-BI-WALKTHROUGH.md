# Build the first Power BI report

Use the eight CSVs in `data/`. They reproduce the two-day SQL example with a third date to demonstrate a later change in opportunity status. All names and transactions are synthetic.

1. Open this branch on GitHub, select **Code → Download ZIP**, then extract the archive. Keep the extracted folder in a stable location so Power Query can refresh from it.
2. On Windows, open Power BI Desktop and create a blank report. Choose **Home → Get data → Text/CSV**, select `DimDate.csv`, and choose **Transform Data**. Verify the first row supplies the headers, name the query `DimDate`, set `Date` to Date and `DateKey` to Whole Number. Choose **Close & Apply**. Repeat for the other seven CSVs using each filename without the extension as its query name. Set all DateKey columns to Whole Number, Probability to Decimal Number, GBP columns to Fixed Decimal Number, metre/minute quantities to numeric types and alphanumeric identifiers to Text.
3. In **Model view**, check the relationships below. Create each missing relationship by dragging the matching key between tables. Set cardinality to **one to many**, with the dimension on the one side, active, and **Single** filter direction. Remove any automatically inferred relationship outside this list.

| Dimension | Matching key | Fact tables |
|---|---|---|
| DimDate | DateKey | FactInvoice, FactOpportunity, FactShift, FactStock |
| DimProduct | ProductKey | FactInvoice, FactOpportunity, FactShift, FactStock |
| DimCustomer | CustomerKey | FactInvoice, FactOpportunity |
| DimLine | LineKey | FactShift |

4. Select **Modeling → New measure** and enter each formula separately. Format Net Sales, Cost and Weighted Pipeline as GBP, Gross Margin, OEE and Production Yield as percentages, and Period Inventory Turns as a decimal.

```dax
Net Sales = SUM(FactInvoice[SalesGBP])

Cost = SUM(FactInvoice[CostGBP])

Gross Margin = DIVIDE([Net Sales] - [Cost], [Net Sales])

Weighted Pipeline =
VAR Cutoff = MAX(DimDate[DateKey])
VAR History =
    CALCULATETABLE(FactOpportunity, REMOVEFILTERS(DimDate))
VAR Eligible = FILTER(History, FactOpportunity[DateKey] <= Cutoff)
VAR Deals = DISTINCT(SELECTCOLUMNS(Eligible, "DealID", FactOpportunity[Deal]))
RETURN
    COALESCE(
        SUMX(
            Deals,
            VAR CurrentDeal = [DealID]
            VAR Latest = TOPN(1, FILTER(Eligible, FactOpportunity[Deal] = CurrentDeal), FactOpportunity[DateKey], DESC)
            RETURN SUMX(FILTER(Latest, FactOpportunity[Status] = "open"), FactOpportunity[ValueGBP] * FactOpportunity[Probability])
        ), 0
    )

OEE =
DIVIDE(
    SUMX(FactShift, DIVIDE(FactShift[FirstPassM], FactShift[IdealMetresPerMin])),
    SUM(FactShift[PlannedMin])
)

Period Inventory Turns =
VAR AverageDailyCost =
    AVERAGEX(VALUES(DimDate[DateKey]), CALCULATE(SUM(FactStock[ClosingCostGBP])))
RETURN DIVIDE([Cost], AverageDailyCost)

Production Yield = DIVIDE(SUM(FactShift[FirstPassM]), SUM(FactShift[InputM]))
```

5. Name the page **Executive overview**. Add a **Between** slicer on `DimDate[Date]` (select the date field itself). Set it to **1–2 April 2026**. Add a Card for each of Gross Margin, Weighted Pipeline, OEE, Period Inventory Turns and Production Yield. Use zero decimal places for percentages and one for turns.
6. Check the cards from left to right against **40%, £4,000, 75%, 1.0, 90%**. Add a table with `DimProduct[Product]`, Net Sales and Cost. Barrier textile should show £900 sales and £540 cost after the credit. Extend the slicer through **3 April** and the pipeline should fall to **£0**, as deal A has closed. Restore 1–2 April before saving. Inventory coverage in this starter ends on 2 April.
7. Save your report as `Manufacturing Dashboard.pbix` in the extracted project folder. Reopen it and use **Home → Refresh** with the CSVs in the same location. Keep a screenshot of the reconciled overview for your portfolio.

Optional model check from the repository root using Python 3: `python scripts/check_model.py`.
