###################### This is an R script to produce the figures that are attached to the qcML format
###Run composition pie
######################

#options
options(digits=10)

file1<-commandArgs(TRUE)[1] #ids
post<-commandArgs(TRUE)[2]
png(post)
#file1<-"exampledata/QCRUN.tsv"

QCRUN <- read.csv(file=file1,head=TRUE,sep="\t")
######################################
require(graphics)
require(ggplot2)

ggpie <- function (dat, by, totals, faceting) {
  ggplot(dat, aes_string(x=factor(1), y=totals, fill=by)) +
    geom_bar(stat='identity', color='black') +
    guides(fill=guide_legend(override.aes=list(colour=NA))) + # removes black borders from legend
    coord_polar(theta='y') +
    facet_grid(facets=paste(". ~ ",faceting)) +   #facets=. ~ faceting does not work with variable strings combined with . ~ 
    theme(axis.ticks=element_blank(),
          axis.text.y=element_blank(),
          axis.text.x=element_blank(),
          axis.text.x=element_text(colour='black'),
          axis.title=element_blank()) + # remove the custom y scale - not working with faceting 
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
  #scale_y_continuous(breaks=cumsum(dat[[totals]]) - dat[[totals]] / 2, labels=dat[[by]])  
}

require(dplyr)

QCRUN <- QCRUN %>% mutate(runtype = paste(Organism, Enzyme, sep = ' + ')) %>% group_by(runtype,Month) %>% summarise(count=n()) %>% mutate(freq = count / sum(count))
p <- ggpie(QCRUN, by="runtype", totals="freq", faceting="Month")
p
######################################
dev.off()
#
#
#