QC_umis_384plot<-function(file, name){
  library(RColorBrewer)
  library(plot3D)
  low <- "#313695";mid="#FFFFBF"; high="#A50026"   ## three-class RdYlBu, 11 levels
  RdYlBu.orig <- colorRampPalette(c(low,mid,high))(91)
  palette <- colorRampPalette(rev(brewer.pal(n = 11,name = "RdYlBu")))(10) # pick which palette for plate plotting

  coordinates<-expand.grid(seq(1,24),rev(seq(1,16)))
  UMIsFig <- plot(expand.grid(x = c(1:24), y=c(1:16)),ylab=NA,xlab=NA, xlim=c(1,24), cex=1.5, xaxt="n", yaxt="n") #plate layout
  title(name, line = 2.5)
  axis(2, at=c(1:16),labels =rev(LETTERS[1:16]), las=2)
  axis(3, at=c(1:24), labels = c(1:24))
  print(paste0("Maximum column sum of plate ",name, " :" , max(colSums(file))))
  points(coordinates,pch=19,col=palette[cut(log10(colSums(file)),
                                            breaks=unique(c(0,0.5,1,1.5,2,2.5,3,3.5,4,4.5,max(colSums(file)))))], cex=1.4) # plot total non-ERCC reads/cell over layout
  # cut is used here to  separate and fall the values into different internals (10 is set to tell R 10 internals are set.)
  colkey(col=RdYlBu.orig, side=1, add=T, clab="number of unique counts in log10",
         line.clab = 1.25, length=0.8, clim=c(0,5))
  
}