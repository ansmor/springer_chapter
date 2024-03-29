#define two functions to read and write the GMT files: readGMT and writeGMT
#these functions are available in a R package (rWikiPathways [26]) or can be defined separately here:
####OPTION 1####
#download the rWikiPathways package – you will need to install BiocManager first#
BiocManager::install("rWikiPathways")
####OPTION 2####
#define the two functions separately (without downloading the complete package)#
readGMT <- function(file) {
  x <- readLines(file)
  res <- strsplit(x, "\t")
  names(res) <- vapply(res, function(y) y[1], character(1))
  res <- lapply(res, "[", -c(1:2))
  wp2gene <- stack(res)
  wp2gene <- wp2gene[, c("ind", "values")]
  colnames(wp2gene) <- c("term", "gene")
  wp2gene[] <- lapply(wp2gene, as.character) #replace factors for strings  
  return(wp2gene)
}

writeGMT <- function(df, outfile){  
  # Assess and prep data frame
  df.len <- length(df)  
  if(df.len < 2){
    stop("The input data frame must include at least two columns.")
  } else if(df.len == 2){    
      df$desc <- df[,1]
      df <- df[,c(1,3,2)]  
  } else if(df.len > 3){
        id.cols <- names(df[,seq(1,df.len-2)])
        message(paste0("Concatenating the following columns to use as Identifiers: ",paste(id.cols, collapse = ", ")))    
        df[,df.len+1] <- apply(df[,id.cols],1,paste,collapse="%")    
        df <- df[,!(names(df) %in% id.cols)]
        df <- df[,c(3,1,2)]
        }  
# Generate file  
genelists = lapply(unique(df[,1]), function(x){
  paste(df[df[,1]==x, 3], collapse = "\t")
})
gmt = cbind(unique(df[,1]), df[!duplicated(df[,1]),2], unlist(genelists))  
write.table(gmt, outfile, sep = "\t", row.names = FALSE,col.names = FALSE, quote = FALSE)
}


#read the downloaded gmt file (in our case called “c5.go.v2023.1.Hs.symbols.gmt”)#
#make sure to define the correct path for your file#
GeneSetsGOALL<-readGMT("c5.go.v2023.1.Hs.symbols.gmt")
#show how many gene sets have been loaded#
length(unique(GeneSetsGOALL$term))
#remove gene set sizes <5 and >500#
#took about 22 sec on a Apple M1#
GeneSetsGOALL.sel<-GeneSetsGOALL %>%
  group_by(term) %>%
  mutate(N=n()) %>%
  filter(N>2&N<500) %>%
  rowwise() %>%
  mutate(genesetid=unlist(str_split(term,"%"))[3]) %>%
  mutate(description=unlist(str_split(term,"%"))[1]) %>%
  ungroup() %>%
  dplyr::select(description,gene) %>%
  as.data.frame(.)
#write the new gmt file (for future use)#
#takes about 30 sec on a Apple M1#
writeGMT(GeneSetsGOALL.sel,"GeneSetsGOALL.sel.gmt")
#upload the new gmt file#
upload_GMT_file(gmtfile = "GeneSetsGOALL.sel.gmt")
#following message will pop up (the custom annotation ID can be different)#
# Your custom annotations ID is gp__xOQr_REfT_llE
# You can use this ID as an 'organism' name in all the related enrichment tests against this custom source.
# Just use: gost(my_genes, organism = 'gp__xOQr_REfT_llE')
# [1] "gp__xOQr_REfT_llE"


enr<-gprofiler2::gost(query=biom, organism="gp__xOQr_REfT_llE", significant=TRUE,user_threshold=0.05, evcodes=TRUE,
      exclude_iea = FALSE, custom_bg = hpa.brain, correction_method="fdr")
class(enr) #enr is a list
#element of this list can be visualised as follows
names(enr)
#the results are stored in the first element (called "result)
#we add those results in a dataframe, which we call dfenr and add a column showing the database source 
#(GO_BP, GO_CC or GO_MF)
dfenr<-as.data.frame(enr$result) %>%   
  mutate(source=ifelse(term_name%like%"GOBP","GO_BP",
                       ifelse(term_name%like%"GOCC","GO_CC","GO_MF")))
#the next lines will create a summary graph (as shown in Figure 4)
#graph 1: identify the annotations databases in which significantly enriched pathways were found
g1<-dfenr %>%
  group_by(source) %>%
  summarise(N=n()) %>%
  ggplot(.,aes(x=source,y=N,fill=source,label=N))+
  geom_bar(stat="identity",colour="black",width = 0.5)+
  scale_fill_brewer(palette=1,direction=1)+
  geom_text(vjust=1.4)+
  ggtitle("A. Database sources of significant pathways")+
  theme_bw()+
  theme(plot.title.position = 'plot')
#graph2: identify the number of enriched pathways by genes
g2<-dfenr %>%
  group_by(intersection) %>%
  summarise(N=n()) %>%
  ggplot(.,aes(x=reorder(intersection,N),y=N,fill=N, label=N)) +
  geom_bar(stat="identity",colour="black")+  xlab("")+
  coord_flip()+
  scale_color_continuous()+
  ggtitle("B. Number of enriched pathways by genes/ intersections")+
  theme_bw()+
  geom_text(hjust=-0.3,size=2.5)+
  theme(plot.title.position = 'plot')+
  theme(axis.text.y= element_text(face="bold", size=8),legend.position = "none")
#graph3: create a graph showing the size and distribution of the enriched pathways
mx<-max(dfenr$term_size)-10
q1<-round(as.numeric(quantile(dfenr$term_size,1/4)),0)
q3<-round(as.numeric(quantile(dfenr$term_size,3/4)),0)
txt1<-paste0("mean(SD): ", round(mean(dfenr$term_size),0)," (",round(sd(dfenr$term_size),0),")")
txt2<-paste0("median[IQR]: ", round(median(dfenr$term_size),0)," [",q1,"-",q3,"]")
txt3<-max(dfenr$term_size)
txt4<-min(dfenr$term_size)
dx <- density(dfenr$term_size)
xnew <- mx
approx(dx$x,dx$y,xout=max(dfenr$term_size))
g3<-dfenr %>% 
  ggplot(.,aes(x=term_size))+
  geom_density(linewidth=0.5,fill="grey90",colour="black")+
  geom_vline(aes(xintercept=mean(term_size)),color="coral1", linetype="dashed",linewidth=0.5)+
  geom_vline(aes(xintercept=median(term_size)), color="coral4", linetype="dashed", linewidth=0.5)+
  xlab("gene set size")+
  labs(title="C. Summary statistics for the significant gene set sizes",
       subtitle = paste0("N total=", nrow(dfenr),"\n",txt1," ",txt2,"\n","max gs size =",txt3,", ","min gs size =",txt4))+  
  theme_bw()+
  theme(plot.title.position = 'plot',plot.subtitle = element_text(size=10))
#create a final graph
summary.graph<-ggpubr::ggarrange(g1,g2,g3,nrow=3,ncol=1)
annotate_figure(summary.graph, top = text_grob("gProfileR results",color = "black", face = "bold", size = 12), 
                bottom = text_grob("Legend:dark red dashed line= median; light red dashed line= mean", color = "black",hjust = 1, x = 1, face = "italic", size = 8))
