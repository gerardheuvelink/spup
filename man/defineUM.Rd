% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/defineUM.R
\name{defineUM}
\alias{defineUM}
\title{Define an uncertainty model for a single input.}
\usage{
defineUM(uncertain = TRUE, distribution = NULL, distr_param = NULL, 
                 categories = NULL, cat_prob = NULL, crm = NULL,
                 id = NULL, cross_ids = NULL, ...)
}
\arguments{
\item{uncertain}{"TRUE" or "FALSE", determines if specification of
Uncertainty Model (UM) is needed.}

\item{distribution}{a string specified which distribution to sample from.
See Details for a list of supported distributions.}

\item{distr_param}{a vector or a list with distribution parameters. For example, for 
normal distribution in spatial variable this must be a map of means and a map
of standard deviations.}

\item{crm}{a correlogram model, object of a class "SpatialCorrelogramModel",
output of makecormodel(). Can only be specified for numerical variables.}

\item{categories}{a vector of categories}

\item{cat_prob}{data frame or spatial data frame; A list of probabilities for the vector of categories. 
Number of columns in the data frame cannot be smaller than number of categories.}

\item{id}{identifier of the variable; only in ude if the UM defined here 
is going to be used in defineUM() to construct joint UM for numerical variables.}

\item{...}{additional parameters}
}
\value{
Object of a class "Marginal"A list of all necessary information for creating realizations of
the uncertain variable.
}
\description{
Function that allows user to define marginal uncertainty distributions 
for model inputs and subsequent Monte Carlo analysis.
}
\details{
\strong{uncertain} If "TRUE" the uncertainty model for the input has to be
specified. If uncertain ="FALSE" the function requires a mean value of a
distribution, e.g. a scalar, a vector, or a map.

The spatial object must contain a map of mean and standard deviation. If crm
is provided and spatial correlation between the residuals is assumed only
the normal distribution of residuals is allowed.

If no spatial correlations between residuals is assumed, allowed
distributions for marginal uncertainty models are listed in Table 1.

Add bit about that only parametric are allowed to sample from both discrite
and continuos...



Table 1 Parametric probability models allowed in defineUM().
\tabular{rlllll}{ \tab \strong{Numeric type} \tab \strong{Distribution} \tab
\strong{Syntax} \tab \strong{Parameters} \tab \strong{Description} \cr \tab
Continuous \tab Beta \tab "beta" \tab c(\eqn{\alpha}, \eqn{\beta}) \tab
Shape parameters \eqn{\alpha} > 0, \eqn{\beta} > 0 \cr \tab Continuous \tab
Cauchy \tab \tab \tab \cr \tab Continuous \tab Chi-squared \tab \tab \tab
\cr \tab Continuous \tab Continuous uniform \tab \tab \tab \cr \tab
Continuous \tab Exponential \tab \tab \tab \cr \tab Continuous \tab Gamma
\tab \tab \tab \cr \tab Continuous \tab \tab \tab \tab

}
}
\examples{

# define uncertainty model for spatial numerical variable
data(DEM)
dem_crm <- makecrm(acf0 = 0.78, range = 321, model = "Exp")
demUM <- defineUM(uncertain = TRUE, distribution = "norm",
                   distr_param = c(dem30m, dem30m_sd), crm = dem_crm)
class(demUM)
                   
# define uncertainty model for spatial categorical variable
data(house)
houseUM <- defineUM(uncertain = TRUE, categories = c(0.19, 0), cat_prob = houses_DF)
class(houseUM)

# define uncertainty model for a variable desribed by a scalar
scalarUM <- defineUM(uncertain = TRUE, distribution = "gamma", distr_param = c(1,2))
class(scalarUM)

# define uncertainty model for two spatial cross-correlated variables
data(Madagascar)

OC_crm <- makecrm(acf0 = 0.6, range = 1000, model = "Sph")
OC_UM <- defineUM(TRUE, distribution = "norm", distr_param = c(OC, OC_sd), crm = OC_crm, id = "OC")
class(OC_UM)

TN_crm <- makecrm(acf0 = 0.4, range = 1000, model = "Sph")
TN_UM <- defineUM(TRUE, distribution = "norm", distr_param = c(TN, TN_sd), crm = TN_crm, id = "TN")
class(TN_UM)
  
}
\author{
Kasia Sawicka, Gerard Heuvelink
}

