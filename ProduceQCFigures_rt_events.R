############ This is an R script to produce the figures that are attached to the qcML format
###RT events
############

#options
options(digits=10)

file1<-commandArgs(TRUE)[1] #ids
file2<-commandArgs(TRUE)[2] #precs
file3<-commandArgs(TRUE)[3] #tics
file4<-commandArgs(TRUE)[4] #rics
post<-commandArgs(TRUE)[5]
#file1<-"exampledata/Freiburg_old1/QCID.tsv"
#file2<-"exampledata/Freiburg_old1/QCPREC.tsv"
#file3<-"exampledata/Freiburg_old1/QCTIC.tsv"
#file4<-"exampledata/Freiburg_old1/QCRIC.tsv"
QCID <- read.csv(file=file1,head=TRUE,sep="\t")
QCPREC <- read.csv(file=file2,head=TRUE,sep="\t")
QCTIC <- read.csv(file=file3,head=TRUE,sep="\t")
QCRIC <- read.csv(file=file4,head=TRUE,sep="\t")
png(post)
######################################
require(scales)
require(ggplot2)
require(chron)
require(dplyr)

names(QCPREC) <- c('RT','MZ','Charge')[0:ncol(QCPREC)]  # Charge column is absent in old exports from qcML
names(QCID) <- c('RT','MZ', 'Score', 'PeptideSequence', 'Charge', 'TheoreticalWeight', 'deltaPPM', 'Oxidation(M)')[0:ncol(QCID)]  # Qxidation(M) is absent in new exports from qcML (deprecated)

QCID <- QCID[0:7]
QCPREC <- QCPREC[0:3]

Sys.setenv(TZ='CEST')
QCID$datetime <- as.POSIXct(as.character(0),format="%S", tz='CEST')+QCID$RT
QCID$time <- times(format(QCID$datetime, "%H:%M:%S"))
QCID$col <- "identified"
QCPREC$datetime <- as.POSIXct(as.character(0),format="%S", tz='CEST')+QCPREC$RT
QCPREC$time <- times(format(QCPREC$datetime, "%H:%M:%S"))
QCPREC$col <- "recorded"

QCTIC$datetime <- as.POSIXct(as.character(0),format="%S", tz='CEST')+QCTIC$MS.1000894_.sec.
QCTIC$time <- times(format(QCTIC$datetime, "%H:%M:%S"))
QCRIC$datetime <- as.POSIXct(as.character(0),format="%S", tz='CEST')+QCRIC$MS.1000894_.sec.
QCRIC$time <- times(format(QCRIC$datetime, "%H:%M:%S"))

#group by value Pint into quarters
#RT of 25% chromatography intensity is recorded, 50% intensity is recorded, 75% intensity is recorded
#RT of 25% ESI intensity is recorded, 50% intensity is recorded, 75% intensity is recorded
#RT of 25% MS2 is recorded, 50% MS2 is recorded, 75% MS2 is recorded
#RT of 25% IDs is recorded, 50% IDs is recorded, 75% IDs is recorded
tic <- sum(as.numeric(QCTIC$MS.1000285))
QCTIC$OAint <- cumsum(as.numeric(QCTIC$MS.1000285))
QCTIC$Pint <- (QCTIC$OAint/tic) * 100
QCTIC$Quartiles <- ifelse(QCTIC$Pint<25,1,ifelse(QCTIC$Pint<50,2,ifelse(QCTIC$Pint<75,3,4)))

plotdf_tic <- QCTIC %>% group_by(Quartiles) %>% summarise(n=n(),m=max(time))
plotdf_tic <- plotdf_tic %>% mutate(diffm = m-lag(m))
plotdf_tic[1,]$diffm <- plotdf_tic[1,]$m

ric <- sum(as.numeric(QCRIC$MS.1000285))
QCRIC$OAint <- cumsum(as.numeric(QCRIC$MS.1000285))
QCRIC$Pint <- (QCRIC$OAint/tic) * 100
QCRIC$Quartiles <- ifelse(QCRIC$Pint<25,1,ifelse(QCRIC$Pint<50,2,ifelse(QCRIC$Pint<75,3,4)))

plotdf_ric <- QCRIC %>% group_by(Quartiles) %>% summarise(n=n(),m=max(time))
plotdf_ric <- plotdf_ric %>% mutate(diffm = m-lag(m))
plotdf_ric[1,]$diffm <- plotdf_ric[1,]$m

ms2 <- nrow(QCPREC)
QCPREC$OAcount <- 1
QCPREC$OAcount <- cumsum(QCPREC$OAcount) 
QCPREC$Pcount <- (QCPREC$OAcount/ms2) * 100
QCPREC$Quartiles <- ifelse(QCPREC$Pcount<25,1,ifelse(QCPREC$Pcount<50,2,ifelse(QCPREC$Pcount<75,3,4)))

plotdf_ms2 <- QCPREC %>% group_by(Quartiles) %>% summarise(n=n(),m=max(time))
plotdf_ms2 <- plotdf_ms2 %>% mutate(diffm = m-lag(m))
plotdf_ms2[1,]$diffm <- plotdf_ms2[1,]$m

ids <- nrow(QCID)
QCID$OAcount <- 1
QCID$OAcount <- cumsum(QCID$OAcount) 
QCID$Pcount <- (QCID$OAcount/ids) * 100
QCID$Quartiles <- ifelse(QCID$Pcount<25,1,ifelse(QCID$Pcount<50,2,ifelse(QCID$Pcount<75,3,4)))

plotdf_ids <- QCID %>% group_by(Quartiles) %>% summarise(n=n(),m=max(time))
plotdf_ids <- plotdf_ids %>% mutate(diffm = m-lag(m))
plotdf_ids[1,]$diffm <- plotdf_ids[1,]$m

plotdf_tic$group <- "TIC"
plotdf_ric$group <- "RIC"
plotdf_ms2$group <- "MS2"
plotdf_ids$group <- "IDs"
quartilesdf <- rbind(plotdf_tic,plotdf_ric,plotdf_ms2,plotdf_ids)
quartilesdf$Quartiles <- as.factor(quartilesdf$Quartiles)
quartilesdf$frequencies <- quartilesdf$n / (seconds(quartilesdf$diffm)+minutes(quartilesdf$diffm)*60+hours(quartilesdf$diffm)*60*60)
quartilesdf$frequencies <- paste(format(quartilesdf$frequencies, digits=3)," Hz")

ggplot(quartilesdf, aes(x=group,y=diffm,fill=Quartiles)) +
  geom_bar(stat='identity')+
  scale_y_chron(format ="%H:%M:%S")+
  coord_flip() + 
  ylab("RT") +
  xlab("") + 
  ggtitle("Quartiles of IDs, MS2, TIC/MS1 in which periode over RT") + 
  geom_text(aes(x=group,y=m,label=quartilesdf$frequencies),hjust=1)

######################################
dev.off()
#
#
#