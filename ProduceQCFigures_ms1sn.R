########### This is an R script to produce the figures that are attached to the qcML format
### MS1 S/N
###########

#options
options(digits=10)

file1<-commandArgs(TRUE)[1] #RICs with S/N column
post<-commandArgs(TRUE)[2]
png(post)
#file1<-"exampledata/QCRIC.tsv"

QCRIC <- read.csv(file=file1,head=TRUE,sep="\t")
######################################
require(ggplot2)

ggplot(QCRIC, aes(x=S.N)) + 
  geom_histogram(aes(y=..density..),      # Histogram with density instead of count on y-axis
                 binwidth=.5,
                 colour="black", fill="white") +
  geom_density(alpha=.1, fill="green") + # Overlay with transparent density plot
  geom_vline(aes(xintercept=median(S.N, na.rm=TRUE)),   # Ignore NA values for mean
             color="red", linetype="dashed", size=1) + 
  geom_text(aes(median(S.N, na.rm=TRUE),Inf,label = paste("median=",format(median(S.N, na.rm=TRUE),digits=3),sep=""), hjust = "left", vjust = "top")) +
  scale_y_continuous(expand=c(0, 0)) +
  scale_x_continuous(expand=c(0, 0), limits = c(0,50)) +
  xlab(expression("S/N")) +
  ggtitle(expression("MS1 S/N distribution"))

######################################
dev.off()
#
#
#