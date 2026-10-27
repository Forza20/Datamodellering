let
    Adresse = Table.NestedJoin(slv_customer, {"AddressID"}, slv_address, {"AddressID"}, "Adr", JoinKind.LeftOuter),
    AdresseUd = Table.ExpandTableColumn(Adresse, "Adr", {"Street", "CityName"}),
    By = Table.NestedJoin(AdresseUd, {"CityName"}, slv_city, {"CityName"}, "By", JoinKind.LeftOuter),
    ByUd = Table.ExpandTableColumn(By, "By", {"RegionName"}),
    Kredit = Table.NestedJoin(ByUd, {"CustomerID"}, slv_credit, {"CustomerID"}, "Kr", JoinKind.LeftOuter),
    KreditUd = Table.ExpandTableColumn(Kredit, "Kr", {"CreditLimit"}),
    Kontakt = Table.NestedJoin(KreditUd, {"CustomerID"}, slv_contact, {"CustomerID"}, "Ko", JoinKind.LeftOuter),
    KontaktUd = Table.ExpandTableColumn(Kontakt, "Ko", {"ContactName"}),
    Sorteret = Table.Buffer(Table.Sort(KontaktUd, {{"CustomerID", Order.Ascending}})),
    MedKey = Table.AddIndexColumn(Sorteret, "customer_key", 1, 1, Int64.Type),
    Omdoebt = Table.RenameColumns(MedKey, {{"CustomerID", "customer_id"}, {"CustomerName", "customer_name"}, {"Segment", "segment"}, {"AccountManager", "account_manager"}, {"PaymentTerms", "payment_terms"}, {"CreditLimit", "credit_limit"}, {"Street", "street"}, {"CityName", "city"}, {"RegionName", "region"}, {"ContactName", "primary_contact"}}),
    Valgt = Table.SelectColumns(Omdoebt, {"customer_key", "customer_id", "customer_name", "segment", "account_manager", "payment_terms", "credit_limit", "street", "city", "region", "primary_contact"}),
    Typer = Table.TransformColumnTypes(Valgt, {{"customer_key", Int64.Type}, {"customer_id", Int64.Type}, {"customer_name", type text}, {"segment", type text}, {"account_manager", type text}, {"payment_terms", type text}, {"credit_limit", Currency.Type}, {"street", type text}, {"city", type text}, {"region", type text}, {"primary_contact", type text}}),
    Ukendt = #table(Value.Type(Typer), {{-1, null, "Ukendt", null, null, null, null, null, null, null, null}}),
    Samlet = Table.Combine({Typer, Ukendt})
in
    Samlet
