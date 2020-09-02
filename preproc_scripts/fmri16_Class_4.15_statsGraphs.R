library(tiff)
library(reshape2)
library(ez)



### --- Notes
#
# This script will run stats on ETAC betas
#
# This is a stripped-down script from one I use on my projects,
# hence all the oddities.



###################
# Set up
###################

parDir <- "/Volumes/Vedder/Bootcamp/Nate/Analyses/"

doWrite <- 1
doGraphs <- 1


### Etac variables
etacDir <- paste0(parDir,"grpAnalysis/")
etacData_location <- paste0(etacDir,"etac_betas/")
etacData_list <- read.table(paste0(etacData_location,"All_list.txt"))
etac_outDir <- etacData_location
etac_statsDir <- paste0(etacDir,"etac_stats/")




###################
# Functions
###################
GraphNames.Function <- function(dataString){
  if(dataString=="T1"){return(list(n1="Hit", n2="FA", n3="CR"))}
}

GraphEtacNames.Function <- function(dataString){
  if(dataString=="T1"){return(list(n1="Hit", n2="FA"))}
}

BehNames.Function <- function(dataString){
  if(dataString=="T1"){out<-c("H1","F1","CR"); return(out)}
}

EtacNames.Function <- function(x,y){
  if(grepl("T1_",x)==T){
    if(y=="RAMTG"){
      return("R. Anterior Middle Temporal Gyrus")
    }else if(y=="RMPFC"){
      return("R. Medial PFC")
    }else if(y=="LMPFC"){
      return("L. Medial PFC")
    }else if(y=="LAG"){
      return("L. Angular Gyrus")
    }else if(y=="RPUT"){
      return("R. Putamen")
    }else if(y=="RPCU"){
      return("R. Precuneus")
    }else if(y=="RSFG"){
      return("R. Superior Frontal Gyrus")
    }else if(y=="RIFS"){
      return("R. Inferior Frontal Sulcus")
    }
  }
}

SE.Function <- function(x,plot_data){
  SD <- sd(plot_data[,x])/sqrt(length(plot_data[,x]))
  return(SD)
}

Graph.Function <- function(DF,output_name,maskN,out_place){
  
  TITLE <- maskN
  MEANS <- colMeans(DF)
  E.BARS<-NA
  for(a in 1:dim(DF)[2]){
    E.BARS[a] <- SE.Function(a,DF)
  }
  RANGE <- range(c(MEANS,MEANS-E.BARS,MEANS+E.BARS,0))
  
  if(grepl("ns_stats",out_place)==T){
    ROI <- NsNames.Function(maskN)
    XNAMES <- GraphNames.Function(output_name)
  }else if(grepl("etac_stats",out_place)==T){
    ROI <- EtacNames.Function(output_name,maskN)
    XNAMES <- GraphEtacNames.Function(output_name)
  }else if(grepl("sub_stats",out_place)==T){
    ROI <- maskN
    XNAMES <- GraphNames.Function(output_name)
  }
  
  plotable <- matrix(0,nrow=2,ncol=num.betas)
  plotable[1,] <- MEANS
  plotable[2,] <- E.BARS
  
  if(doWrite == 1){
    graphOut <- paste0(out_place,"Graph_",output_name,"_",TITLE,".tiff")
    bitmap(graphOut, width = 6.5, units = 'in', type="tiff24nc", res=1200)
  }
  barCenters <- barplot(plotable[1,], names.arg = c(XNAMES), main=ROI, ylab="Beta Coefficient",ylim=RANGE)
  segments(barCenters, MEANS-E.BARS, barCenters, MEANS+E.BARS)
  arrows(barCenters, MEANS-E.BARS, barCenters, MEANS+E.BARS, lwd = 1, angle = 90, code = 3, length = 0.05)
  set.pos <- rowMeans(plotable); if(set.pos[1]>0){POS<-3}else{POS<-1}
  text(barCenters,0,round(plotable[1,],4),cex=1,pos=POS,font=2)
  if(doWrite == 1){
    dev.off()
  }
}

TT.Function <- function(x, y, dataN, maskN, out_place){
  ttest_out <- t.test(x,y,paired=T)
  meanX <- mean(x)
  meanY <- mean(y)
  if(doWrite == 1){
    output <- c(meanX, meanY)
    output <- c(output, capture.output(print(ttest_out)))
    writeLines(output,paste0(out_place,"Stats_TT_",dataN,"_",maskN,".txt"))
    return(ttest_out)
  }else{
    print(ttest_out)
  }
}

