let
    Omdoebt = Table.RenameColumns(slv_security, {{"UserEmail", "user_email"}, {"Region", "region"}}),
    Valgt = Table.SelectColumns(Omdoebt, {"user_email", "region"})
in
    Valgt
