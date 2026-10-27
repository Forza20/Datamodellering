let
    Kanaler = #table(
        type table [channel_key = Int64.Type, channel_name = text],
        {{10, "Web"}, {20, "Butik"}, {30, "Telefon"}, {40, "Partner"}, {-1, "Ukendt"}}
    )
in
    Kanaler
