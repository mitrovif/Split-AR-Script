
# ===========================================================================================================
# AR.3.1:  Generate Institutional Implementation breakdown table - by source
# ============================================================================================================

institutional_implementation_table <- group_roster %>%
  filter(g_conled == 2) %>%
  mutate(
    Source = case_when(
      PRO08.A == 1 ~ "Survey",
      PRO08.B == 1 ~ "Administrative Data",
      PRO08.C == 1 ~ "Census",
      PRO08.D == 1 ~ "Data Integration",
      PRO08.E == 1 | PRO08.F == 1 | PRO08.G == 1 | PRO08.H == 1 | PRO08.X == 1 ~ "Other",
      TRUE ~ "Unknown"
    ),
    Use_of_Recommendations = case_when(
      PRO09 == 1 ~ "Using Recommendations",
      PRO09 == 2 ~ "Not Using Recommendations",
      PRO09 == 8 ~ "Don't Know",
      TRUE ~ "Unknown"
    )
  ) %>%
  group_by(Use_of_Recommendations, Source, ryear) %>%
  summarise(Total_Examples = n(), .groups = "drop") %>%
  pivot_wider(names_from = ryear, values_from = Total_Examples, values_fill = 0) %>%
  rowwise() %>%
  mutate(Total = sum(c_across(`2021`:`2024`), na.rm = TRUE)) %>%
  ungroup() %>%
  arrange(
    factor(Use_of_Recommendations, levels = c("Using Recommendations", "Not Using Recommendations", "Don't Know", "Unknown")),
    factor(Source, levels = c("Survey", "Census", "Administrative Data", "Other"))
  ) %>%
  mutate('Use of Recommendations' = Use_of_Recommendations) %>%
  select('Use of Recommendations', Source, `2021`, `2022`, `2023`, `2024`, Total)  # Ensure correct column order

# Beautify and create FlexTable for Word
ar.3.1 <- flextable(institutional_implementation_table) %>%
  theme_booktabs() %>%
  bold(part = "header") %>%
  bg(bg = "#f4cccc", j = "2024") %>%
  bg(bg = "#c9daf8", j = "Total") %>%
  merge_v(j = "Use of Recommendations") %>%
  merge_v(j = "Source") %>%
  border_outer(border = fp_border(color = "black", width = 2)) %>%
  # border_inner_v(border = fp_border(color = "gray", width = 0.5), part = "body") %>%
  border_inner_h(border = fp_border(color = "gray", width = 0.5), part = "all") %>%
  fontsize(size = 10, part = "all") %>%  # Set font size
  bg(part = "header", bg = "#4cc3c9") %>%
  autofit() %>%
  add_footer_row(
    values = paste0(
      "Footnote: Table shows institutionally led examples (g_conled == 2) by data source and whether ",
      "they used EGRISS recommendations (PRO09). “Source” is coded as Survey (PRO08.A), Administrative Data (PRO08.B), ",
      "Census (PRO08.C), Data Integration (PRO08.D) or Other (any of PRO08.E/F/G/H/X). “Use of Recommendations” ",
      "categories: Using (PRO09 == 1), Not Using (PRO09 == 2), Don't Know (PRO09 == 8), Unknown (else). ",
      "Counts reflect total examples per year (ryear 2021–2024) and summed in ‘Total’."
    ),
    colwidths = ncol(institutional_implementation_table)
  ) %>%
  fontsize(size = 7, part = "footer") %>%
  set_caption(
    caption = as_paragraph(
      as_chunk(
        "AR.3.1: Institutional Implementation Breakdown, by year (AR pg.49)",
        props = fp_text(
          font.family = "Helvetica",
          font.size   = 10,
          italic      = FALSE
        )
      )
    )
  )%>%
  fix_border_issues()

ar.3.1



