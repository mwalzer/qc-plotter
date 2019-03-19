################################# This is an R script to produce the figures that are attached to the qcML format
###IDs on rt/mz map vs precursors
#################################

#options
options(digits=10)

file1<-commandArgs(TRUE)[1] #ids
file2<-commandArgs(TRUE)[2] #precs
post<-commandArgs(TRUE)[3]
png(post)
#file1<-"exampledata/QCID.tsv"
#file2<-"exampledata/QCPREC.tsv"

QCID <- read.csv(file=file1,head=TRUE,sep="\t")
QCPREC <- read.csv(file=file2,head=TRUE,sep="\t")
######################################
require(scales)
require(ggplot2)
require(chron)

##########################
names(QCPREC) <- c('RT','MZ','Charge')[0:ncol(QCPREC)]  # Charge column is absent in old exports from qcML
names(QCID) <- c('RT','MZ', 'Score', 'PeptideSequence', 'Charge', 'TheoreticalWeight', 'deltaPPM', 'Oxidation(M)')[0:ncol(QCID)]  # Qxidation(M) is absent in new exports from qcML (deprecated)

Sys.setenv(TZ='CEST')
QCID$datetime <- as.POSIXct(as.character(0),format="%S", tz='CEST')+QCID$RT
QCID$time <- times(format(QCID$datetime, "%H:%M:%S"))
QCID$col <- "identified"
QCPREC$datetime <- as.POSIXct(as.character(0),format="%S", tz='CEST')+QCPREC$RT
QCPREC$time <- times(format(QCPREC$datetime, "%H:%M:%S"))
QCPREC$col <- "recorded"

IS2 <- median(QCID$MZ)
ctext <- data.frame(c(IS2))
rownames(ctext) <- c("IS-2")
colnames(ctext) <-"Metric value"
footnote <- paste(capture.output(ctext), collapse="\n") 

ggplot(QCPREC, aes(x=time, y=MZ,colour=col)) + 
  geom_point() + 
  scale_x_chron(format ="%H:%M", n=10, expand=c(0,0)) +
  scale_y_continuous(expand=c(0,0)) +
  ylab("MZ") +
  xlab("Time") +
  geom_point(data = QCID, aes(x=time, y = MZ, colour=col)) +
  theme(legend.title=element_blank()) +
  geom_text(aes(x=Inf,y=Inf,hjust=1.1,vjust=1.1,label=footnote), family="Courier", colour="black")

######################################
dev.off()
#
#
#