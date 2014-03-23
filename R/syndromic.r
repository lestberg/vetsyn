##' Class \code{"syndromic"}
##'
##' Main class of the package, stores syndromic surveillance objects.
##'
##'
##' The \code{syndromic} class stores observed data in a format appropriate
##' for monitoring, and contains several slots to store  input and outputs of 
##' analysis (temporal monitoring).
##' Functions are available to create an object of the class syndromic from data 
##' already cleaned and prepared for monitoring, or alternatively from raw observed data.
##' 
##' @section Slots:
##' \describe{
##'   \item{observed}{
##'     A \code{matrix} with the number of rows equal to the number of time points available
##' (p.e. the number of days of observed data); and number of columns equal to the number of 
##' syndromes monitored.
##'   }
##'   \item{dates}{
##'     A \code{DataFrame} which first column contains the dates corresponding to the observations
##' recorded. Additional columns contain additional information extracted from the date,
##' such as day-of-the-week, month, holidays, etc.
##'   }
##'   \item{baseline}{
##'   A \code{matrix} of dimensions exactly equal to the slot @observed, where observed data has been 
##'   cleaned in order to remove excess noise and/or outbreak signals, generating an outbreak-free
##'   time series that should be used as baseline for the detection algorithms.     
##'   }
##'   \item{alarms}{
##'     An \code{array} containing the results of the outbreak-signal detection algorithms, for each
##'     of the time series being monitored (columns in @observed). Alarms
##'     can be registered as binary values (0 for no alarm and 1 for alarm) or as a ordinal value 
##'     representing an alarm level (for instance 0-5). The first and second dimensions (rows and columns) 
##'     correspond to the dimensions of the time series monitored, but a third dimension can be added when
##'     multiple detection algorithms are used.
##'   }
##'   \item{UCL}{
##'     An \code{array} containing the upper confidence limit (UCL) of the 
##'     outbreak-signal detection algorithms, 
##'     for each of the time series being monitored (columns in @observed).  
##'     The first and second dimensions (rows and columns) correspond to the dimensions of the 
##'     time series monitored, but a third dimension can be added when 
##'     multiple detection algorithms are used. Whether an alarm is registered or not, 
##'     this dimension can be used to record the minimum number that would have generated an alarm.
##'   }
##'   \item{LCL}{
##'     An \code{array} containing the lower confidence limit (LCL) of the outbreak-signal 
##'     detection algorithms, for each of the time series being monitored
##'      ( columns in @observed), when detection is based
##'     (also) on the detection of decreases in the number of observations.
##'      The first and second dimensions (rows and columns) 
##'     correspond to the dimensions of the time series monitored, 
##'     but a third dimension can be added when
##'     multiple detection algorithms are used. Whether an alarm is registered or not, 
##'     this dimension can be used
##'     to record the maximum number that would have generated an alarm.
##'   }
##'   }
##'   
##' @name syndromic-class
##' @docType class
##' @section Objects from the Class: Objects can be created by calls of the
##' form \code{syndromic(observed, dates, ...)}
##' @keywords classes
##' @export
##' @aliases syndromic
##' @examples
##' ## Load data
##' data(observed)
##' my.syndromic <- syndromic(observed,min.date="01/01/2010",max.date="28/05/2013")
##' my.syndromic <- syndromic(observed[1:5,],min.date="01/01/2010",max.date="05/01/2010")
##' my.syndromic <- syndromic(observed[1:6,],min.date="01/01/2010",max.date="08/01/2010", 
##'                           weekends=FALSE) 
##' dates = seq(from=as.Date("01/01/2010",format ="%d/%m/%Y" ),
##'               to=as.Date("05/01/2010",format ="%d/%m/%Y" ), 
##'               by="days")
##' my.syndromic <- syndromic(observed[1:5,],dates=dates) 
##'
setClass('syndromic',
         representation(observed  = 'matrix',
                        dates     = 'data.frame',
                        baseline  = 'matrix',
                        alarms     = 'array',
                        UCL       = 'array',
                        LCL        = 'array'),
         validity = function(object) {
             retval <- NULL
             
             if(dim(object@observed)[1]==0) ({
               retval <- 'You cannot create a syndromic object without 
               supplying observed data'
             }) else ({
                     

             l1 <-dim(object@observed)[1]
             if(length(object@dates)>1L)    (l1 <- c(l1,dim(object@dates)[1]))
             if(length(object@baseline)>1L) (l1 <- c(l1,dim(object@baseline)[1]))
             if(length(object@alarms)>1L)   (l1 <- c(l1,dim(object@alarms)[1]))
             if(length(object@UCL)>1L)      (l1 <- c(l1,dim(object@UCL)[1]))
             if(length(object@LCL)>1L)      (l1 <- c(l1,dim(object@LCL)[1]))
             
             l2 <-dim(object@observed)[2]
             if(length(object@baseline)>1L) (l2 <- c(l2,dim(object@baseline)[2]))
             if(length(object@alarms)>1L)   (l2 <- c(l2,dim(object@alarms)[2]))
             if(length(object@UCL)>1L)      (l2 <- c(l2,dim(object@UCL)[2]))
             if(length(object@LCL)>1L)      (l2 <- c(l2,dim(object@LCL)[2]))
             
             l1 <- unique(l1)
             l2 <- unique(l2)
             
             if(!identical(length(l1), 1L)||!identical(length(l2), 1L)) {
                 retval <- 'Dimensions of observed, dates, 
                            baseline, alarms, UCL and LCL should be the same'
             }
                  })
         }
)



setAs(from='syndromic',
      to='data.frame',
      def=function(from)
  {
      if(dim(from@dates)[1] > 0L) ({
          df <- data.frame(dates=from@dates[,1],
                            from@observed)}) else ({
                           df <- data.frame(from@observed)
                            })
          return(df)
      }
   )



setAs(from='syndromic',
      to='matrix',
      def=function(from)
      {
        mtx <- from@observed                       
        return(mtx)
      }
)
