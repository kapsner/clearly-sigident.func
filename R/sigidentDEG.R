#' @title Perform DEG Analysis in Gene Expression Datasets Derived
#'   from MicroArrays
#'
#' @description One function to perform DEG analysis.
#'
#' @param mergeset A matrix of merged expression sets (rows = genes,
#'   columns = samples). The output of the funtion
#'   `sigident.preproc::load_geo_data()`.
#' @param mergedset A large merged Expression Data set. The output
#'   of the funtion `sigident.preproc::load_geo_data()`.
#' @param sample_metadata A data frame. The data frame holding the
#'   sample metadata.
#' @param diagnosis A vector of integers, holding the binary outcome variable
#'   (0 = "Control", 1 = "Target").
#' @param idtype A character string. The type of ID used to name the
#'   genes. One of 'entrez' or 'affy' intended to use either entrez IDs or
#'   affy IDs. Caution: when using entrez IDs, missing and duplicated IDs
#'   are being removed!
#' @param fdr A positive numeric value between (max. 0.05) indicating the
#'   desired q-Value during DEG analysis (Default: 0.01).
#' @param csvdir A character string. Path to the folder to store output
#'   tables. Default: "./tables/".
#' @param plotdir A character string. Path to the folder to store resulting
#'   plots. Default: "./plots/".
#'
#' @import data.table
#'
#'
#' @export

sigidentDEG <- function(mergeset, # nolint
                        mergedset,
                        sample_metadata,
                        diagnosis,
                        idtype,
                        fdr,
                        plotdir = "./plots/",
                        csvdir = "./tables/") {
  stopifnot(
    class(mergeset) == c("matrix", "array"),
    is.data.frame(sample_metadata),
    is.character(idtype),
    idtype %in% c("entrez", "affy"),
    is.numeric(fdr),
    fdr > 0 | fdr <= 0.05,
    is.character(plotdir),
    is.character(csvdir)
  )

  targetcol <- "target"
  controlname <- "Control"

  # create internal list for storage
  rv <- list()

  # store names
  rv$controlname <- controlname
  rv$targetcol <- targetcol

  # store other variables
  rv$deg_q <- fdr
  rv$diagnosis <- diagnosis
  rv$idtype <- idtype

  # store dirs
  rv$plotdir <- sigident.preproc::clean_path_name(plotdir)
  rv$csvdir <- sigident.preproc::clean_path_name(csvdir)

  # add mergeset to list
  rv$mergeset <- mergeset
  rv$mergedset <- mergedset

  ### DEG Analysis ###
  rv$genes <- identify_degs(
    mergeset = rv$mergeset,
    diagnosis = rv$diagnosis,
    q_value = rv$deg_q
  )

  # heatmap creation
  # create colors for map
  ht_colors <- color_heatmap(
    sample_metadata = sample_metadata
  ) #% cancer = red

  plot_deg_heatmap(
    mergeset = rv$mergeset,
    genes = rv$genes,
    patientcolors = ht_colors,
    filename = paste0(rv$plotdir, "DEG_heatmap.png")
  )

  # Export a table with DEGs and annotations
  rv$deg_info <-
    export_deg_annotations(
      mergedset = rv$mergedset,
      genes = rv$genes,
      idtype = rv$idtype
    )
  data.table::fwrite(rv$deg_info, paste0(rv$csvdir, "DEG_info.csv"))

  # export table with differential expression parameters and annotations
  rv$deg_results <- limma_top_table(
    mergeset = rv$mergeset,
    diagnosis = rv$diagnosis,
    q_value = rv$deg_q
  )
  data.table::fwrite(rv$deg_results, paste0(rv$csvdir, "DEG_results.csv"))

  # return genes
  return(rv$genes)
}
