let
    MedNoegle = Table.AddColumn(slv_product, "SubLower", each Text.Lower([SubcategoryName]), type text),
    SubLower = Table.AddColumn(slv_subcategory, "SubLower", each Text.Lower([Subcategory]), type text),
    Kategori = Table.NestedJoin(MedNoegle, {"SubLower"}, SubLower, {"SubLower"}, "Sub", JoinKind.LeftOuter),
    KategoriUd = Table.ExpandTableColumn(Kategori, "Sub", {"Category", "Subcategory"}),
    Sorteret = Table.Buffer(Table.Sort(KategoriUd, {{"ProductCode", Order.Ascending}})),
    MedKey = Table.AddIndexColumn(Sorteret, "product_key", 1, 1, Int64.Type),
    Omdoebt = Table.RenameColumns(MedKey, {{"ProductCode", "product_code"}, {"ProductName", "product_name"}, {"Brand", "brand"}, {"Category", "category"}, {"Subcategory", "subcategory"}, {"UnitPrice", "list_price"}, {"PrimarySupplier", "primary_supplier"}}),
    Valgt = Table.SelectColumns(Omdoebt, {"product_key", "product_code", "product_name", "brand", "category", "subcategory", "list_price", "primary_supplier"}),
    Typer = Table.TransformColumnTypes(Valgt, {{"product_key", Int64.Type}, {"product_code", type text}, {"product_name", type text}, {"brand", type text}, {"category", type text}, {"subcategory", type text}, {"list_price", Currency.Type}, {"primary_supplier", type text}}),
    Ukendt = #table(Value.Type(Typer), {{-1, null, "Ukendt", null, "Ukendt", "Ukendt", null, null}}),
    Samlet = Table.Combine({Typer, Ukendt})
in
    Samlet
