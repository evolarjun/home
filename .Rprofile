# see http://www.gettinggeneticsdone.com/2013/07/customize-rprofile.html
# http://www.onthelambda.com/2014/09/17/fun-with-rprofile-and-customizing-r-startup/


#if(Sys.getenv("TERM") == "xterm")
#  library("colorout")

options(stringsAsFactors=FALSE)
options(editor="vim")
options("repos" = c(CRAN = "https://cran.rstudio.com/"))

.First <- function() {
    # library(ggplot2)
    # library(dplyr)
    cat("\nSuccessfully loaded .Rprofile at", date(), "\n", file=stderr())
}

.Last <- function(){
  cat("\nGoodbye at ", date(), "\n", file=stderr())
  if(interactive()){
    hist_file <- Sys.getenv("R_HISTFILE")
        if (hist_file=="") 
            savehistory()
        else
            savehistory(hist_file)
#if(hist_file=="") hist_file <- "/home/aprasad/.RHistory"
#    savehistory(hist_file)
  }
}


# set up an environment so rm(list=ls()) doesn't nuke everything
if (!".env" %in% search()) { 
    .env <- new.env()

    .env$tabout <- function(x, filename, quote=F, row.names=F, sep="\t", rotate=TRUE, ...) {
	  old.filename <- filename
	  if (!rotate) {
		write.table(x, file=filename, quote=quote, row.names=row.names, sep=sep, ...)
		return(filename)
	  } else {
		n <- 1
		newfilename <- paste0(filename, '.', n)
		
		while (file.exists(newfilename)) {
		  n <- n + 1
		  newfilename <- paste0(filename, '.', n)
		}
		write.table(x, file=newfilename, quote=quote, row.names=row.names, sep=sep, ...)
		if (n > 1) {
		  x <- tools::md5sum(c(filename, newfilename))
		  if (!is.na(x[1]) & x[1] == x[2]) {
			# no change, so just return the previous max filename
			unlink(newfilename)
			return(paste0(filename, '.', n-1))
		  } else {
			if (file.exists(filename)) { file.remove(filename) }
			file.copy(newfilename, filename)
		  }
		} else {
		  file.copy(newfilename, filename)
		}
		return(newfilename)
	  }
	}


    .env$n_unique <- function(x) {
      y <- unique(x)
      y <- y[!is.na(y)]
      length(y)
    }

    .env$tabin <- function(filename, header=T, quote='', as.is=T, comment="", sep="\t", ...) {
        return(read.table(file=filename, sep=sep, header=header, quote=quote, as.is=as.is, comment=comment, ...))
    }
    .env$q <- function (save="no", ...) {
      quit(save=save, ...)
    }
    .env$"%nin%" <- function(x, y) { !(x %in% y) }

    .env$setwidth <- function() { options(width=system2('tput', 'cols', stdout=TRUE)) }

# get all my functions above into current namespace
    attach(.env)
}
