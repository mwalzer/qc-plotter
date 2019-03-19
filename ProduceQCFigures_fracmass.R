####################### This is an R script to produce the figures that are attached to the qcML format
###Fractional mass plot
#######################

#options
options(digits=10)

file1<-commandArgs(TRUE)[1] #ids
file2<-commandArgs(TRUE)[2] #precs
file3<-commandArgs(TRUE)[3] #theoretical_masses.tsv.gz
post<-commandArgs(TRUE)[4]
png(post)
#file1<-"exampledata/QCID.tsv"
#file2<-"exampledata/QCPREC.tsv"
#file3<-"exampledata/theoretical_masses.tsv.gz

QCID <- read.csv(file=file1,head=TRUE,sep="\t")
QCPREC <- read.csv(file=file2,head=TRUE,sep="\t")
theoretical_masses <- read.csv(file=gzfile(file3),head=TRUE,sep="\t")
######################################
require(graphics)
require(dplyr)
require(scales)
require(ggplot2)
require(chron)

names(QCPREC) <- c('RT','MZ','Charge')[0:ncol(QCPREC)]  # Charge column is absent in old exports from qcML
names(QCID) <- c('RT','MZ', 'Score', 'PeptideSequence', 'Charge', 'TheoreticalWeight', 'deltaPPM', 'Oxidation(M)')[0:ncol(QCID)]  # Qxidation(M) is absent in new exports from qcML (deprecated)
QCID <- QCID[0:7]

Sys.setenv(TZ='CEST')
QCID$datetime <- as.POSIXct(as.character(0),format="%S", tz='CEST')+QCID$RT
QCID$time <- times(format(QCID$datetime, "%H:%M:%S"))

QCPREC <- QCPREC[0:3]

theoretical_masses$col <- "theoretical"
QCFRAC<-merge(x = QCPREC, y = QCID, by.x =c("MZ","RT"), by.y =c("MZ","RT"),  all=TRUE)

if(all(c("Charge.x","Charge.y") %in% names(QCFRAC))){QCFRAC <- QCFRAC %>% mutate(Charge = ifelse(is.na(Charge.x),Charge.y,Charge.x)) %>% select(-Charge.x,-Charge.y)}

QCFRAC<-QCFRAC[complete.cases(QCFRAC),]
QCFRAC$charge <- QCFRAC$Charge
QCFRAC$Charge <- as.factor(QCFRAC$Charge)
ggplot(theoretical_masses, aes(x=as.numeric(nominal), y=as.numeric(fractional), colour=col)) +
  geom_point(alpha = .01) + 
  geom_point(data=QCFRAC, aes(x=floor(MZ*charge),y=MZ*charge-floor(MZ*charge),colour=Charge), na.rm=TRUE) +
  xlab("Nominal mass") + 
  ylab("Fractional mass") + 
  labs(colour="Identified as charge") +
  scale_x_continuous(expand = c(0, 0), limit=c(0,5000)) + 
  scale_y_continuous(expand = c(0, 0)) +
  ggtitle("Fractional masses plot")
  #xlim(c(min(as.integer(theoretical_masses$nominal), na.rm=TRUE),max(as.numeric(theoretical_masses$nominal), na.rm=TRUE)))

######################################
dev.off()
#
#
#
