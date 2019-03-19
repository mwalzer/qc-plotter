############ This is an R script to produce the figures that are attached to the qcML format
###ID lengths
############

#options
options(digits=10)

file1<-commandArgs(TRUE)[1] #ids
post<-commandArgs(TRUE)[2]
png(post)

#file1<-"exampledata/QCID.tsv"
QCID <- read.csv(file=file1,head=TRUE,sep="\t")
##########################
library(ggplot2)
library(scales)

names(QCID) <- c('RT','MZ', 'Score', 'PeptideSequence', 'Charge', 'TheoreticalWeight', 'deltaPPM', 'Oxidation(M)')[0:ncol(QCID)]  # Qxidation(M) is absent in new exports from qcML (deprecated)
QCID$Length <- nchar(gsub("\\([^(]*\\)", "", QCID$PeptideSequence))
ggplot(data=QCID, aes(x=Length)) + 
  geom_histogram(binwidth = 1, origin = -0.5, colour="black", fill="white") + 
  ylab("Count") + 
  geom_vline(data=QCID, aes(xintercept=mean(Length)), linetype="dashed", size=1, colour="red") +
  geom_text(aes(mean(Length),Inf,label = paste("mean=",format(mean(Length),digits=5),sep=""), hjust = "left", vjust = "top")) +
  scale_x_continuous(expand=c(0.005, 0)) +
  scale_y_continuous(expand=c(0, 0)) + 
  labs(title = "Length distribution of identified peptide sequences")
######################################
dev.off()
