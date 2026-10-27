let
    Ark25 = Table.PromoteHeaders(Kilde{[Item = "ORDERS_2025", Kind = "Sheet"]}[Data], [PromoteAllScalars = true]),
    Ark26 = Table.PromoteHeaders(Kilde{[Item = "ORDERS_2026", Kind = "Sheet"]}[Data], [PromoteAllScalars = true]),
    // 2025 har ekstra kolonner (LegacyRef, SourceFile) - reducer til faelles kolonner
    Kolonner = {"OrderID", "CustomerName", "RegionName", "OrderDate", "OrderChannel", "Status", "Priority"},
    Samlet = Table.Combine({Table.SelectColumns(Ark25, Kolonner), Table.SelectColumns(Ark26, Kolonner)}),
    Typer = Table.TransformColumnTypes(Samlet, {{"OrderID", type text}, {"CustomerName", type text}, {"RegionName", type text}, {"OrderDate", type datetime}, {"OrderChannel", Int64.Type}, {"Status", type text}, {"Priority", type text}}, "en-US"),
    KunDato = Table.TransformColumns(Typer, {{"OrderDate", Date.From, type date}}),
    Trimmet = Table.TransformColumns(KunDato, {{"OrderID", Text.Trim, type text}, {"CustomerName", Text.Trim, type text}, {"RegionName", Text.Trim, type text}, {"Status", Text.Trim, type text}, {"Priority", Text.Trim, type text}}),
    Unikke = Table.Distinct(Trimmet, {"OrderID"})
in
    Unikke
