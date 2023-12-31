% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/capacity.R
\name{capacity}
\alias{capacity}
\title{capacity}
\usage{
capacity(
  fig_dir = NULL,
  prj_data = NULL,
  input_dir = getwd(),
  scenarios = NULL,
  ref_scenario = NULL
)
}
\arguments{
\item{fig_dir}{Default = NULL, Output folder for figures and maps.}

\item{prj_data}{Default = NULL, Gcam output data in "dat" format.}

\item{input_dir}{Default = getwd(),output direction}

\item{scenarios}{Default = NULL}

\item{ref_scenario}{Default = NULL}
}
\value{
number
}
\description{
Function that calculates capacity
}
\examples{
\dontrun{
library(gcamjobs)
gcamjobs::capacity (1,1)
}

}
\keyword{sum}
