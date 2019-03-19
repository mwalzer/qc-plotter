## This is an R script to produce the figures that are attached to the qcML format

#options
options(digits=10)

file<-commandArgs(TRUE)[1]
post<-commandArgs(TRUE)[2]
png(post)

#file<-"exampledata/QCID.tsv"
QCID <- read.csv(file=file,head=TRUE,sep="\t")
##########################
###Mass accuracy
##########################
library(ggplot2)
library(scales)
require(chron)

aa <- c("I","V","L","F","C","M","A","G","T","W","S","Y","P","H","E","Q","D","N","K","R")
hi <- c(4.5,4.2,3.8,2.8,2.5,1.9,1.8,-0.4,-0.7,-0.9,-0.8,-1.3,-1.6,-3.2,-3.5,-3.5,-3.5,-3.5,-3.9,-4.5)
gravy <- data.frame(aa,hi)
names(gravy) <- c("aminoacid",	"hydropathyindex")

names(QCID) <- c('RT','MZ', 'Score', 'PeptideSequence', 'Charge', 'TheoreticalWeight', 'deltaPPM', 'Oxidation(M)')[0:ncol(QCID)]  # Qxidation(M) is absent in new exports from qcML (deprecated)

Sys.setenv(TZ='CEST')
QCID$datetime <- as.POSIXct(as.character(0),format="%S", tz='CEST')+QCID$RT
QCID$time <- times(format(QCID$datetime, "%H:%M:%S"))

QCID$unmod <- gsub("\\([^(]*\\)", "", QCID$PeptideSequence)
QCID$gravy <- sapply(QCID$unmod,function(s){ sum(sapply(unlist(strsplit(s,'')), function(t){ gravy$hydropathyindex[which(gravy$aminoacid==t)]} ))/nchar(s) })

#ggplot(data=QCID, aes(x=gravy)) + 
#  geom_histogram(colour="black", fill="white") + 
#  ylab("Count") + 
#  geom_vline(data=QCID, aes(xintercept=mean(gravy)), linetype="dashed", size=1, colour="red") +
#  geom_text(aes(mean(gravy),Inf,label = paste("mean=",format(mean(gravy),digits=5),sep=""), hjust = "left", vjust = "top"))

ggplot(data=QCID, aes(x=time , y=gravy)) + 
  scale_x_chron(format ="%H:%M", n=10, expand=c(0,0)) +
  geom_point(alpha=0.5) + ylim(c(-3,3)) + 
  geom_line(y=0, colour="blue") + 
  stat_smooth(colour="red", method=loess, span=1/5) +
  ggtitle("Hydropathy index of identified peptides over retention time") +
  xlab("Time") +
  ylab("Gravy")

######################################
dev.off()
