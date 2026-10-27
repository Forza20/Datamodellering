let
    Ark = Kilde{[Item = "sales_targets", Kind = "Sheet"]}[Data],
    Headers = Table.PromoteHeaders(Ark, [PromoteAllScalars = true]),
    Typer = Table.TransformColumnTypes(Headers, {{"Period", type text}, {"TargetRevenue", type number}}, "en-US"),
    MedDato = Table.AddColumn(Typer, "MonthStart", each Date.FromText(Text.Trim([Period]) & "-01", [Format = "yyyy-MM-dd"]), type date),
    Valgt = Table.SelectColumns(MedDato, {"MonthStart", "TargetRevenue"}),
    Unikke = Table.Distinct(Valgt, {"MonthStart"})
in
    Unikke
