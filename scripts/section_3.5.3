#we use the previously created cyto3 dataframe and save the gene set names#
write.csv(cyto3$transf.name,file="cluster.txt",quote=FALSE,row.names = FALSE)
#we open the file in excel or any tabular text editor and manually identify clusters of similar biological function and then reload the file in R#
cluster<-read.table("cluster.txt",sep="\t",fill=T,header=T) %>% magrittr::set_colnames(.,c("transf.name","cluster"))
#and add the cluster to the main dataframe#
cyto4<-cyto3 %>%   
  merge(.,cluster,by.x="transf.name",all.x=T)
#save the file to be exported into Cytoscape#
write.table(cyto4,file="cytoscape_cluster.txt",sep="\t",row.names=FALSE,quote=FALSE)
