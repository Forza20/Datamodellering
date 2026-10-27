let
    Ark = Kilde{[Item = "Address", Kind = "Sheet"]}[Data],
    Headers = Table.PromoteHeaders(Ark, [PromoteAllScalars = true]),
    Valgt = Table.SelectColumns(Headers, {"AddressID", "Street", "CityName"}),
    Typer = Table.TransformColumnTypes(Valgt, {{"AddressID", Int64.Type}, {"Street", type text}, {"CityName", type text}}, "en-US"),
    Trimmet = Table.TransformColumns(Typer, {{"Street", Text.Trim, type text}, {"CityName", Text.Trim, type text}}),
    Unikke = Table.Distinct(Trimmet, {"AddressID"})
in
    Unikke
