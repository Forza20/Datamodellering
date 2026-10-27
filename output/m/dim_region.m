let
    Regioner = Table.Distinct(Table.SelectColumns(slv_city, {"RegionName"})),
    Sorteret = Table.Buffer(Table.Sort(Regioner, {{"RegionName", Order.Ascending}})),
    MedKey = Table.AddIndexColumn(Sorteret, "region_key", 1, 1, Int64.Type),
    Omdoebt = Table.RenameColumns(MedKey, {{"RegionName", "region_name"}}),
    Valgt = Table.SelectColumns(Omdoebt, {"region_key", "region_name"}),
    Typer = Table.TransformColumnTypes(Valgt, {{"region_key", Int64.Type}, {"region_name", type text}}),
    Ukendt = #table(Value.Type(Typer), {{-1, "Ukendt"}}),
    Samlet = Table.Combine({Typer, Ukendt})
in
    Samlet
