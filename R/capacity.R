#' capacity
#'
#' Function that sums two numbers
#'
#' @param fig_dir Default = NULL, Output folder for figures and maps.
#' @param prj_data Default = NULL, Gcam output data in "dat" format.
#' @param input_dir Default = getwd(),output direction
#' @keywords sum
#' @return number
#' @export
#' @examples
#' \dontrun{
#' library(gcamjobs)
#' gcamjobs::capacity (1,1)
#' }

capacity <- function(fig_dir = NULL,
                     prj_data = NULL,
                     input_dir = getwd()) {
  #.........................
  # Initialize
  #.........................

  rlang::inform("Starting capacity...")

  #.........................
  # Run Function
  #.........................

  output = NULL

  rlang::inform("reading prj...")
  prj <- rgcam::loadProject(paste0(input_dir, "/", prj_data))
  scenarios <- rgcam::listScenarios (prj)
  queries = rgcam::listQueries(prj)

  #.........................
  # Saving outputs
  #.........................
  output = list(scenarios=scenarios,
                queries = queries)


  #.........................
  # Close out
  #.........................


  rlang::inform("capacity complete.")

  return(output)

}
