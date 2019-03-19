###### This is an R script to produce the figures that are attached to the qcML format
###TIC
######

#options
options(digits=10)

file<-commandArgs(TRUE)[1]
post<-commandArgs(TRUE)[2]
#file<-"exampledata/QCTIC.tsv"

QCTIC<-read.csv(file=file,head=TRUE,sep="\t")
png(post)
######################################
require(scales)
require(ggplot2)
require(chron)

QCTIC$datetime <- as.POSIXct(as.character(0),format="%S", tz='CEST')+QCTIC$MS.1000894_.sec.
Sys.setenv(TZ='CEST')
QCTIC$time <- times(format(QCTIC$datetime, "%H:%M:%S"))
ggplot(data=QCTIC, aes(x=time, y=MS.1000285)) +
  geom_line() +
  scale_x_chron(format ="%H:%M", n=10, expand=c(0,0)) +
  scale_y_continuous(expand=c(0, 0)) +
  ylab("Intensity") +
  xlab("Time") +
  theme(plot.margin = unit(c(.1,1,.1,.1), "cm"))

#scale_x_datetime works as well after setting the time zone environment equal to the posix datetime
#ggplot(data=QCTIC, aes(x=datetime, y=MS.1000285)) + geom_line() + scale_x_datetime(breaks=date_breaks("15 min"), labels=date_format("%H:%M")) + ylab("Intensity") +xlab("Time")
######################################
dev.off()
#
#
#