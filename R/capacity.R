#' capacity
#'
#' Function that sums two numbers
#'
#' @param fig_dir Default = NULL, Output folder for figures and maps.
#' @param prj_data Default = NULL, Gcam output data in "dat" format.
#' @keywords sum
#' @return number
#' @export
#' @examples
#' \dontrun{
#' library(gcamjobs)
#' gcamjobs::capacity (1,1)
#' }

capacity <- function(fig_dir = NULL,
                     prj_data = NULL) {
  #.........................
  # Initialize
  #.........................

  rlang::inform("Starting capacity...")

  #.........................
  # Run Function
  #.........................

  output = NULL

  rlang::inform("reading prj...")
  prj <- rgcam::loadProject(paste0(out_dir, "/", prj_data))
  scenarios <- listScenarios (prj)
  scenarios
  listQueries(prj)

  #.........................
  # Close out
  #.........................

  rlang::inform("capacity complete.")

  return(output)

}
