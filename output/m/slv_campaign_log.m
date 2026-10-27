let
    Ark = Kilde{[Item = "CAMPAIGN_LOG", Kind = "Sheet"]}[Data],
    Headers = Table.PromoteHeaders(Ark, [PromoteAllScalars = true]),
    Valgt = Table.SelectColumns(Headers, {"CampaignName", "Channel", "StartDate", "EndDate", "Budget", "Date", "Impressions", "Clicks", "Spend"}),
    Typer = Table.TransformColumnTypes(Valgt, {{"CampaignName", type text}, {"Channel", type text}, {"StartDate", type date}, {"EndDate", type date}, {"Budget", type number}, {"Date", type date}, {"Impressions", Int64.Type}, {"Clicks", Int64.Type}, {"Spend", type number}}, "en-US"),
    Trimmet = Table.TransformColumns(Typer, {{"CampaignName", Text.Trim, type text}, {"Channel", Text.Trim, type text}}),
    Unikke = Table.Distinct(Trimmet, {"CampaignName", "Date"})
in
    Unikke
