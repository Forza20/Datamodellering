let
    Ark = Kilde{[Item = "subcategories", Kind = "Sheet"]}[Data],
    Headers = Table.PromoteHeaders(Ark, [PromoteAllScalars = true]),
    Typer = Table.TransformColumnTypes(Headers, {{"CategorySubcategory", type text}}, "en-US"),
    Delt = Table.SplitColumn(Typer, "CategorySubcategory", Splitter.SplitTextByDelimiter("|"), {"Category", "Subcategory"}),
    Pyntet = Table.TransformColumns(Delt, {{"Category", each Text.Proper(Text.Trim(_)), type text}, {"Subcategory", each Text.Proper(Text.Trim(_)), type text}}),
    Unikke = Table.Distinct(Pyntet, {"Subcategory"})
in
    Unikke
