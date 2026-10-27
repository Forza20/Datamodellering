let
    Ark = Kilde{[Item = "products", Kind = "Sheet"]}[Data],
    Headers = Table.PromoteHeaders(Ark, [PromoteAllScalars = true]),
    Valgt = Table.SelectColumns(Headers, {"ProductCode", "ProductName", "Brand", "SubcategoryName", "UnitPrice", "PrimarySupplier"}),
    Typer = Table.TransformColumnTypes(Valgt, {{"ProductCode", type text}, {"ProductName", type text}, {"Brand", type text}, {"SubcategoryName", type text}, {"UnitPrice", type number}, {"PrimarySupplier", type text}}, "en-US"),
    Trimmet = Table.TransformColumns(Typer, {{"ProductCode", Text.Trim, type text}, {"ProductName", Text.Trim, type text}, {"Brand", Text.Trim, type text}, {"SubcategoryName", Text.Trim, type text}, {"PrimarySupplier", Text.Trim, type text}}),
    // Fjern testproduktet og de tomme dubletter (ingen brand/pris)
    UdenTest = Table.SelectRows(Trimmet, each [ProductCode] <> "ZZZ-000" and [Brand] <> null and [Brand] <> ""),
    UnikKode = Table.Distinct(UdenTest, {"ProductCode"}),
    UnikNavn = Table.Distinct(UnikKode, {"ProductName"})
in
    UnikNavn
