OUTDIR=output

mkdir -p ${OUTDIR}
PREF=$(basename "${1%.*}")
echo $PREF
mafft --maxiterate 1000 --globalpair --thread 1 $1 > tmp/$PREF\.l.fa
clipkit tmp/$PREF\.l.fa -m kpic-gappy -o tmp/$PREF\.lt.fa -g 0.7
iqtree2 -s tmp/$PREF\.lt.fa -m TEST -mset LG,WAG,JTT -nt AUTO -ntmax 10 -bb 1000 -pre ${OUTDIR}/$PREF\_phy -nm 10000 -nstop 200 -cptime 1800
