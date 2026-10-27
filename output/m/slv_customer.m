let
    Ark = Kilde{[Item = "CUST_MASTER", Kind = "Sheet"]}[Data],
    Headers = Table.PromoteHeaders(Ark, [PromoteAllScalars = true]),
    Valgt = Table.SelectColumns(Headers, {"CustomerID", "CustomerName", "Segment", "AddressID", "AccountManager", "PaymentTerms"}),
    Typer = Table.TransformColumnTypes(Valgt, {{"CustomerID", Int64.Type}, {"CustomerName", type text}, {"Segment", type text}, {"AddressID", Int64.Type}, {"AccountManager", type text}, {"PaymentTerms", type text}}, "en-US"),
    Trimmet = Table.TransformColumns(Typer, {{"CustomerName", Text.Trim, type text}, {"Segment", Text.Trim, type text}, {"AccountManager", Text.Trim, type text}, {"PaymentTerms", Text.Trim, type text}}),
    UdenTest = Table.SelectRows(Trimmet, each [CustomerID] <> 9999),
    Unikke = Table.Distinct(UdenTest, {"CustomerID"})
in
    Unikke
