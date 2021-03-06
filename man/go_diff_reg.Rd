% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/enrichment.R
\name{go_diff_reg}
\alias{go_diff_reg}
\title{go_diff_reg}
\usage{
go_diff_reg(mergeset, diagnosis, idtype, entrezids = NULL)
}
\arguments{
\item{mergeset}{A matrix of merged expression sets (rows = genes,
columns = samples). The output of the funtion
`sigident.preproc::load_geo_data()`.}

\item{diagnosis}{A vector of integers, holding the binary outcome variable
(0 = "Control", 1 = "Target").}

\item{idtype}{A character string. The type of ID used to name the
genes. One of 'entrez' or 'affy' intended to use either entrez IDs or
affy IDs. Caution: when using entrez IDs, missing and duplicated IDs
are being removed!}

\item{entrezids}{A character vector, containing entrez IDs.
To be used only if 'idtype'= "affy" (default = NULL).}
}
\description{
Helper function to fitting linear models
}
