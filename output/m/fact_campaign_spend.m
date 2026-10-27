let
    Kampagne = Table.NestedJoin(slv_campaign_log, {"CampaignName"}, dim_campaign, {"campaign_name"}, "C", JoinKind.Inner),
    KampagneUd = Table.ExpandTableColumn(Kampagne, "C", {"campaign_key"}),
    Omdoebt = Table.RenameColumns(KampagneUd, {{"Date", "date_key"}, {"Impressions", "impressions"}, {"Clicks", "clicks"}, {"Spend", "spend"}}),
    Valgt = Table.SelectColumns(Omdoebt, {"date_key", "campaign_key", "impressions", "clicks", "spend"}),
    Typer = Table.TransformColumnTypes(Valgt, {{"date_key", type date}, {"campaign_key", Int64.Type}, {"impressions", Int64.Type}, {"clicks", Int64.Type}, {"spend", Currency.Type}})
in
    Typer
