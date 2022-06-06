# HomeoDB2 phylogenies 
__TODOs__:
* build phylogenies for ANTPs
* build phylogenies for PRDs
* Compare obtained family classifications with what's "known" for human genes using adjusted Rand index  
    * what's now is deduced from gene classification in HomeoDB2
* these results will be later used to compare "the best case" performance with classification from TF evolution pipeline
* an additional analysis would be using GeneRax to potentially improve the classification. 



## Prepare the data  

Rename the sequences: 
```
perl -pe 's/(?<=Honeybee|Beetle|Fruitfly|Nematode|Amphioxus|Zebrafish|Frog|Mouse|Human|Chicken)\|/_/' data/HomeoDB2.fa | perl -pe 's/\|(?=HD[0-9]+)/_/g' > data/HomeoDB2_renamed.fa
# remove brackets:
sed -i 's/Hox9-13(15)/Hox9-13/g' data/HomeoDB2_renamed.fa
```

Get gene-to-family and class classfication:

```
grep '>'  data/HomeoDB2_renamed.fa  | sed -E 's/\|/\t/g' | sed 's/>//g' > data/HomeoDB2_classification.tab
```

Get classes for the alignment:
```
mkdir -p tmp
CLASSES=(ANTP PRD TALE POU)
for PREF in ${CLASSES[@]};do 
echo $PREF
bioawk -c fastx -v PREF="$PREF" '$name ~ PREF {print ">"$name"\n"$seq}' data/HomeoDB2_renamed.fa | sed 's/:/_/g' > tmp/${PREF}.fa
done
```
## Phylogenies 

Now, obtain the phylogenies:

```
for PREF in ${CLASSES[@]}; do
echo $PREF
scripts/get_phy.sh tmp/${PREF}.fa &> output/${PREF}.log
done
```

## Orthogroup calling  

Once the trees are ready, we can call the orthogroups using possum:

```
PREFS=( ANTP PRD )
for PREF in ${PREFS[@]}; do
echo $PREF
python scripts/possvm-orthology/possvm.py -s 0 -i output/${PREF}_phy.treefile  --skipprint -refsps Human -itermidroot 10 -min_support_transfer 10 --cut_gene_names 100 -ogprefix OG -p ${PREF}
done
```
This will create the files in `output` directory with OGs and transferred annotations.  

## Orthogroup classification   

Classify the orthogroups w.r.t. to the known families.  

**TODO** implement jaccard index / Rmd with comparison. 

## Optimize tree topology using GeneRax

* for this species tree should be present - `data/sps_tree.newick`

```
mpiexec -np 4 generax -s data/sps_tree.newick -f famfile --per-family-rates --strategy SPR -p generax_out
```
