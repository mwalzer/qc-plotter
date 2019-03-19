
################ This is an R script to produce the figures that are attached to the qcML format
###Feature width
################

#options
options(digits=10)

file<-commandArgs(TRUE)[1]
post<-commandArgs(TRUE)[2]
png(post)

#file<-"exampledata/QCFEAT.tsv"
QCFEAT<-read.csv(file=file,head=TRUE,sep="\t")
######################################
require(scales)
require(ggplot2)
require(chron)
require(grid)
require(gridExtra)

QCFEAT$datetime <- as.POSIXct(as.character(0),format="%S", tz='CEST')+QCFEAT$RT
Sys.setenv(TZ='CEST')
QCFEAT$time <- times(format(QCFEAT$datetime, "%H:%M:%S"))

ht <- ggplot(QCFEAT, aes(x=FWHM)) + 
  geom_histogram(aes(y=..density..), colour="black", fill="white") +  
  geom_density(alpha=.1, fill="green") +
  scale_y_continuous(expand=c(0, 0)) +
  scale_x_continuous(expand=c(0, 0)) +
  theme(axis.text.x = element_blank(),
        plot.margin=unit(c(1,1,-0.1,1), "cm")) +
  xlab("") + ylab("Density") +
  ggtitle("Features FWHM distribution")

bx <- ggplot(data=QCFEAT, aes(x=1, y=FWHM)) + 
  geom_boxplot() +
  coord_flip() + 
  xlab("") + ylab("FWHM") +
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
#
#