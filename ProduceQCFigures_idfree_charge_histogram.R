################### This is an R script to produce the figures that are attached to the qcML format
###Charge histogram
###################

#options
options(digits=10)


file1<-commandArgs(TRUE)[1] #precs
post<-commandArgs(TRUE)[2]
png(post)
#file1<-"exampledata/QCPREC.tsv"

QCPREC <- read.csv(file=file1,head=TRUE,sep="\t")
######################################
require(scales)
require(ggplot2)
require(chron)
require(dplyr)
##########################
names(QCPREC) <- c('RT','MZ','Charge')[0:ncol(QCPREC)]  # Charge column is absent in old exports from qcML

QCPREC <- QCPREC[0:3]

Sys.setenv(TZ='CEST')
QCPREC$datetime <- as.POSIXct(as.character(0),format="%S", tz='CEST')+QCPREC$RT
QCPREC$time <- times(format(QCPREC$datetime, "%H:%M:%S"))


QCPREC$Charge[is.na(QCPREC$Charge)] <- "?"
QCPREC$Charge <- as.factor(QCPREC$Charge)
sorted_labels <- paste(sort(as.integer(levels(QCPREC$Charge))))
QCPREC$Charge <- factor(QCPREC$Charge, levels = sorted_labels)

QCZsum <- QCPREC %>% group_by(Charge) %>% summarise(n=n())
c1n <- ifelse(nrow(QCZsum[QCZsum$Charge==1,])<1,as.numeric(NA), QCZsum[QCZsum$Charge==1,]$n)
c2n <- ifelse(nrow(QCZsum[QCZsum$Charge==2,])<1,as.numeric(NA), QCZsum[QCZsum$Charge==2,]$n)
c3n <- ifelse(nrow(QCZsum[QCZsum$Charge==3,])<1,as.numeric(NA), QCZsum[QCZsum$Charge==3,]$n)
c4n <- ifelse(nrow(QCZsum[QCZsum$Charge==4,])<1,as.numeric(NA), QCZsum[QCZsum$Charge==4,]$n)
IS3A <- c1n / c2n
IS3B <- c3n / c2n
IS3C <- c4n / c2n

ctext <- data.frame(c(IS3A,IS3B,IS3C))
rownames(ctext) <- c("IS-3A","IS-3B","IS-3C")
colnames(ctext) <-"Metric value"
footnote <- paste(capture.output(ctext), collapse="\n") 

ggplot(data=QCPREC, aes(x=Charge)) + 
  geom_bar(na.rm = TRUE) +
  ylab("Count") + 
  xlab("Charges") + 
  #scale_x_continuous(breaks=seq(0,max(QCZ$Charge, na.rm = TRUE),1),na.value = 0) +
  scale_y_continuous(expand=c(0, 0)) +
  theme(legend.title=element_blank()) +
  geom_text(aes(x=Inf,y=Inf,hjust=1.1,vjust=1.1,label=footnote), family="Courier") + 
  ggtitle("Charge distribution")

######################################
dev.off()
#
#
#