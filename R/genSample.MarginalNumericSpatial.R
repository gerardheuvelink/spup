#' Generating Monte Carlo sample from an uncertain object of a class 
#' 'NumMarSpatial'
#'
#' Function that runs Monte Carlo simulations depending on the type of
#' uncertain object. Facilitates unconditional gausian simulation of errors for
#' spatially auto-correlated residulas, and random sampling, stratified
#' sampling if no spatial auto-correlation is included.
#'
#'
#' \strong{"ugs"} Unconditional gaussian simulation of spatially
#' auto-correlated errors.
#'
#' \strong{"stratifiedSampling"} Number of samples (n) must be dividable by the
#' number of quantiles to assure each quantile is evenly represented.
#'
#' \strong{"lhs"} Sampling method for at least two uncertain inputs. The
#' uncertain.object is then a list of two or more. It uses startified sampling
#' method to generate the inputs for the latin hypercude algorithm, hence the p
#' is restricted as above.
#'
#' @usage genSample(UMobject, n, samplemethod, p = 0, ...)
#'
#' @param UMobject uncertain object defined using defineUMs().
#' @param n Integer. Number of Monte Carlo realizations.
#' @param samplemethod "ugs" for spatially correlated errors, "randomSampling" and
#' "stratifiedSampling" if no spatial correlation of errors is
#' considered.
#' @param p A vector of quantiles. Optional. Only required if sample method is
#' "stratifiedSampling" or "lhs".
#' @param var Logical. Specifies if variance for X realizations should be also returned.
#' @param ...  Additional parameters that may be passed, e.g. in
#' the "ugs" method. See examples.
#' 
#' @return A Monte Carlo sample of uncertain input of a class of distribution
#' parameters.
#' 
#' @author Kasia Sawicka, Stefan van Dam, Gerard Heuvelink
#' 
#' @examples
#'
#' # load data
#' data(DEM)
#' 
#' # "ugs" method example
#' dem_crm <- makecrm(acf0 = 0.78, range = 321, model = "Exp")
#' demUM <- defineUMs(uncertain = TRUE, distribution = "norm", 
#'                    distr_param = c(dem30m, dem30m_sd), crm = dem_crm)
#' dem_sample <- genSample(UMobject = demUM, n = 5, samplemethod = "ugs", nmax = 20)
#' str(dem_sample)
#'
#' # "randomSampling" method example
#' demUM <- defineUMs(uncertain = TRUE, distribution = "norm", distr_param = c(dem30m, dem30m_sd))
#' dem_sample <- genSample(UMobject = demUM, n = 5, samplemethod = "randomSampling")
#' str(dem_sample)
#' 
#' demUM <- defineUMs(uncertain = TRUE, distribution = "beta", distr_param = c(dem30m, dem30m_sd, dem30m))
#' dem_sample <- genSample(UMobject = demUM, n = 5, samplemethod = "randomSampling")
#' str(dem_sample)
#'
#' # "startifiedSampling" method example
#' demUM <- defineUMs(uncertain = TRUE, distribution = "norm", distr_param = c(dem30m, dem30m_sd))
#' dem_sample <- genSample(UMobject = demUM, n = 5, samplemethod = "stratifiedSampling", p = 0:5/5)
#' str(dem_sample)
#'
#' @export
genSample.MarginalNumericSpatial <- function(UMobject, n, samplemethod, p = 0, ...) {
  
  stopifnot(UMobject$uncertain == TRUE)
  distribution <- UMobject[[2]]
  distr_param <- UMobject[[3]]
  crm <- UMobject[[4]]
  dots <- list(...)
  
  ### UGS ----------------------------------------------------------------------------
  if (samplemethod == "ugs") { 
    if (is.null(crm))
      stop("Correlogram model is required for the 'ugs' sampling method.")
    if (distribution != "norm")
      stop("Only normal distribution can be assumed in the 'ugs' method.")
    for (i in 1:2) {
      assign(paste0("distr_param", i), distr_param[[i]])
    }
    mask <- distr_param1
    g <- gstat::gstat(formula = z~1, # locations = ~x+y, # KS: is it always x and y?
               dummy = TRUE, beta = 0, model = crm2vgm(crm), ...)
    epsilon_sample <- predict(object = g, newdata = mask, nsim = n)
    X_sample <- epsilon_sample
    # if it is Spatial data frame
    X_sample@data <- as.data.frame(apply(as.matrix(epsilon_sample@data), MARGIN = 2,
                                  function(x) distr_param1@data + distr_param2@data*x))
    names(X_sample@data) <- paste("sim", c(1:n), sep = "")

    # What if it is a raster? How to generate epsilon sample if it is a raster?
    # Convert to spatial grid data frame and back is only thing I can think of.
    
    # here if var = TRUE - return variance of X realizations
  } 
  
  ### RANDOM SAMP ---------------------------------------------------------------------
  if (samplemethod == "randomSampling") {
    if (class(distr_param[[1]]) != "RasterLayer") { # so all other spatial classes
      in1df <- do.call("cbind", distr_param)
      in1mtx <- as.matrix(in1df@data)
      ds <- function(x) {
        parameters <- x
        distribution_sampling(n, distribution, parameters)
      }
      temp_samples <- t(apply(in1mtx, MARGIN = 1, ds))
      X_sample <- distr_param[[1]]
      X_sample@data <- as.data.frame(temp_samples)
      names(X_sample@data) <- paste("sim", c(1:n), sep = "")
    } else {
      print("what with Raster?")
    }
  }
  
  ### STRATIFIED SAMP ------------------------------------------------------------------
  if (samplemethod == "stratifiedSampling") {
    if (distribution != "norm")
      stop("stratified sampling in current version is supported only for normal distribution")
    if (n %% (length(p)-1) != 0)
      stop("n should be divisable by the number of strata")
    if (class(distr_param[[1]]) != "RasterLayer") {
      in1df <- do.call("cbind", distr_param)
      in1mtx <- as.matrix(in1df@data)  
      stsS <- function(x) {
        parameters <- x
        mu <- parameters[1]
        sigma <- parameters[2]
        as.numeric(stratsampSpatial(mu, sigma, n/(length(p)-1), p))
      }
      temp_samples <- t(apply(in1mtx, MARGIN = 1, stsS))
      X_sample <- distr_param[[1]]
      X_sample@data <- as.data.frame(temp_samples)
      names(X_sample@data) <- paste("sim", c(1:n), sep = "")
    } else {
      print("what with Raster?")
    }  
  }
  X_sample
} 
