QC_ERCC_384plot <- function(file, name){
  library(RColorBrewer)
  library(plot3D)
  low <- "#313695";mid="#FFFFBF"; high="#A50026"   ## three-class RdYlBu, 11 levels
  RdYlBu.orig <- colorRampPalette(c(low,mid,high))(91)
  palette <- colorRampPalette(rev(brewer.pal(n = 11,name = "RdYlBu")))(10) # pick which palette for plate plotting
  
  coordinates<-expand.grid(seq(1,24),rev(seq(1,16)))
  #plot(expand.grid(x = c(1:24), y=c(1:16)),main=name,ylab=NA,xlab=NA, xlim=c(1,24), cex=1.5, xaxt="n", yaxt="n") #plate layout
  plot(expand.grid(x = c(1:24), y=c(1:16)),ylab=NA,xlab=NA, xlim=c(1,24), cex=1.5, xaxt="n", yaxt="n") #plate layout
  title(name, line = 2.5)
  axis(2, at=c(1:16),labels =rev(LETTERS[1:16]), las=2)
  axis(3, at=c(1:24), labels = c(1:24))
  points(coordinates,pch=19,col=palette[cut(log10(colSums(file)),include.lowest = T,
                                            breaks=unique(c(0,0.2,0.4,0.6,0.8,1,1.2,1.4,1.6,1.8,max(colSums(file)))))], cex=1.4)
  colkey(col=RdYlBu.orig, side=1, add=T, clab="number of ERCC-reads in log10",
         line.clab = 1.25, length=0.8, clim=c(0,2))
}