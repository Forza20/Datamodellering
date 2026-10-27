let
    Kampagner = Table.Distinct(Table.SelectColumns(slv_campaign_log, {"CampaignName", "Channel", "StartDate", "EndDate", "Budget"}), {"CampaignName"}),
    Sorteret = Table.Buffer(Table.Sort(Kampagner, {{"StartDate", Order.Ascending}, {"CampaignName", Order.Ascending}})),
    MedKey = Table.AddIndexColumn(Sorteret, "campaign_key", 1, 1, Int64.Type),
    Omdoebt = Table.RenameColumns(MedKey, {{"CampaignName", "campaign_name"}, {"Channel", "marketing_channel"}, {"StartDate", "start_date"}, {"EndDate", "end_date"}, {"Budget", "budget"}}),
    Valgt = Table.SelectColumns(Omdoebt, {"campaign_key", "campaign_name", "marketing_channel", "start_date", "end_date", "budget"}),
    Typer = Table.TransformColumnTypes(Valgt, {{"campaign_key", Int64.Type}, {"campaign_name", type text}, {"marketing_channel", type text}, {"start_date", type date}, {"end_date", type date}, {"budget", Currency.Type}})
in
    Typer
