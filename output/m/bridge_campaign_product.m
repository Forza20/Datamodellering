let
    Kampagne = Table.NestedJoin(slv_campaign_sku, {"CampaignName"}, dim_campaign, {"campaign_name"}, "C", JoinKind.Inner),
    KampagneUd = Table.ExpandTableColumn(Kampagne, "C", {"campaign_key"}),
    // Inner join: SKU'er uden produkt (DSC-001) falder ud
    Produkt = Table.NestedJoin(KampagneUd, {"ProductCode"}, dim_product, {"product_code"}, "P", JoinKind.Inner),
    ProduktUd = Table.ExpandTableColumn(Produkt, "P", {"product_key"}),
    Valgt = Table.SelectColumns(ProduktUd, {"campaign_key", "product_key"}),
    Typer = Table.TransformColumnTypes(Valgt, {{"campaign_key", Int64.Type}, {"product_key", Int64.Type}}),
    Unikke = Table.Distinct(Typer)
in
    Unikke
