let
    Ark = Kilde{[Item = "customer_contacts", Kind = "Sheet"]}[Data],
    Headers = Table.PromoteHeaders(Ark, [PromoteAllScalars = true]),
    Valgt = Table.SelectColumns(Headers, {"CustomerID", "ContactName", "IsPrimary"}),
    Typer = Table.TransformColumnTypes(Valgt, {{"CustomerID", Int64.Type}, {"ContactName", type text}}, "en-US"),
    Trimmet = Table.TransformColumns(Typer, {{"ContactName", Text.Trim, type text}}),
    Primaer = Table.SelectRows(Trimmet, each Text.Lower(Text.From([IsPrimary])) = "true"),
    KunNavn = Table.SelectColumns(Primaer, {"CustomerID", "ContactName"}),
    Unikke = Table.Distinct(KunNavn, {"CustomerID"})
in
    Unikke
