let
    Linjer = Table.NestedJoin(slv_order_line, {"OrderID"}, slv_order, {"OrderID"}, "Ordre", JoinKind.Inner),
    OrdreUd = Table.ExpandTableColumn(Linjer, "Ordre", {"CustomerName", "RegionName", "OrderDate", "OrderChannel", "Status", "Priority"}),
    Kunde = Table.NestedJoin(OrdreUd, {"CustomerName"}, dim_customer, {"customer_name"}, "K", JoinKind.LeftOuter),
    KundeUd = Table.ExpandTableColumn(Kunde, "K", {"customer_key"}),
    Produkt = Table.NestedJoin(KundeUd, {"ProductName"}, dim_product, {"product_name"}, "P", JoinKind.LeftOuter),
    ProduktUd = Table.ExpandTableColumn(Produkt, "P", {"product_key"}),
    Region = Table.NestedJoin(ProduktUd, {"RegionName"}, dim_region, {"region_name"}, "R", JoinKind.LeftOuter),
    RegionUd = Table.ExpandTableColumn(Region, "R", {"region_key"}),
    Kanal = Table.NestedJoin(RegionUd, {"OrderChannel"}, dim_channel, {"channel_key"}, "Ch", JoinKind.LeftOuter),
    KanalUd = Table.ExpandTableColumn(Kanal, "Ch", {"channel_key"}),
    // Ingen match -> -1 (Ukendt)
    Ukendt = Table.ReplaceValue(KanalUd, null, -1, Replacer.ReplaceValue, {"customer_key", "product_key", "region_key", "channel_key"}),
    Status = Table.TransformColumns(Ukendt, {{"Status", each if _ = "Delivered" then "Leveret" else if _ = "Shipped" then "Afsendt" else if _ = "Processing" then "Under behandling" else _, type text}}),
    Prioritet = Table.TransformColumns(Status, {{"Priority", each if _ = "Express" then "Ekspres" else _, type text}}),
    // LineTotal er brutto (Quantity x UnitPrice) - netto er efter rabat
    Brutto = Table.AddColumn(Prioritet, "gross_amount", each Number.Round([Quantity] * [UnitPrice], 2), Currency.Type),
    Netto = Table.AddColumn(Brutto, "net_amount", each Number.Round([gross_amount] * (1 - [DiscountPct]), 2), Currency.Type),
    Rabat = Table.AddColumn(Netto, "discount_amount", each [gross_amount] - [net_amount], Currency.Type),
    Kost = Table.AddColumn(Rabat, "cost_amount", each Number.Round([Quantity] * [UnitCost], 2), Currency.Type),
    Omdoebt = Table.RenameColumns(Kost, {{"LineID", "line_id"}, {"OrderID", "order_id"}, {"OrderDate", "date_key"}, {"Status", "order_status"}, {"Priority", "order_priority"}, {"Quantity", "quantity"}, {"UnitPrice", "unit_price"}, {"DiscountPct", "discount_pct"}}),
    Valgt = Table.SelectColumns(Omdoebt, {"line_id", "order_id", "date_key", "customer_key", "product_key", "channel_key", "region_key", "order_status", "order_priority", "quantity", "unit_price", "discount_pct", "gross_amount", "discount_amount", "net_amount", "cost_amount"}),
    Typer = Table.TransformColumnTypes(Valgt, {{"line_id", type text}, {"order_id", type text}, {"date_key", type date}, {"customer_key", Int64.Type}, {"product_key", Int64.Type}, {"channel_key", Int64.Type}, {"region_key", Int64.Type}, {"quantity", Int64.Type}, {"unit_price", Currency.Type}, {"discount_pct", type number}})
in
    Typer
