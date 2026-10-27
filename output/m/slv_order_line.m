let
    Ark = Kilde{[Item = "order_line_items", Kind = "Sheet"]}[Data],
    Headers = Table.PromoteHeaders(Ark, [PromoteAllScalars = true]),
    Valgt = Table.SelectColumns(Headers, {"LineID", "OrderID", "ProductName", "Quantity", "UnitPrice", "UnitCost", "DiscountPct", "LineTotal"}),
    Typer = Table.TransformColumnTypes(Valgt, {{"LineID", type text}, {"OrderID", type text}, {"ProductName", type text}, {"Quantity", Int64.Type}, {"UnitPrice", type number}, {"UnitCost", type number}, {"DiscountPct", type number}, {"LineTotal", type number}}, "en-US"),
    Trimmet = Table.TransformColumns(Typer, {{"LineID", Text.Trim, type text}, {"OrderID", Text.Trim, type text}, {"ProductName", Text.Trim, type text}}),
    Rabat0 = Table.ReplaceValue(Trimmet, null, 0, Replacer.ReplaceValue, {"DiscountPct"}),
    Unikke = Table.Distinct(Rabat0, {"LineID"})
in
    Unikke
