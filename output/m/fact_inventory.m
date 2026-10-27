let
    Produkt = Table.NestedJoin(slv_inventory, {"ProductName"}, dim_product, {"product_name"}, "P", JoinKind.LeftOuter),
    ProduktUd = Table.ExpandTableColumn(Produkt, "P", {"product_key"}),
    Ukendt = Table.ReplaceValue(ProduktUd, null, -1, Replacer.ReplaceValue, {"product_key"}),
    Omdoebt = Table.RenameColumns(Ukendt, {{"MonthStart", "date_key"}, {"StockQty", "stock_qty"}}),
    Valgt = Table.SelectColumns(Omdoebt, {"date_key", "product_key", "stock_qty"}),
    Typer = Table.TransformColumnTypes(Valgt, {{"date_key", type date}, {"product_key", Int64.Type}, {"stock_qty", Int64.Type}})
in
    Typer
