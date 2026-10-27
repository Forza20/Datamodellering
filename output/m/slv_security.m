let
    Ark = Kilde{[Item = "security", Kind = "Sheet"]}[Data],
    Headers = Table.PromoteHeaders(Ark, [PromoteAllScalars = true]),
    Typer = Table.TransformColumnTypes(Headers, {{"UserEmail", type text}, {"Region", type text}}, "en-US"),
    Trimmet = Table.TransformColumns(Typer, {{"UserEmail", each Text.Lower(Text.Trim(_)), type text}, {"Region", Text.Trim, type text}}),
    Unikke = Table.Distinct(Trimmet, {"UserEmail"})
in
    Unikke
