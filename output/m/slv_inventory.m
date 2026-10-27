let
    Ark = Kilde{[Item = "inventory", Kind = "Sheet"]}[Data],
    Headers = Table.PromoteHeaders(Ark, [PromoteAllScalars = true]),
    // Bredt ark: en kolonne pr. maaned -> en raekke pr. produkt pr. maaned
    Unpivot = Table.UnpivotOtherColumns(Headers, {"ProductName"}, "Period", "StockQty"),
    Typer = Table.TransformColumnTypes(Unpivot, {{"ProductName", type text}, {"Period", type text}, {"StockQty", Int64.Type}}, "en-US"),
    Trimmet = Table.TransformColumns(Typer, {{"ProductName", Text.Trim, type text}, {"Period", Text.Trim, type text}}),
    MedDato = Table.AddColumn(Trimmet, "MonthStart", each Date.FromText([Period] & "-01", [Format = "yyyy-MM-dd"]), type date),
    Valgt = Table.SelectColumns(MedDato, {"ProductName", "MonthStart", "StockQty"})
in
    Valgt
