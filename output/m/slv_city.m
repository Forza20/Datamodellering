let
    Ark = Kilde{[Item = "cities", Kind = "Sheet"]}[Data],
    Headers = Table.PromoteHeaders(Ark, [PromoteAllScalars = true]),
    Valgt = Table.SelectColumns(Headers, {"CityName", "RegionName"}),
    Typer = Table.TransformColumnTypes(Valgt, {{"CityName", type text}, {"RegionName", type text}}, "en-US"),
    Trimmet = Table.TransformColumns(Typer, {{"CityName", Text.Trim, type text}, {"RegionName", Text.Trim, type text}}),
    Unikke = Table.Distinct(Trimmet, {"CityName"})
in
    Unikke
