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
  consort,
  DiagrammeR,
  
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
adsl <- import(paste(pwd,"output/adsl.xpt",sep="/"))

test_adsl <- adsl %>%
  select(SUBJID,ACTARMCD,ACTARM,EOSSTT,DTHDT) %>%
  mutate(SUBJID1=SUBJID,
         SCR = case_when(
           ACTARMCD=="Scrnfail" ~ ACTARM,
           .default = NULL
          ),
         SUBJID2 = case_when(
           ACTARMCD!="Scrnfail" ~ SUBJID,
           .default = NULL
         ),
         ARM = case_when(
           ACTARMCD!="Scrnfail" ~ ACTARM,
           .default = NULL
         ),
         DISC = case_when(
           EOSSTT=="DISCONTINUED" & !is.na(DTHDT) ~ "Death",
           EOSSTT=="DISCONTINUED" &  is.na(DTHDT) ~ "Other",
           .default = NULL
         )
         ) %>%
  select(-c(SUBJID,ACTARMCD,ACTARM,EOSSTT,DTHDT))

g <- consort_plot(data = test_adsl,
                  orders = list(SUBJID1 = "Population",
                                SCR     = "Excluded",
                                ARM     = "Randomized patient",
                                DISC    = "Disompleted",
                                SUBJID1 = "Completed"),
                  side_box = c("SCR", "DISC"),
                  allocation = "ARM",
                  labels = c("1" = "Screening",
                             "2" = "Randomization",
                             "4" = "End of study"),
                  cex = 1)

plot(g)
#plot(g, grViz = TRUE)
#cat(build_grviz(g), file = "consort.gv")

# save plots
#png("consort_diagram.png", width = 29, height = 21, res = 300, units = "cm", type = "cairo") 
#plot(g)
#dev.off() 

