######################## This is an R script to produce the figures that are attached to the qcML format
###TopN sampling spacing
########################

#options
options(digits=10)

file1<-commandArgs(TRUE)[1] #ids
file2<-commandArgs(TRUE)[2] #precs
post<-commandArgs(TRUE)[3]
png(post)
#file1<-"exampledata/Freiburg_old1/QCRIC.tsv"
#file2<-"exampledata/Freiburg_old1/QCPREC.tsv"

QCRIC <- read.csv(file=file1,head=TRUE,sep="\t")
QCPREC <- read.csv(file=file2,head=TRUE,sep="\t")
######################################
require(scales)
require(ggplot2)
require(chron)

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

names(QCPREC) <- c('RT','MZ','Charge')[0:ncol(QCPREC)]  # Charge column is absent in old exports from qcML
names(QCRIC) <- c('RT','Int')

QCPREC <- QCPREC[0:3]
QCRIC <- QCRIC[0:2]


QCRIC$datetime <- as.POSIXct(as.character(0),format="%S", tz='CEST')+QCRIC$RT
QCTOP<-merge(x = QCRIC, y = QCPREC, by.x = "RT", by.y = "RT",  all=TRUE)
Sys.setenv(TZ='CEST')

QCTOP$cons <- !is.na(QCTOP$MZ)
QCTOP$topn <- cumul_trues(QCTOP$cons)

ggplot(data=QCTOP, aes(x=topn)) + 
  geom_histogram(binwidth = 1, origin=-0.5, colour="black", fill="white") + 
  ylab("Count") + 
  xlab("TopN sampling") + 
  scale_x_continuous(breaks=0:max(QCTOP$topn)) +
  scale_y_continuous(expand=c(0, 0)) + 
  ggtitle("TopN spacing")
######################################
dev.off()
#
#
#