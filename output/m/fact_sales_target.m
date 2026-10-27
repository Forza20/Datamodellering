let
    Omdoebt = Table.RenameColumns(slv_sales_target, {{"MonthStart", "date_key"}, {"TargetRevenue", "target_amount"}}),
    Typer = Table.TransformColumnTypes(Omdoebt, {{"date_key", type date}, {"target_amount", Currency.Type}})
in
    Typer
