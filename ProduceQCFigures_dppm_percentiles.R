################ This is an R script to produce the figures that are attached to the qcML format
###Mass accuracy percentiles
################

#options
options(digits=10)

file1<-commandArgs(TRUE)[1] #ids
post<-commandArgs(TRUE)[2]
png(post)
#file1<-"exampledata/QCID.tsv"

QCID <- read.csv(file=file1,head=TRUE,sep="\t")
######################################
require(ggplot2)

names(QCID) <- c('RT','MZ', 'Score', 'PeptideSequence', 'Charge', 'TheoreticalWeight', 'deltaPPM', 'Oxidation(M)')[0:ncol(QCID)]  # Qxidation(M) is absent in new exports from qcML (deprecated)
QCID$error <- QCID$MZ- QCID$TheoreticalWeight
QCID$abserr <- abs(QCID$MZ- QCID$TheoreticalWeight)
#QCID <- QCID %>% mutate(error = MZ - TheoreticalWeight, abserr = abs(MZ-TheoreticalWeight))

MS15A	<- median(QCID$error)
MS15B	<- mean(QCID$abserr)
MS15C	<- median(QCID$deltaPPM)
MS15D	<- IQR(QCID$deltaPPM)

ctext <- data.frame(c(MS15A,MS15B,MS15C,MS15D))
rownames(ctext) <- c("MS1-5A","MS1-5B","MS1-5C","MS1-5D")
colnames(ctext) <-"Metric value"
footnote <- paste(capture.output(ctext), collapse="\n") 

ggplot(QCID, aes(x=deltaPPM)) + 
  geom_histogram(aes(y=..density..),      # Histogram with density instead of count on y-axis
                 binwidth=.5,
                 colour="black", fill="white") +
  geom_density(alpha=.1, fill="green") + # Overlay with transparent density plot
  geom_vline(aes(xintercept=median(deltaPPM, na.rm=TRUE)),   # Ignore NA values for mean
             color="red", linetype="dashed", size=1) + 
  geom_text(aes(median(deltaPPM, na.rm=TRUE),Inf,label = paste("median=",format(median(deltaPPM, na.rm=TRUE),digits=3),sep=""), hjust = "right", vjust = "top")) +
  scale_y_continuous(expand=c(0, 0)) +
  scale_x_continuous(expand=c(0, 0), limit=c(-10,10)) +
  xlab(expression(paste(Delta, " ppm"))) +
  geom_text(aes(x=Inf,y=Inf,hjust=1.1,vjust=1.1,label=footnote), family="Courier", colour="black") +
  ggtitle(expression(paste(Delta, " ppm distribution")))

######################################
dev.off()
#
#
#