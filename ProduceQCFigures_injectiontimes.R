################### This is an R script to produce the figures that are attached to the qcML format
###Charge histogram
###################

#options
options(digits=10)

file1<-commandArgs(TRUE)[1] #ids
file2<-commandArgs(TRUE)[2] #precs
file3<-commandArgs(TRUE)[3] #inj
post<-commandArgs(TRUE)[4]
png(post)

file1<-"exampledata/Freiburg_old1/QCRIC.tsv"
file2<-"exampledata/Freiburg_old1/QCPREC.tsv"
file3<-"exampledata/Freiburg_old1/QCINJ.tsv"

QCRIC <- read.csv(file=file1,head=TRUE,sep="\t")
QCPREC <- read.csv(file=file2,head=TRUE,sep="\t")
QCINJ <- read.csv(file=file3,head=TRUE,sep="\t")
######################################
require(scales)
require(ggplot2)
require(chron)
require(dplyr)
##########################
names(QCPREC) <- c('RT','MZ','Charge')[0:ncol(QCPREC)]  # Charge column is absent in old exports from qcML
names(QCINJ) <- c('RT','Ioncollection')
names(QCRIC) <- c('RT','Intensity')

#Sys.setenv(TZ='CEST')
#QCID$datetime <- as.POSIXct(as.character(0),format="%S", tz='CEST')+QCID$RT
#QCID$time <- times(format(QCID$datetime, "%H:%M:%S"))

QCTOP<-merge(x = QCPREC, y = QCINJ, by.x =c("RT"), by.y =c("RT"),  all=TRUE)
QCTOP<-merge(x = QCTOP, y = QCRIC, by.x =c("RT"), by.y =c("RT"),  all=TRUE)

cumul_trues <- function(x)  {
  rl <- rle(x)
  len <- rl$lengths
  v <- rl$values
  cumLen <- cumsum(len)
  z <- x
  # replace the 0 at the end of each zero-block in z by the 
  # negative of the length of the preceding 1-block....
  iDrops <- c(0, diff(v)) < 0
  z[ cumLen[ iDrops ] ] <- -len[ c(iDrops[-1],FALSE) ]
  # ... to ensure that the cumsum below does the right thing.
  # We zap the cumsum with x so only the cumsums for the 1-blocks survive:
  x*cumsum(z)
}

max_trues <- function(x)  {
  his <- c()
  v <- 0
  for (i in 2:length(x)) {
    if (x[i]>0){
      v<-x[i]
    }
    else{
      his<-c(his,v)
      v<-0
    }
  }
  his <- c(his,v)
}

QCTOP$cons <- !is.na(QCTOP$MZ)
QCTOP$topn <- cumul_trues(QCTOP$cons)

#correl. topn spacing with fill time?
#take max in each duty cycle and plot against RT together with fill time

Sys.setenv(TZ='CEST')
QCTOP$datetime <- as.POSIXct(as.character(0),format="%S", tz='CEST')+QCTOP$RT
QCTOP$time <- times(format(QCTOP$datetime, "%H:%M:%S"))
test <- QCTOP %>% filter(!is.na(Ioncollection))

m <- mean(test$Ioncollection,rm.na=TRUE)
footnote <- paste("mean injection time ~",format(m,digits = 3), "ms", sep = " " )

ggplot(test) +
  geom_line(aes(y=Ioncollection,x=time)) +
  scale_x_chron(format ="%H:%M", n=10, expand=c(0,0)) +
  scale_y_continuous(expand=c(0, 0),limits = c(0,max(test$Ioncollection)+5)) +
  xlab("RT [HH:MM:SS]") +
  ylab("ion injection time [ms]") +
  stat_smooth(aes(y=Ioncollection,x=time),colour="red", method=loess, span=1/5) +
  geom_text(aes(x=Inf,y=Inf,hjust=1.1,vjust=1.1,label=footnote), family="Courier") + 
  ggtitle("Ion Injection Time over RT")
  
######################################
dev.off()
#
#
#