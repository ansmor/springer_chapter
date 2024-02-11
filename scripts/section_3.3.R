####STEP1: read human protein atlas data “normal_tissue.tsv”--####
hpa<-data.table::fread("normal_tissue.tsv")
#clean columns names and filter for data with enhanced reliability score#
hpa<-hpa %>%
  janitor::clean_names() %>%
  filter(reliability=="Enhanced")
#see tissues and cell types which are available#
hpa.cell_types<-unique(hpa$cell_type)
hpa.tissues<-unique(hpa$tissue)
hpa.tissues
hpa.cell_types
#select brain tissues#
hpa.brain.tissues<-c("caudate","cerebellum","cerebral cortex","pituitary gland","choroid plexus")
hpa.brain.tissues
#extract cell types available from brain tissues#
hpa.brain.celltypes<-hpa %>%   
  filter(tissue%in%hpa.brain.tissues) %>%
  distinct(cell_type) %>%
  pull(cell_type)



#get genes with low, high or medium expression in the brain#
hpa.brain<-hpa %>%   
  filter(tissue%in%hpa.brain.tissues) %>%   
  filter(level=="High"|level=="Medium"|level=="Low") %>%   
  distinct(gene_name) %>%   
  pull(gene_name)
#analysis and visualisation of HPA data#


####STEP2: create a vector with the biomarkers we are interested in--####
biom<-c("NRGN","SNAP25", "SYT1", "GAP43", "VLDLR", "SYNPO", "SYP")
#create the first graph showing the expression profile by cell type#
gA<-hpa %>%   
  filter(gene_name%in%biom) %>% 
  filter(tissue%in%hpa.brain.tissues) %>% 
  group_by(gene_name,cell_type, level) %>%
  summarise(N=n()) %>%
  ungroup() %>%
  add_row(gene_name=setdiff(biom,unique(.$gene_name)),cell_type=unique(.$cell_type),level="Not detected",N=1) %>%
  tidyr::complete(gene_name,cell_type) %>%
  replace_na(list(level="Not detected")) %>%
  mutate(level2=factor(level,levels=rev(c("Not detected","Low","Medium","High")))) %>%
  ggplot(.,aes(x=gene_name,y=cell_type,fill=level2))+  
  geom_tile(colour="black") +
  scale_fill_brewer(palette=2,direction=-1,name="",na.value="grey90")+
  theme(axis.text.x=element_text(face="bold"))+
  theme_light()+
  theme(axis.ticks=element_line(size=0.4),
        plot.background=element_blank(),
        panel.border=element_blank(),
        axis.text.x=element_text(face="bold",angle=90,vjust=1),
        plot.title.position = 'plot')+
  ylab("")+
  xlab("cell type")+
  ggtitle("A. Expression by brain cell type")
#show the graph#
gA


#create the second graph showing the expression by brain regions#
#use the aseg (Automatic subcortical segmentation) atlas to show the subcortical regions#
dfaseg<-aseg$data$region %>%   
  as.data.frame(.) %>%   
  'colnames<-'(c("region")) %>%   
  mutate(region2=region) %>%   
  mutate(region2=ifelse(region2=="cerebellum cortex","cerebellum",region2))
data.aseg<-hpa %>%   
  janitor::clean_names() %>% #nice function to clean names  
  filter(gene_name%in%biom) %>%  
  filter(tissue%in%hpa.brain.tissues) %>%  
  group_by(gene_name,tissue,level) %>%   
  summarise(N=n()) %>%   
  filter(level%in%c("Medium","High")) %>%   
  distinct(gene_name,tissue) %>%   
  group_by(gene_name,tissue) %>%   
  summarise(N2=n()) %>%   
  merge(.,dfaseg,by.x="tissue",by.y="region2",all.y=T) %>%   
  dplyr::select(-tissue) %>%   
  ungroup() %>%   
  tidyr::complete(gene_name,region) %>%   
  filter(!is.na(gene_name)) %>%   
  add_row(gene_name=biom,N2=NA,region=NA) 
gB<-ggplot(data.aseg) +  
  geom_brain(atlas = aseg, aes(fill = N2)) +  
  scale_fill_viridis_c(option = "magma", direction =1 ,na.value="grey90") +  
  theme_void() +
  labs(title = "B. Detected expression in subcortical regions \n")+
  facet_wrap(~gene_name)+  
  theme(legend.position = "none", plot.title.position = 'plot')
#show the graph#
gB



#use the Campbell atlas to show the cortical regions (HPA only provides data for “cerebral cortex” and does not specifies the regions (frontal, parietal, etc…))#
dfcampbell<-campbell$data$region %>%
  as.data.frame(.) %>%
  'colnames<-'(c("region")) %>% 
  mutate(region2=region) %>%
  mutate(region2=ifelse(!is.na(region2),"cerebral cortex",region2))
data.campbell<-hpa %>%
  filter(gene_name%in%biom) %>% 
  filter(tissue%in%hpa.brain.tissues) %>%
  group_by(gene_name,tissue,level) %>%
  summarise(N=n()) %>%
  filter(level%in%c("Light","Medium","High")) %>%
  distinct(gene_name,tissue) %>%
  group_by(gene_name,tissue) %>%
  summarise(N2=n()) %>%
  ungroup() %>%
  tidyr::complete(gene_name,tissue) %>%
  merge(.,dfcampbell,by.x="tissue",by.y="region2",all.y=T) %>%
  dplyr::select(-tissue) %>%
  ungroup() %>%
  filter(!is.na(gene_name)) %>%
  add_row(gene_name=setdiff(biom,unique(.$gene_name)),N2=NA,region=unique(.$region)) %>%
  add_row(gene_name=biom,N2=NA,region=NA)
gC<-ggplot(data.campbell) +
  geom_brain(atlas = campbell, hemi="left", colour="white", aes(fill = N2)) +
  scale_fill_viridis_c(option = "magma", direction =1 ,na.value="grey90") +
  theme_void() +
  labs(title = "C. Detected expression in cerebral cortex \n")+
  facet_wrap(~gene_name)+
  theme(legend.position = "none")
#show the graph#
gC
#create the final graph (Figure 2 in this tutorial)#
ggarrange(gA, ggarrange(gB,gC,nrow=2),ncol=2)
