############################ This is an R script to produce the figures that are attached to the qcML format
###Mass accuracy time course
############################

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
#require(cowplot)

names(QCPREC) <- c('RT','MZ','Charge')[0:ncol(QCPREC)]  # Charge column is absent in old exports from qcML
names(QCID) <- c('RT','MZ', 'Score', 'PeptideSequence', 'Charge', 'TheoreticalWeight', 'deltaPPM', 'Oxidation(M)')[0:ncol(QCID)]  # Qxidation(M) is absent in new exports from qcML (deprecated)
QCID <- QCID[0:7]

Sys.setenv(TZ='CEST')
QCID$datetime <- as.POSIXct(as.character(0),format="%S", tz='CEST')+QCID$RT
QCID$time <- times(format(QCID$datetime, "%H:%M:%S"))

QCPREC <- QCPREC[0:3]

QCZ<-merge(x = QCPREC, y = QCID, by.x =c("MZ","RT"), by.y =c("MZ","RT"),  all=TRUE)

if(all(c("Charge.x","Charge.y") %in% names(QCZ))){QCZ <- QCZ %>% mutate(Charge = ifelse(is.na(Charge.x),Charge.y,Charge.x)) %>% select(-Charge.x,-Charge.y)}

QCZ<-QCZ[complete.cases(QCZ), ]

ml <- loess(deltaPPM ~ time, data=QCZ, span=0.10)
mdf <- as.data.frame(seq(min(QCZ$RT), max(QCZ$RT), 60))  # minute spaced new data frame
names(mdf) <- c('RT')
mdf$datetime <- as.POSIXct(as.character(0),format="%S", tz='CEST')+mdf$RT
mdf$time <- times(format(mdf$datetime, "%H:%M:%S"))
mdf$pred <- predict(ml,mdf)
mdf <- mdf %>% mutate(above=mdf$pred > sd(QCZ$deltaPPM))  # check which are above standard deviation of dppm
runs <- rle(mdf$above)  # runs (aka stretches of equal consecutive values)
correctionflag <- any(10<runs$lengths[runs$values==TRUE])  # selecting run lengths of TRUE (i.e. above sd), check if any longer than 10 (minutes, because mdf is minute spaced)

p <- ggplot(data=QCZ, aes(x=time, y=deltaPPM)) +
  ggtitle(expression(paste(Delta, "ppm over time"))) + 
  theme(plot.title = element_text(hjust = 0.5)) +
  geom_line(y=0, colour="blue") + 
  geom_point(alpha=0.5) + 
  scale_x_chron(format ="%H:%M", n=10, expand=c(0,0)) +
  scale_y_continuous(limit=c(-10,10)) +
  ylab(expression(paste(Delta, " ppm"))) +
  xlab("Time") +
  stat_smooth(colour="red", method=loess, span=1/5) +
  geom_hline(yintercept = sd(QCZ$deltaPPM),linetype="dotted", colour="green") 

if(correctionflag){ 
  p <- p + labs(caption="More than 10 minutes of consecutive lock mass loss detected!") + 
    geom_hline(yintercept = sd(QCZ$deltaPPM),linetype="dotted", colour="violet", size=1.5) +
    theme(plot.caption=element_text(face="italic", color="red"))
}

plot(p)
######################################
dev.off()
