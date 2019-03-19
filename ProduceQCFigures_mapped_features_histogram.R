################################# This is an R script to produce the figures that are attached to the qcML format
###IDs on rt/mz map vs precursors
#################################

#options
options(digits=10)

file1<-commandArgs(TRUE)[1] #feats
post<-commandArgs(TRUE)[2]
png(post)
file1<-"exampledata/QCFEAT.tsv"

QCFEAT <- read.csv(file=file1,head=TRUE,sep="\t")
######################################
require(scales)
require(ggplot2)
require(chron)

##########################
names(QCFEAT) <- c('MZ','RT', 'Intensity', 'Charge', 'Quality', 'FWHM', 'IDs')
QCFEAT$widthbin <- findInterval(QCFEAT$FWHM, seq(1:10))

ggplot(data=QCFEAT, aes(as.factor(IDs), fill=factor(widthbin))) + 
  geom_bar() +
  ylab("Count") + 
  xlab("IDs mapped") + 
  scale_y_continuous(expand=c(0, 0))  + 
  scale_fill_discrete(name="Feature FWHM bins\n(increasing width)") + 
  ggtitle("Features with mapped identifications")

######################################
dev.off()
#
#
#