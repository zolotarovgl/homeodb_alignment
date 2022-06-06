# Get classification stats 
suppressMessages(library(ape))
suppressMessages(library(dplyr))
suppressMessages(library(stringr))
suppressMessages(library(fossil))
# Input - phylogenetic tree 
# Ouput:
# * table with precision, recall and F1
# * adjusted rand index.
prefs=c('PRD','PRD_Generax','ANTP','ANTP_Generax','POU','POU_Generax','TALE','TALE_Generax')
dfs = lapply(prefs, FUN = function(ds){
  tree = read.tree(sprintf('output/%s.ortholog_groups.newick',ds))
  # orthogrups are stored in the names 
  ref_fam = sapply(str_split(tree$tip.label,'\\|'),FUN = function(x) x[2])
  og = sapply(str_split(tree$tip.label,'\\|'),FUN = function(x) x[length(x)-1])
  cl_df = data.frame(ref_fam = ref_fam, og = og, name = tree$tip.label)})
names(dfs) = prefs  

res = lapply(dfs,FUN = function(cl_df){  
  famdf = lapply(unique(cl_df$ref_fam),FUN  = function(ref_fam){
    # you can compute precision, recall and F-scores for every family
    # precision - PPV 
    # recall - true positive rate 
    # F-score 
    # All of this should be computed for every reference family 
    # Pax2/5/8 would a nice test case for the oversplitting
    
    # orgthoup with the highest number of 
    # a ‘best hit’ approach that took into account the largest Possvm-derived
    # cluster whose contents overlapped with the reference;
    
    #possum_ogs = unique(cl_df[cl_df$ref_fam == ref_fam,]$og)
    #best_og = names(sort(table(cl_df$og)[possum_ogs],decreasing = T))[1]
    best_og = names(sort(table(cl_df[cl_df$ref_fam == ref_fam,]$og),decreasing = T))[1]
    
    # True positives  - overlap
    TP = nrow(cl_df[cl_df$ref_fam == ref_fam & cl_df$og == best_og,])
    # predicted positives - all sequences in the best OG
    PP = nrow(cl_df[cl_df$og == best_og,])
    # positives in the population 
    P = nrow(cl_df[cl_df$ref_fam == ref_fam,])
    precision = TP/PP
    recall = TP/P
    F1 = 2*(precision*recall)/(precision + recall)
    o = data.frame(ref_fam = ref_fam,best_og = best_og,P = P, TP = TP, PP = PP, precision = precision, recall = recall, F1 = F1)
    return(o)
  })
  famdf = do.call(rbind,famdf)
  return(famdf)
})
for(i in seq_along(res)){
  res[[i]]$dataset = names(res)[i]
}
res=do.call(rbind,res)
write.table(res,'downstream/data/classification_results.tab',sep = '\t',row.names = F,quote = F)

# Calculate adjusted rand indices
r = sapply(dfs,FUN = function(x){
  fossil::adj.rand.index(as.integer(as.factor(x$ref_fam)),as.integer(as.factor(x$og)))
})
r = as.data.frame(r)
write.table(r,'downstream/data/classification_Rand.tab',sep = '\t',row.names = T,col.names =F,quote = F)
# the stats we get are worse but this is because we are not using the outgroups.
