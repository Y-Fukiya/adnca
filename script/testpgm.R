dsname <- "ADPC"

attrib_func <- function(data,var){
  if (requireNamespace("metatools", quietly = T)) {
  data %>%
    # Drop unspecified variables from specs
    metatools::drop_unspec_vars({{var}}) %>%
    # Check all variables specified are present and no more
    metatools::check_variables({{var}}) %>%
    # Checks all variables with CT only contain values within the CT.
    metatools::check_ct_data({{var}}) %>%
    # Orders the columns according to the spec
    metatools::order_cols({{var}}) %>%
    # Sorts the rows by the sort keys
    metatools::sort_by_key({{var}})
  }
  else {
    stop("Something bad happened.")
  }
}

adpc <- attrib_func(adpc_prefinal,metacore)

export_xpt <- function(data,var,dir,dsname){
  if (requireNamespace("xportr", quietly = T)) {
    data %>%
      # Coerce variable type to match spec
      xportr::xportr_type({{var}}) %>%
      # Assigns SAS length from a variable level metadata
      xportr::xportr_length({{var}}) %>%
      # Assigns variable label from metacore specifications
      xportr::xportr_label({{var}}) %>%
      # Assigns variable format from metacore specifications
      xportr::xportr_format({{var}}) %>%
      # Assigns dataset label from metacore specifications
      xportr::xportr_df_label({{var}}) %>%
      # Write xpt v5 transport file
      xportr::xportr_write(
        file.path(
           {{dir}}
          ,paste(
             tolower({{dsname}})
            ,"xpt"
            ,sep=".")
        )
      ) 
  }
  else {
    stop("Something bad happened.")
  }
}

export_xpt(adpc,metacore,dir,dsname)

ex_dates <- ex %>%
  derive_vars_merged(
    dataset_add = adsl,
    new_vars = adsl_vars,
    by_vars = exprs(STUDYID, USUBJID)
  ) %>%
  # Keep records with nonzero dose
  filter(EXDOSE > 0) %>%
  # Add time and set missing end date to start date
  # Impute missing time to 00:00:00
  # Note all times are missing for dosing records in this example data
  # Derive Analysis Start and End Dates
  # derive_vars_dtm(
  #   new_vars_prefix = "AST",
  #   dtc = EXSTDTC,
  #   time_imputation = "00:00:00"
  # ) %>%
  # derive_vars_dtm(
  #   new_vars_prefix = "AEN",
  #   dtc = EXENDTC,
  #   time_imputation = "00:00:00"
  # ) %>%
  crossing(prefix = c("AST","AEN"),
           dtc    = c(expr(EXSTDTC), expr(EXENDTC)),
           time_imput = c("00:00:00","00:00:00")) %>%
  purrr::pmap(
    function(prefix, dtc, time_imput) {
      derive_vars_dtm(
        new_vars_prefix = {{ prefix }},
        dtc = {{  dtc }},
        time_imputation = {{ time_imput}},
      ) 
    }
  ) %>%
  # Derive event ID and nominal relative time from first dose (NFRLT)
  mutate(
    EVID = 1,
    NFRLT = 24 * (VISITDY - 1), .after = USUBJID
  ) %>%
  # Set missing end dates to start date
  mutate(AENDTM = case_when(
    is.na(AENDTM) ~ ASTDTM,
    TRUE ~ AENDTM
  )) %>%
  # Derive dates from date/times
  derive_vars_dtm_to_dt(exprs(ASTDTM,AENDTM))


