################## This is an R script to produce the figures that are attached to the qcML format
###ID oversampling
##################

#options
options(digits=10)

file1<-commandArgs(TRUE)[1] #ids
post<-commandArgs(TRUE)[2]
png(post)
#file1<-"exampledata/QCID.tsv"

QCID <- read.csv(file=file1,head=TRUE,sep="\t")
######################################
require(ggplot2)
require(dplyr)
require(ggrepel)

names(QCID) <- c('RT','MZ', 'Score', 'PeptideSequence', 'Charge', 'TheoreticalWeight', 'deltaPPM', 'Oxidation(M)')[0:ncol(QCID)]  # Qxidation(M) is absent in new exports from qcML (deprecated)
sampling <- QCID %>% group_by(PeptideSequence) %>% summarise(sampled=n()) %>% group_by(sampled) %>% summarise(n=sum(sampled))

DS1A <- sampling[1,]$n/sampling[2,]$n  # NA if one is NA
DS1B <- sampling[2,]$n/sampling[3,]$n  # NA if one is NA

samplemin <- min(sampling$sampled)
samplemax <- max(sampling$sampled)

is_outlier <- function(x) {
  return(x < quantile(x, 0.25) - 1.5 * IQR(x) | x > quantile(x, 0.75) + 1.5 * IQR(x))
}

samplingdf <- QCID %>% group_by(PeptideSequence) %>% 
  summarise(sampled=n()) %>% 
  mutate(outlier = ifelse(is_outlier(sampled), sampled, as.numeric(NA)))

#3rd max .. i.e. nrow(samplingdf)-2
m3 <- sort(samplingdf$sampled,partial=nrow(samplingdf)-2)[nrow(samplingdf)-2]
#only those are used as label
samplingdf <- samplingdf %>% mutate(outlier = ifelse(outlier<m3, as.numeric(NA), outlier)) %>% 
  mutate(outlier = ifelse(is.na(outlier),as.numeric(NA),as.character(PeptideSequence)))

ctext <- data.frame(c(samplemin,samplemax,DS1A,DS1B))
rownames(ctext) <- c("samplemin","samplemax","DS-1A","DS-1B")
colnames(ctext) <-"Metric value"
footnote <- paste(capture.output(ctext), collapse="\n") #sampling min+sampling max+ DS-1A + DS-1B

samplingdf$all <- "all"

ggplot(samplingdf, aes(x=all,y=sampled)) + 
  geom_boxplot() + 
  coord_flip() +
  theme(axis.title.y=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks.y=element_blank()) +
  ylab("resampling count") +
  ggtitle("Boxplot of peptide resampling") +
  #geom_text(aes(label = outlier), na.rm = TRUE, hjust = -0.3, vjust = "inward")
  geom_label_repel(aes(label = outlier), na.rm = TRUE, box.padding = unit(2, "lines")) +
  geom_text(aes(x=Inf,y=Inf,hjust=1.1,vjust=1.1,label=footnote), family="Courier")

######################################
dev.off()
#
#
#