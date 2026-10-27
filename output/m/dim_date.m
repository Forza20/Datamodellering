let
    Datoer = List.Combine({slv_order[OrderDate], slv_sales_target[MonthStart], slv_campaign_log[Date], slv_inventory[MonthStart]}),
    Start = #date(Date.Year(List.Min(Datoer)), 1, 1),
    Slut = #date(Date.Year(List.Max(Datoer)), 12, 31),
    Liste = List.Dates(Start, Duration.Days(Slut - Start) + 1, #duration(1, 0, 0, 0)),
    Tabel = Table.FromList(Liste, Splitter.SplitByNothing(), type table [date_key = date]),
    Aar = Table.AddColumn(Tabel, "year", each Date.Year([date_key]), Int64.Type),
    Kvartal = Table.AddColumn(Aar, "quarter", each "K" & Text.From(Date.QuarterOfYear([date_key])), type text),
    MaanedNr = Table.AddColumn(Kvartal, "month_no", each Date.Month([date_key]), Int64.Type),
    Maaned = Table.AddColumn(MaanedNr, "month_name", each Date.ToText([date_key], [Format = "MMM", Culture = "da-DK"]), type text),
    AarMaaned = Table.AddColumn(Maaned, "year_month", each Date.ToText([date_key], [Format = "yyyy-MM"]), type text),
    Maanedstart = Table.AddColumn(AarMaaned, "month_start", each Date.StartOfMonth([date_key]), type date),
    Uge = Table.AddColumn(Maanedstart, "week_no", each Date.WeekOfYear([date_key], Day.Monday), Int64.Type)
in
    Uge