Mdata.Function <- function(x){
  
  #masks
  DF <- x
  ind.mask <- grep("Mask", DF[,1])
  assign("num.mask", length(ind.mask), envir = .GlobalEnv)
  # num.mask <- length(ind.mask)
  
  #subjects
  ind.subj <- grep("File", DF[,1])
  len.subj <- length(ind.subj)
  assign("num.subj", len.subj/num.mask, envir = .GlobalEnv)
  # num.subj <- len.subj/num.mask
  
  #betas
  ind.betas <- grep("+tlrc", DF[,1])
  len.betas <- length(ind.betas)
  assign("num.betas", (len.betas/num.mask)/num.subj, envir = .GlobalEnv)
  # num.betas <- (len.betas/num.mask)/num.subj
  
  # organize data
  ind.data <- matrix(as.numeric(as.character(DF[grep("+tlrc",DF[,1]),3])),ncol=num.betas,byrow=T)
  df.hold <- matrix(0,nrow=num.subj, ncol=num.mask*num.betas)
  for(i in 1:num.mask){
    df.hold[,(num.betas*i-(num.betas-1)):(num.betas*i)] <- ind.data[(num.subj*i-(num.subj-1)):(num.subj*i),1:num.betas]
  }
  colnames(df.hold) <- c(as.character(rep(DF[ind.mask,1],each=num.betas)))
  h.mask.names <- sub("Mask ","",DF[ind.mask,1])
  assign("mask.names",h.mask.names, envir = .GlobalEnv)
  
  return(df.hold)
}

MkTable.Function <- function(x,y){
  
  DF <- x
  DF.perm <- y
  hold.post <- matrix(NA,nrow=1,ncol=1+(num.comp*6))
  hold.post[1,1] <- hold.mask
  
  d<-2; for(k in 1:dim(DF.perm)[1]){
    
    colA <- DF.perm[k,1]; colB <- DF.perm[k,2]
    t.hold <- TT.Function(DF[,colA],DF[,colB],comp,paste0(hold.mask,"_",beh[colA],"-",beh[colB]),ns_outDir)

    t.hold.comp <- paste0(beh[colA],"-",beh[colB])
    t.hold.t <- as.numeric(t.hold$statistic)
    t.hold.df <- as.numeric(t.hold$parameter)
    t.hold.p <- as.numeric(t.hold$p.value)
    t.hold.lb <- as.numeric(t.hold$conf.int[1])
    t.hold.ub <- as.numeric(t.hold$conf.int[2])

    t.hold.capture <- c(t.hold.comp,t.hold.t,t.hold.df,t.hold.p,t.hold.lb,t.hold.ub)
    dd <- d+5
    hold.post[1,d:dd]<-t.hold.capture
    d <- dd+1
  }
  return(hold.post)
}







###################
# ETAC
###################
# # For testing
# i <- "All_Betas_T1.txt"
# j <- "Betas_T1_LAG.txt"

for(i in t(etacData_list)){
  
  beta_list <- read.table(paste0(etacData_location,i))
  
  df.post <- matrix(NA,nrow = dim(beta_list)[1],ncol = 6)
  colnames(df.post) <- c("ROI","T","df","p","LB","RB")
  
  count<-1
  for(j in t(beta_list)){
    
    ### Get, clean data
    raw_data <- read.delim2(paste0(etacData_location,j),header=F)
    
    # num subjects
    ind.subj <- grep("File", raw_data[,1])
    num.subj <- as.numeric(length(ind.subj))
    
    # num betas - will be 2 for ETAC
    ind.beta <- grep("beh", raw_data[,2])
    num.betas <- as.numeric(length(ind.beta)/num.subj)
    
    ind.beh1 <- ind.beta[c(TRUE, FALSE)]
    ind.beh2 <- ind.beta[c(FALSE, TRUE)]
    
    # fill df
    df <- matrix(0,ncol=num.betas,nrow=num.subj)
    df[,1] <- as.numeric(as.character(raw_data[ind.beh1,3]))
    df[,2] <- as.numeric(as.character(raw_data[ind.beh2,3]))
    
    # write out
    hold<-gsub("^.*_","",i); comp<-gsub("\\..*","",hold)
    hold1<-gsub("^.*_","",j); anat<-gsub("\\..*","",hold1)
    
    if(doWrite == 1){
      write.table(df,paste0(etacData_location,"Avg_Betas_",comp,"_",anat,".txt"),col.names=F, row.names=F,sep = "\t")
    }
    
    
    ### Stats
    t.out <- TT.Function(df[,1],df[,2],comp,anat,etac_statsDir)
    
    hold.t <- round(t.out$statistic,digits=2)
    hold.df <- t.out$parameter
    hold.p <- round(t.out$p.value,digits=6)
    hold.ci <- round(t.out$conf.int,digits=3)
    hold.write <- c(anat,hold.t,hold.df,hold.p,hold.ci)
    df.post[count,] <- hold.write

    
    ### Graphs
    if(doGraphs == 1){
      Graph.Function(df,comp,anat,etac_statsDir)
    }
    count <- count+1
  }
  
  if(doWrite==1){
    write.table(df.post,paste0(etac_statsDir,"Table_",comp,".txt"),row.names = F, quote = F, sep = "\t")
  }
}

