let
    Ark = Kilde{[Item = "campaign_skus", Kind = "Sheet"]}[Data],
    Headers = Table.PromoteHeaders(Ark, [PromoteAllScalars = true]),
    Typer = Table.TransformColumnTypes(Headers, {{"CampaignName", type text}, {"PromotedSKUs", type text}}, "en-US"),
    // En celle med flere SKU'er -> en raekke pr. SKU
    SomListe = Table.TransformColumns(Typer, {{"PromotedSKUs", each List.Transform(Text.Split(_, ","), Text.Trim)}}),
    Udfoldet = Table.ExpandListColumn(SomListe, "PromotedSKUs"),
    Omdoebt = Table.RenameColumns(Udfoldet, {{"PromotedSKUs", "ProductCode"}}),
    Typer2 = Table.TransformColumnTypes(Omdoebt, {{"ProductCode", type text}}),
    Trimmet = Table.TransformColumns(Typer2, {{"CampaignName", Text.Trim, type text}}),
    Unikke = Table.Distinct(Trimmet)
in
    Unikke
