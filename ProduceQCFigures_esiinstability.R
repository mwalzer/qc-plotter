################## This is an R script to produce the figures that are attached to the qcML format
###ESI instability
##################

#options
options(digits=10)

file1<-commandArgs(TRUE)[1] #ids
post<-commandArgs(TRUE)[2]
png(post)
#file1<-"exampledata/Freiburg_old1/QCRIC.tsv"

QCRIC <- read.csv(file=file1,head=TRUE,sep="\t")
######################################
require(scales)
require(ggplot2)
require(chron)
require(dplyr)

aa=100:1
bb=sin(aa/3)
cc=aa*bb
findPeaks <-function (x, thresh = 0) 
{
  pks <- which(diff(sign(diff(x, na.pad = FALSE)), na.pad = FALSE) < 0) + 2
  if (!missing(thresh)) {
    pks[x[pks - 1] - x[pks] > thresh]
  }
  else pks
}
findPeaks(cc)
findSteepJumps <-function (x, fact = 10) 
{
  pks <- which(diff(sign(diff(x, na.pad = FALSE)), na.pad = FALSE) < 0) + 2
  if (!missing(fact)) {
    pks[x[pks - 1]*fact < x[pks]]
  }
  else pks
}
findSteepJumps(cc)
findSteepDrops <-function (x, fact = 10) 
{
  pks <- which(diff(sign(diff(x, na.pad = FALSE)), na.pad = FALSE) < 0) + 2
  if (!missing(fact)) {
    pks[x[pks - 1]*fact > x[pks]]
  }
  else pks
}
findSteepDrops(cc)

# see also https://www.r-bloggers.com/change-point-detection-in-time-series-with-r-and-tableau/


QCRIC$datetime <- as.POSIXct(as.character(0),format="%S", tz='CEST')+QCRIC$MS.1000894_.sec.
QCRIC$time <- times(format(QCRIC$datetime, "%H:%M:%S"))
QCRIC$Type <- "RIC"
QCRIC$drops <- 0
QCRIC[findSteepDrops(QCRIC$MS.1000285),]$drops <- -1  # IS-1A
metA <- QCRIC %>% group_by(drops) %>% summarise()
QCRIC[findSteepJumps(QCRIC$MS.1000285),]$drops <- 1  # IS-1B
ggplot(data=QCRIC, aes(x=time, y=MS.1000285)) +
  geom_line(aes(colour = drops)) +
  scale_x_chron(format ="%H:%M", n=10, expand=c(0,0)) +
  scale_y_continuous(expand=c(0, 0)) +
  ylab("Intensity") +
  xlab("Time") +
  theme(plot.margin = unit(c(.1,1,.1,.1), "cm")) +
  ggtitle("ESI instability")

######################################
dev.off()
#
#
#