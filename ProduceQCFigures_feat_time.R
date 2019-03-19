#################### This is an R script to produce the figures that are attached to the qcML format
###Feature histogram
####################

#options
options(digits=10)

file<-commandArgs(TRUE)[1]
post<-commandArgs(TRUE)[2]
png(post)
#file<-"exampledata/QCFEAT.tsv"

QCFEAT<-read.csv(file=file,head=TRUE,sep="\t")
######################################
require(scales)
require(ggplot2)
require(chron)

QCFEAT$datetime <- as.POSIXct(as.character(0),format="%S", tz='CEST')+QCFEAT$RT
Sys.setenv(TZ='CEST')
QCFEAT$time <- times(format(QCFEAT$datetime, "%H:%M:%S"))

#ggplot(data=QCFEAT, aes(x=time)) + 
#  scale_x_chron(format ="%H:%M", n=10, expand=c(0,0)) +
#  geom_histogram(colour="black", fill="white") + 
#  ylab("Count")

ggplot(QCFEAT, aes(x=time)) + 
  geom_histogram(aes(y=..density..), colour="black", fill="white") +  
  scale_x_chron(format ="%H:%M", n=10, expand=c(0,0)) +
  scale_y_continuous(expand=c(0, 0)) +
  geom_density(alpha=.1, fill="green") +
  xlab("Time") +
  ylab("Density") +
  ggtitle("Feature distribution over time")
######################################
dev.off()
#
#
#
#
#
