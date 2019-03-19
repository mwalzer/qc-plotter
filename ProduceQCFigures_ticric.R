###### This is an R script to produce the figures that are attached to the qcML format
###TIC
######

#options
options(digits=10)

file1<-commandArgs(TRUE)[1]
file2<-commandArgs(TRUE)[2]
post<-commandArgs(TRUE)[3]
png(post)

#file1<-"exampledata/Freiburg_old1/QCTIC.tsv"
#file2<-"exampledata/Freiburg_old1/QCRIC.tsv"
QCTIC<-read.csv(file=file1,head=TRUE,sep="\t")
QCRIC<-read.csv(file=file2,head=TRUE,sep="\t")
######################################
require(scales)
require(ggplot2)
require(chron)

Sys.setenv(TZ='CEST')
QCTIC$datetime <- as.POSIXct(as.character(0),format="%S", tz='CEST')+QCTIC$MS.1000894_.sec.
QCTIC$time <- times(format(QCTIC$datetime, "%H:%M:%S"))
QCRIC$datetime <- as.POSIXct(as.character(0),format="%S", tz='CEST')+QCRIC$MS.1000894_.sec.
QCRIC$time <- times(format(QCRIC$datetime, "%H:%M:%S"))
QCRIC$Type <- "RIC"
QCTIC$Type <- "TIC"

ggplot(data=QCTIC, aes(x=time, y=MS.1000285)) +
  geom_line(aes(colour = Type)) +
  scale_x_chron(format ="%H:%M", n=10, expand=c(0,0)) +
  scale_y_continuous(expand=c(0, 0)) +
  ylab("Intensity") +
  xlab("Time") +
  theme(plot.margin = unit(c(.1,1,.1,.1), "cm")) +
  geom_line(data=QCRIC, aes(x=time, y=MS.1000285,colour=Type),alpha=.5) +
  ggtitle("TIC and RIC")

######################################
dev.off()
#
#
#