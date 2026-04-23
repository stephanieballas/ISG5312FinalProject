# ISG5312 Final Project - Canine Osteosarcoma WES Analysis
# Reproducing Das et al. 2021 (DOI: 10.1038/s42003-021-02683-0)
# Author: Stephanie Ballas

library(readr)
library(dplyr)
library(ggplot2)
library(survival)
library(survminer)
library(maftools)

# ============================================================
# LOAD DATA
# ============================================================

proj_path <- "C:/Users/steph/OneDrive/Documents/ISG5312/ISG5312_Analysis"

variants <- read_tsv("C:/Users/steph/OneDrive - University of Connecticut/GRAD SCHOOL/UCONN PSM HCG/ISG5312/all_variants_annotated2.tsv")

metadata <- data.frame(
  TumorID = c("T-424","T-856","T-907","T-1192","T-1087","T-458","T-276","T-1096",
              "T-999","T-1272","T-134","T-343","T-1023","T-149","T-843","T-153",
              "T-554","T-25","T-1247","T-992","T-74","T-1166","T-346","T-399",
              "T-29C","T-1246","M-1166"),
  TumorSRR = c("SRR11352522","SRR11352516","SRR11352515","SRR11352510","SRR11352520",
               "SRR11352521","SRR11352527","SRR11352512","SRR11352513","SRR11352507",
               "SRR11352506","SRR11352525","SRR11352531","SRR11352530","SRR11352517",
               "SRR11352529","SRR11352519","SRR11352528","SRR11352508","SRR11352514",
               "SRR11352518","SRR11352511","SRR11352524","SRR11352523","SRR11352526",
               "SRR11352509","SRR11352532"),
  DFI = c(20,64,75,77,80,91,95,97,132,134,150,151,216,232,246,252,296,372,376,
          392,406,427,474,605,1533,756,NA),
  TumorLocation = c("Radius","Humerus","Tibia","Radius","Humerus","Humerus","Humerus",
                    "Radius","Tibia","Humerus","Humerus","Femur","Tibia","Humerus",
                    "Tibia","Radius","Scapula","Tibia","Humerus","Tibia","Radius",
                    "Tibia","Radius","Femur","Tibia","Radius","Metastatic"),
  Sex = c("Male","Female","Male","Male","Male","Female","Female","Female","Female",
          "Female","Female","Male","Male","Female","Male","Male","Male","Male",
          "Male","Female","Female","Male","Male","Female","Male","Female","Male"),
  stringsAsFactors = FALSE
)

# Join metadata to variants
variants <- variants %>%
  mutate(TumorSRR = sub("_vs_.*", "", Sample)) %>%
  left_join(metadata %>% select(TumorID, TumorSRR, DFI, TumorLocation), by = "TumorSRR")

# Add variant type and mutation type
variants <- variants %>%
  mutate(
    VariantType = ifelse(nchar(Ref) == 1 & nchar(Alt) == 1, "SNP", "INDEL"),
    MutationType = case_when(
      grepl("missense_variant", Effect) ~ "Missense_Mutation",
      grepl("frameshift_variant", Effect) & nchar(Ref) > nchar(Alt) ~ "Frame_Shift_Del",
      grepl("frameshift_variant", Effect) ~ "Frame_Shift_Ins",
      grepl("stop_gained", Effect) ~ "Nonsense_Mutation",
      grepl("stop_lost", Effect) ~ "Nonstop_Mutation",
      grepl("splice_acceptor|splice_donor", Effect) ~ "Splice_Site",
      grepl("synonymous_variant", Effect) ~ "Silent",
      grepl("conservative_inframe_insertion|disruptive_inframe_insertion", Effect) ~ "In_Frame_Ins",
      grepl("conservative_inframe_deletion|disruptive_inframe_deletion", Effect) ~ "In_Frame_Del",
      grepl("start_lost", Effect) ~ "Translation_Start_Site",
      TRUE ~ "Other"
    )
  )

# ============================================================
# FIG 1A: Somatic variant counts by DFI
# ============================================================

variant_counts2 <- variants %>%
  filter(!TumorID %in% c("T-1087", "M-1166")) %>%
  group_by(TumorID, DFI, TumorLocation, VariantType) %>%
  summarise(Total = n(), .groups = "drop") %>%
  arrange(DFI) %>%
  mutate(TumorID = factor(TumorID, levels = unique(TumorID[order(DFI)])),
         DFI_group = case_when(
           DFI < 100 ~ "DFI: <100 days",
           DFI <= 300 ~ "DFI: 100-300 days",
           TRUE ~ "DFI: >300 days"
         ),
         DFI_group = factor(DFI_group, levels = c("DFI: <100 days","DFI: 100-300 days","DFI: >300 days")))

fig1a <- ggplot(variant_counts2, aes(x = TumorID, y = Total, fill = VariantType)) +
  geom_bar(stat = "identity") +
  facet_grid(~ DFI_group, scales = "free_x", space = "free_x") +
  scale_fill_manual(values = c("SNP" = "steelblue", "INDEL" = "orange")) +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8)) +
  labs(x = "Sample Name", y = "Number of variants",
       fill = "Variant Types",
       title = "Fig 1a: Somatic variant counts by DFI")

