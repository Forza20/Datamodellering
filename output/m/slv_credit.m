let
    Ark = Kilde{[Item = "user_details", Kind = "Sheet"]}[Data],
    Headers = Table.PromoteHeaders(Ark, [PromoteAllScalars = true]),
    Valgt = Table.SelectColumns(Headers, {"UserID", "CreditLimit"}),
    Typer = Table.TransformColumnTypes(Valgt, {{"UserID", Int64.Type}, {"CreditLimit", type number}}, "en-US"),
    Omdoebt = Table.RenameColumns(Typer, {{"UserID", "CustomerID"}}),
    Unikke = Table.Distinct(Omdoebt, {"CustomerID"})
in
    Unikke
