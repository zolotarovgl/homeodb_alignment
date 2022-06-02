# HomeoDB2 phylogenies 
__TODOs__:
* build phylogenies for ANTPs
* build phylogenies for PRDs
* Compare obtained family classifications with what's "known" for human genes using adjusted Rand index  
    * what's now is deduced from gene classification in HomeoDB2
* these results will be later used to compare "the best case" performance with classification from TF evolution pipeline


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
bioawk -c fastx '$name ~ /ANTP/ {print ">"$name"\n"$seq}' data/HomeoDB2_renamed.fa > tmp/ANTP.fa
bioawk -c fastx '$name ~ /PRD/ {print ">"$name"\n"$seq}' data/HomeoDB2_renamed.fa > tmp/PRD.fa
```
## Phylogenies 

Now, obtain the phylogenies:

```
./get_phy.sh tmp/PRD.fa
./get_phy.sh tmp/ANTP.fa
```

## Orthogroup calling  

Once the trees are ready, we can call the orthogroups using possum:
```
TODO: call the orthogroups
```

## Orthogroup classification   

Classify the orthogroups w.r.t. to the known families.  