ggsave("fig1a_variant_counts.png", plot = fig1a, width=10, height=5, dpi=300)

# ============================================================
# FIG 1B: Mutation type distribution by DFI
# ============================================================

mutation_colors <- c(
  "Frame_Shift_Del" = "#E41A1C",
  "Frame_Shift_Ins" = "#FF7F00",
  "In_Frame_Ins" = "#FFFF33",
  "Missense_Mutation" = "#984EA3",
  "Nonstop_Mutation" = "#4DAF4A",
  "In_Frame_Del" = "#377EB8",
  "Nonsense_Mutation" = "#A65628",
  "Splice_Site" = "#F781BF",
  "Silent" = "#999999",
  "Translation_Start_Site" = "#000000"
)

fig1b_data <- variants %>%
  filter(!TumorID %in% c("T-1087", "M-1166"),
         MutationType != "Other") %>%
  group_by(TumorID, DFI, MutationType) %>%
  summarise(Count = n(), .groups = "drop") %>%
  group_by(TumorID) %>%
  mutate(Fraction = Count / sum(Count)) %>%
  ungroup() %>%
  arrange(DFI) %>%
  mutate(TumorID = factor(TumorID, levels = unique(TumorID[order(DFI)])),
         DFI_group = case_when(
           DFI < 100 ~ "DFI: <100 days",
           DFI <= 300 ~ "DFI: 100-300 days",
           TRUE ~ "DFI: >300 days"
         ),
         DFI_group = factor(DFI_group, levels = c("DFI: <100 days","DFI: 100-300 days","DFI: >300 days")),
         MutationType = factor(MutationType, levels = names(mutation_colors)))

fig1b <- ggplot(fig1b_data, aes(x = TumorID, y = Fraction, fill = MutationType)) +
  geom_bar(stat = "identity") +
  facet_grid(~ DFI_group, scales = "free_x", space = "free_x") +
  scale_fill_manual(values = mutation_colors) +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8)) +
  labs(x = "Sample Name", y = "Fraction of mutation types",
       fill = "Mutation Types",
       title = "Fig 1b: Mutation type distribution by DFI")

ggsave("fig1b_mutation_types.png", plot = fig1b, width=10, height=5, dpi=300)

# ============================================================
# FIG 2A: Oncoprint of top mutated genes
# ============================================================

maf_data <- variants %>%
  filter(!TumorID %in% c("T-1087", "M-1166"),
         MutationType != "Other") %>%
  transmute(
    Hugo_Symbol = Gene,
    Tumor_Sample_Barcode = TumorID,
    Variant_Classification = MutationType,
    Variant_Type = VariantType,
    Chromosome = Chrom,
    Start_Position = Pos,
    End_Position = Pos,
    Reference_Allele = Ref,
    Tumor_Seq_Allele2 = Alt
  )

maf <- read.maf(maf = maf_data)

png("fig2a_oncoprint.png", width=800, height=1000)
oncoplot(maf = maf, top = 20)
dev.off()

# ============================================================
# FIG 6A: Kaplan-Meier plot - TP53 mutation status vs DFI
# ============================================================

tp53 <- variants %>%
  filter(Gene == "TP53",
         !TumorID %in% c("T-1087", "M-1166"))

tp53_status <- variants %>%
  filter(!TumorID %in% c("T-1087", "M-1166")) %>%
  distinct(TumorID) %>%
  left_join(
    tp53 %>%
      filter(MutationType != "Other", MutationType != "Silent") %>%
      mutate(TP53_class = case_when(
        MutationType == "Missense_Mutation" ~ "Missense",
        MutationType %in% c("Nonsense_Mutation", "Frame_Shift_Del", "Frame_Shift_Ins") ~ "Truncating",
        TRUE ~ "Other"
      )) %>%
      group_by(TumorID) %>%
      summarise(TP53_status = case_when(
        any(TP53_class == "Missense") ~ "TP53=MUT",
        any(TP53_class == "Truncating") ~ "TP53=WT/NULL",
        TRUE ~ "TP53=WT/NULL"
      ), .groups = "drop"),
    by = "TumorID"
  ) %>%
  mutate(TP53_status = ifelse(is.na(TP53_status), "TP53=WT/NULL", TP53_status))

tp53_survival <- tp53_status %>%
  left_join(metadata %>% select(TumorID, DFI), by = "TumorID") %>%
  filter(!is.na(DFI))

surv_obj <- Surv(time = tp53_survival$DFI, event = rep(1, nrow(tp53_survival)))
km_fit <- survfit(surv_obj ~ TP53_status, data = tp53_survival)

fig6a <- ggsurvplot(
  km_fit,
  data = tp53_survival,
  pval = TRUE,
  conf.int = TRUE,
  risk.table = TRUE,
  legend.labs = c("TP53=MUT", "TP53=WT/NULL"),
  palette = c("steelblue", "firebrick"),
  xlab = "Disease free interval (days)",
  ylab = "Survival probability",
  title = "Fig 6a: TP53 mutation status and DFI",
  risk.table.height = 0.25,
  ggtheme = theme_classic()
)

ggsave("fig6a_KM_TP53_status.png", plot = fig6a$plot, width=8, height=6, dpi=300)
