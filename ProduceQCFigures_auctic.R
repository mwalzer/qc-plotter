###### This is an R script to produce the figures that are attached to the qcML format
###AUC TIC
######

#options
options(digits=10)

file<-commandArgs(TRUE)[1]
post<-commandArgs(TRUE)[2]
png(post)

#file1<-"exampledata/QCTIC.tsv"

QCTIC<-read.csv(file=file,head=TRUE,sep="\t")
######################################
require(scales)
require(ggplot2)
require(chron)
require(gridExtra)
require(grid)
require(pracma)

QCTIC$datetime <- as.POSIXct(as.character(0),format="%S", tz='CEST')+QCTIC$MS.1000894_.sec.
Sys.setenv(TZ='CEST')
QCTIC$time <- times(format(QCTIC$datetime, "%H:%M:%S"))

AUC <- trapz(QCTIC$MS.1000894_.sec.,QCTIC$MS.1000285)
Qs <- quantile(QCTIC$MS.1000285,prob = c(0.25, 0.5, 0.75))
Qs <- data.frame(Qs)
lab <- rbind(Qs,AUC)
colnames(lab) <- c("Raw intensity value")
row.names(lab) <- c(row.names(Qs),"AUC")
txtlab <- capture.output(lab)
#25% of intensities below value(Q1),50% of intensities below value(Q2),75% of intensities below value(Q3)

ht <- ggplot(data=QCTIC, aes(x=MS.1000285)) + 
  geom_histogram(bins = 100) +
  theme(axis.text.x = element_blank(),
        plot.margin=unit(c(1,1,-0.1,1), "cm")) +
  xlab("") + ylab("Count") +
  ggtitle("Intensity distribution") +
  geom_text(aes(x=Inf,y=Inf,hjust=1.1,vjust=1.1,label=paste(txtlab,collapse="\n")), family="Courier")

bx <- ggplot(data=QCTIC, aes(x=1, y=MS.1000285)) + 
  geom_boxplot() +
  coord_flip() + 
  xlab("") + ylab("Intensity distribution") +
  theme(
    axis.text.y = element_blank(),
    axis.ticks = element_blank(),
    plot.margin=unit(c(-0.1,1,1,1), "cm")
    )

ht <- ggplot_gtable(ggplot_build(ht))
bx <- ggplot_gtable(ggplot_build(bx))
maxWidth = unit.pmax(ht$widths[2:3], ht$widths[2:3])
ht$widths[2:3] <- maxWidth
bx$widths[2:3] <- maxWidth
grid.arrange(ht,bx, ncol = 1, nrow = 2, widths=c(3), heights=c(4,1))
######################################
dev.off()
#
#
#