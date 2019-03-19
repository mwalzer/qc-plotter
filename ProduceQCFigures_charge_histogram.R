################### This is an R script to produce the figures that are attached to the qcML format
###Charge histogram
###################

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
require(dplyr)
##########################
names(QCPREC) <- c('RT','MZ','Charge')[0:ncol(QCPREC)]  # Charge column is absent in old exports from qcML
names(QCID) <- c('RT','MZ', 'Score', 'PeptideSequence', 'Charge', 'TheoreticalWeight', 'deltaPPM', 'Oxidation(M)')[0:ncol(QCID)]  # Qxidation(M) is absent in new exports from qcML (deprecated)

QCID <- QCID[0:7]
QCPREC <- QCPREC[0:3]

Sys.setenv(TZ='CEST')
QCID$datetime <- as.POSIXct(as.character(0),format="%S", tz='CEST')+QCID$RT
QCID$time <- times(format(QCID$datetime, "%H:%M:%S"))
QCID$col <- "identified"
#QCPREC$col <- "recorded"

QCZ<-merge(x = QCPREC, y = QCID, by.x =c("MZ","RT"), by.y =c("MZ","RT"),  all=TRUE)

if(all(c("Charge.x","Charge.y") %in% names(QCZ))){QCZ <- QCZ %>% mutate(Charge = ifelse(is.na(Charge.x),Charge.y,Charge.x)) %>% select(-Charge.x,-Charge.y)}

QCZ$Charge[is.na(QCZ$Charge)] <- "?"
QCZ$Charge <- as.factor(QCZ$Charge)
sorted_labels <- paste(sort(as.integer(levels(QCZ$Charge))))
QCZ$Charge <- factor(QCZ$Charge, levels = sorted_labels)
QCZ$col[is.na(QCZ$col)] <- "recorded"

QCZsum <- QCZ %>% group_by(Charge) %>% summarise(n=n())
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

ggplot(data=QCZ, aes(x=Charge, fill=col)) + 
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