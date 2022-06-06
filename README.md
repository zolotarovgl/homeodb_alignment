# HomeoDB2 phylogenies 
__TODOs__:
* build phylogenies for ANTPs -DONE
* build phylogenies for PRDs - DONE
* Compare obtained family classifications with HomeoDB2 gene family assignments for human genes using adjusted Rand index or similar metrices 
* Do this for classifications obtained on the "raw" and GR-improved trees  




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

Get ANTP and PRD classes:
```
mkdir -p tmp
PREFS=( ANTP PRD POU TALE )
for PREF in ${PREFS[@]};
do echo $PREF
bioawk -c fastx -v PREF="$PREF" '$name ~ PREF {print ">"$name"\n"$seq}' data/HomeoDB2_renamed.fa > tmp/${PREF}.fa
done
```
## Phylogenies 

Now, obtain the phylogenies:

```
for PREF in ${PREFS[@]}; do
echo $PREF
scripts/get_phy.sh tmp/${PREF}.fa &> output/${PREF}.log
done
```

## Orthogroup calling  

Once the trees are ready, we can call the orthogroups using possum:

```
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
After generax has finished, let's call the orthogroups and compare resulting groupings:

```
GR_OUTDIR=generax_out
PREFS=( ANTP PRD )
for PREF in ${PREFS[@]}; do
echo $PREF
i=${GR_OUTDIR}/results/${PREF}/geneTree.newick
python scripts/possvm-orthology/possvm.py -o output -s 0 -i $i  --skipprint -refsps Human -itermidroot 10 -min_support_transfer 10 --cut_gene_names 100 -ogprefix OG -p ${PREF}_Generax
done
```