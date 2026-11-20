"""Check the starter CSV model. Run with python scripts/check_model.py."""
import csv
from decimal import Decimal, InvalidOperation
from pathlib import Path

DATA = Path(__file__).resolve().parents[1] / "data"
GRAINS = {
    "DimDate": ("DateKey",),
    "DimProduct": ("ProductKey",),
    "DimCustomer": ("CustomerKey",),
    "DimLine": ("LineKey",),
    "FactInvoice": ("DocumentLine",),
    "FactStock": ("DateKey", "ProductKey"),
    "FactShift": ("Shift",),
    "FactOpportunity": ("Deal", "DateKey"),
}
UNITS = {
    "FactInvoice": ("SalesGBP", "CostGBP"),
    "FactStock": ("ClosingCostGBP",),
    "FactShift": ("PlannedMin", "RunMin", "IdealMetresPerMin", "InputM", "OutputM", "FirstPassM", "RecoveredM"),
    "FactOpportunity": ("ValueGBP", "Probability"),
}
errors = []
dimension_keys = {}
for table, grain in GRAINS.items():
    seen = set()
    with (DATA / f"{table}.csv").open(newline="", encoding="utf-8") as source:
        for line, row in enumerate(csv.DictReader(source), 2):
            location = f"{table}.csv line {line}"
            key = tuple(row[column] for column in grain)
            if not all(key) or key in seen:
                errors.append(f"{location}: empty or duplicate key {key}")
            seen.add(key)
            for column in dimension_keys.keys() & row.keys():
                if row[column] not in dimension_keys[column]:
                    errors.append(f"{location}: unknown {column} {row[column]}")
            for column in UNITS.get(table, ()):
                try:
                    value = Decimal(row[column])
                    if not value.is_finite() or (column == "Probability" and not 0 <= value <= 1):
                        raise ValueError
                except (InvalidOperation, ValueError):
                    errors.append(f"{location}: invalid {column} {row[column]!r}")
    if table.startswith("Dim"):
        dimension_keys[grain[0]] = {k[0] for k in seen}

if errors:
    raise SystemExit("\n".join(errors))
print("All eight tables passed key, relationship and numeric field checks.")
