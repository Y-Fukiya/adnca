rm(list=ls()); gc();  gc();
options(repos = "https://cran.ism.ac.jp/")
if (!requireNamespace("renv"  , quietly = T)) {install.packages("renv")}
if (!requireNamespace("pacman", quietly = T)) {install.packages("pacman")}
if (!requireNamespace("BiocManager", quietly = T)) {install.packages("BiocManager")}

##############################
pacman::p_load(
  # 一般的なデータ管理
  ####################
  tidyverse, 
  magrittr, 
  
  # パッケージのインストールと管理
  ################################
  pacman,   # パッケージのインストール・読み込み
  renv,     # グループで作業する際のパッケージのバージョン管理  
  
  # プロジェクトとファイルの管理
  ##############################
  here,     # Rのプロジェクトフォルダを基準とするファイルパス
  rio,      # 様々なタイプのデータのインポート・エクスポート
  
  # CDISC ADaM関連パッケージ
  ##########################
  Tplyr, 
  tfrmt,
  tidytlg,  
  rtables, 
  tern, 
  nestcolor,
  
  # スタイルテーブル関連パッケージ
  ################################
  huxtable,  # html,LaTeX,rtf,docx,xlsx and pptxへ変換可能なスタイル
  
  # 図表関連パッケージ
  ####################
  patchwork, # 複数の図表をまとめられるパッケージ
  
  # 出力形式関連パッケージ
  ########################
  pharmaRTF  # 医薬品申請関連資料の出力用パッケージ
)

pwd <- here::here()
nca  <- import(paste(pwd,"output/nca.sas7bdat",sep="/"))
adsl <- import(paste(pwd,"output/adsl.xpt",sep="/"))
adnca <- import(paste(pwd,"output/adnca.xpt",sep="/"))

adnca$AVISIT <- char2factor(adnca,"AVISIT","AVISITN")

tbl <- adnca %>% 
  filter(PARAMCD == "XAN") %>% 
  univar(colvar = "ARMCD", 
         rowvar = "AVAL", 
         rowbyvar = "AVISIT",
         tablebyvar = "PARAM",
         decimal = 4)

knitr::kable(tbl)

#lyt <- rtables::basic_table() %>%
#  rtables::split_cols_by(var = "ARM") %>%
#  rtables::split_rows_by(var = "AVISIT") %>%
#  rtables::analyze(vars = "AVAL", mean, format = "xx.x")

#lyt2 <- rtables::basic_table() %>%
#  rtables::split_cols_by(var = "ARM") %>%
#  rtables::split_rows_by(var = "AVISIT") %>%
#  tern::analyze_vars(vars = "AVAL", .formats = c("mean_sd" = "(xx.xx, xx.xx)"))

#adrs <- formatters::ex_adrs
#adsl <- formatters::ex_adsl
#adlb <- formatters::ex_adlb
#adlb <- dplyr::filter(adlb, PARAMCD == "ALT", AVISIT != "SCREENING")
#tern::g_lineplot(adlb, adsl, subtitle = "Laboratory Test:")

nca  <- import("./output/nca.sas7bdat")
adsl <- import("./output/adsl.xpt")
adnca <- import("./output/adnca.xpt")

nca_t  <- nca %>% 
  pivot_longer(  -c(SUBJID,TRT01A)
               , names_to = "PARAMCD"
               , values_to = "AVAL") %>%
  mutate(TRT01A = factor( TRT01A
                         ,c( "Xanomeline Low Dose"
                            ,"Xanomeline High Dose")))

prec_data <- tibble::tribble(
  ~PARAMCD, ~max_int, ~max_dec,
  "CMAX"    ,   2, 1,
  "AUCLST"  ,   4, 1,
  "AUCIFO"  ,   4, 1,
  "TMAX"    ,   2, 2,
  "MRTEVIFO",   3, 1,
  "LAMZHL"  ,   2, 2,
  ) %>%
  mutate(PARAMCD = factor(PARAMCD
                          ,c( "CMAX","AUCLST","AUCIFO"
                             ,"TMAX","LAMZHL","MRTEVIFO")))

header_data <- adsl %>%
  filter(
    SAFFL == "Y" & 
    TRT01A %in% c("Xanomeline Low Dose","Xanomeline High Dose")) %>%
  mutate(
    TRT01A = factor( TRT01A
                    ,c( "Xanomeline Low Dose"
                       ,"Xanomeline High Dose"))) %>%
  group_by(TRT01A) %>%
  summarise(n=n()) 

nca_summary <- nca_t %>%
  filter(PARAMCD %in% c( "CMAX","AUCLST","AUCIFO"
                        ,"TMAX","MRTEVIFO","LAMZHL")) %>%
  mutate(PARAMCD = factor( PARAMCD
                          ,c( "CMAX","AUCLST","AUCIFO"
                             ,"TMAX","LAMZHL","MRTEVIFO"))) %>%
  univar(colvar = "TRT01A", 
         rowvar = "AVAL", 
         tablebyvar = "PARAMCD",
         statlist = statlist(c("N","MEANSD","CV","GeoMEAN","MEDIAN","RANGE")),
         decimal = 4)

tbl <- bind_table(nca_summary,tablebyvar="PARAMCD")

gentlg(huxme = tbl,
       orientation = "portrait",
       file = "./output/table_14.2.01_1",
       title = "PK Parameter summary",
       footers = "xxxxxxxxxxxxxxxxxxxxxx",
       colspan = list(c("", "Xanomeline","Xanomeline")),
       colheader = c("","Low","High"),
       wcol=.30
)


