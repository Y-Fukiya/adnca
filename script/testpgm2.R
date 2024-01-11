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
adpc <- import(paste(pwd,"output/adpc.xpt",sep="/"))

adpc$AVISIT <- char2factor(adpc,"AVISIT","AVISITN")

tbl <- adpc %>% 
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
