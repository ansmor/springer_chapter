#read the exported node file from Cytoscape (called “AD_biomarkers_default_node.csv”#
cyto<-read.csv("AD_biomarkers_default_node.csv",sep=",",header=TRUE)
#make node names lowercase#
cyto$transf.name<-tolower(cyto$EnrichmentMap..GS_DESCR)
#add colours column#
dfcolours<-data.frame(colours=sample(colors(),
              length(unique(cyto$EnrichmentMap..Genes))),
              intersection=unique(cyto$EnrichmentMap..Genes)) %>% 
  mutate(intersection=gsub(",","|",intersection)) %>%
  rowwise() %>% 
  mutate(colours=ifelse(length(grep("\\|",intersection))>0,"multi",intersection))
#add to main dataframe#
cyto2<-cyto %>%
  merge(.,dfenr %>%
          dplyr::select(term_id,term_size),by.y="term_id",by.x="shared.name",all.x=T)
#add a column gs size which can be used to change the size of the nodes#
cyto3<-cyto2 %>%
  mutate(gs_cat=cut(term_size, breaks=c(0,5,10,20,50,100,200))) %>%
  mutate(shared.name=paste0("\"",name, "\"")) %>%
  merge(.,dfcolours,by.y="intersection",by.x="EnrichmentMap..Genes",all.x=T) %>%
  relocate(c(name,transf.name,gs_cat,colours,term_size))
#write the file#
write.table(cyto3,file="nodes_attributes.txt",sep="\t",row.names=FALSE,quote=FALSE)
