`getSplits` <-
function(Symbol,from='1970-01-01',to=Sys.Date(),env=parent.frame(),src='yahoo',
         auto.assign=FALSE,auto.update=FALSE,verbose=FALSE,...) {

  # Function written by Joshua Ulrich, using
  # getSymbols.yahoo as a guide.
  if(missing(env))
    env <- parent.frame(1)
  if(is.null(env))
    auto.assign <- FALSE
  Symbol.name <- ifelse(!is.character(Symbol),
                        deparse(substitute(Symbol)),
                        as.character(Symbol))

  yahoo.URL <- 'http://ichart.finance.yahoo.com/x?s='
  from.y <- as.numeric(strsplit(as.character(from), "-", )[[1]][1])
  from.m <- as.numeric(strsplit(as.character(from), "-", )[[1]][2])-1
  from.d <- as.numeric(strsplit(as.character(from), "-", )[[1]][3])
  to.y <- as.numeric(strsplit(as.character(to), "-", )[[1]][1])
  to.m <- as.numeric(strsplit(as.character(to), "-", )[[1]][2])-1
  to.d <- as.numeric(strsplit(as.character(to), "-", )[[1]][3])

  tmp <- tempfile()
  download.file(paste(yahoo.URL,Symbol.name, "&a=", 
            from.m, "&b=", sprintf("%.2d", from.d), "&c=", from.y, 
            "&d=", to.m, "&e=", sprintf("%.2d", to.d), "&f=", 
            to.y, "&g=v&y=0&z=30000", 
            sep = ""), destfile = tmp, quiet = !verbose)
  fr <- read.table(tmp, skip=1, fill=TRUE, as.is=TRUE, sep=",")
  unlink(tmp)
  fr <- fr[fr$V1=="SPLIT",]

  if(NROW(fr)==0) {
    fr <- NA
  } else {
    fr$V3 <- sub(":","/", fr$V3)
    fr$V3 <- 1 / sapply( parse( text=fr$V3 ), eval )
    fr <- xts(fr$V3, as.Date(as.character(fr$V2),"%Y%m%d"))
    colnames(fr) <- paste(Symbol.name,'spl',sep='.')
  }

  if(is.xts(Symbol)) {
    if(auto.update) {
      xtsAttributes(Symbol) <- list(splits=fr)
      assign(Symbol.name,Symbol,envir=env)
    }
  } else if(auto.assign) {
      assign(paste(Symbol.name,'spl',sep='.'),fr,envir=env)
  } else fr
}
