#!/bin/bash

# Author: Benjamin Beresford-Jones
# Date: 04/05/2021

usage()
{
cat << EOF
usage: $0 options

MGBC feature search - Find and compare functional annotations between human and mouse gut bacteria.

OPTIONS:
   -d	   Dataset to search, one of EGGNOG or INTERPROSCAN [REQUIRED]
   -i	   Feature id(s) from one of the searchable schemes: [REQUIRED]
	     EGGNOG:
		KEGG	 e.g. K00929, 2.7.2.7, ko00650, M00027, R01688
		CAZy	 e.g. GH48
		GO	 e.g. GO:0047761

	     INTERPROSCAN:
		InterPro e.g. IPR011245
		BioCyc	 e.g. PWY-4321
		Reactome e.g. R-HSA-964975
		KEGG (ENZYME or PATHWAY)  e.g. 2.7.2.7, ko00650
		GO	 e.g. GO:0047761

	   Multiple feature ids can be provided as a comma-separated list (e.g. IPR011245,IPR014079). Only returns data for genomes that encode all features supplied.

   -o      Directory to write to [default: "."]
   -p      Prefix for output files [default: "<feature>.<database>"]

EOF
}

FEATURE=
DATABASE=
OUTDIR=
PREFIX=

while getopts “i:d:o:p:” OPTION
do
     case ${OPTION} in
	 i)
	     FEATURE=${OPTARG}
	     ;;
         o)
             OUTDIR=${OPTARG}
             ;;
	 p)
	     PREFIX=${OPTARG}
	     ;;
	 d)
	     DATABASE=${OPTARG}
	     ;;
         ?)
             usage
             exit
             ;;
     esac
done

timestamp() {
date +"%H:%M:%S"
}


if [ -z $(which Rscript) ]
then
	echo "$(timestamp) ERROR : No path variable for Rscript (r/3.6.0). Please load R, or add Rscript to path. Exiting."
	exit 1
fi

## check install
if [ ! -f ___VARPATH___ ]
then
	echo "ERROR : Please run install module first. Exiting."
	exit 1
fi

## source variable paths
. ___VARPATH___


## check commandline inputs

if [ -z $DATABASE ]
then
	echo "$(timestamp) ERROR : Please supply one of either EGGNOG or INTERPROSCAN with the -d flag to specific the query dataset."
	usage
	exit 2
fi

if $(echo "INTERPROSCAN" | grep -iq "^$DATABASE")
then
	echo "$(timestamp) INFO : Querying the INTERPROSCAN dataset."
	DATA=$IPR_DATA
	PREFDB="ips"
elif $(echo "EGGNOG" | grep -iq "^$DATABASE")
then
	echo "$(timestamp) INFO : Querying the EGGNOG dataset."
        DATA=$ENOG_DATA
	PREFDB="eggnog"
else
	echo "$(timestamp) ERROR : Please supply one of either EGGNOG or INTERPROSCAN with the -d flag to specific the query dataset."
        usage
        exit 2
fi


if [ -z $FEATURE ]
then
     echo "$(timestamp) ERROR : Please supply a feature id to query with the -i flag."
     usage
     exit 1
fi

if [ -z $OUTDIR ]
then
     OUTDIR="."
fi

if [ ! -d $OUTDIR ]; then mkdir -p $OUTDIR; fi

if [ -z $PREFIX ]
then
	FEATURE_S=$(echo "$FEATURE" | sed -e 's/:/_/g' -e 's/,/_/g')
	PREFIX=$FEATURE_S.$PREFDB
fi

OUTPREF=$(readlink -f $OUTDIR/$PREFIX)

echo "$(timestamp) INFO : Querying $FEATURE."
echo "$(timestamp) INFO : Writing output to $OUTPREF.species_summary.tsv"


TMP=$OUTPREF.TMP

if [ ! -d $TMP ]; then mkdir $TMP; fi


FCOUNT=$(echo "$FEATURE" | sed 's/,/\n/g' | wc -l)
echo "$(timestamp) INFO : Features provided: $FCOUNT"

if [ $FCOUNT == 1 ]
then
	echo "$(timestamp) INFO : Fetching gene-level data for $FEATURE."

	awk -v feature="$FEATURE" ' $1 == feature ' $DATA | cut -f2 | sed 's/,/\n/g' > $TMP/genes.tmp

	if [ $(wc -l $TMP/genes.tmp | cut -d " " -f1) -eq 0 ]
	then
	        echo "$(timestamp) ERROR : Feature could not be found in dataset. Please doublecheck input is correct (including format), alternatively function has not been annotated."
	        exit 1
	fi

	grep -Fwf $TMP/genes.tmp $CLUS_90 > $TMP/clus90.tmp # get genes from representatives

	cut -f2 $TMP/clus90.tmp | sed 's/_.....$//g' | sort -u > $TMP/genomes.tmp # get genomes

elif [ $FCOUNT -gt 1 ]
then
	COUNT=1

	echo "$FEATURE" | sed 's/,/\n/g' | while read f; do
		echo "$(timestamp) INFO : Fetching gene-level data for $f."

		awk -v feature="$f" ' $1 == feature ' $DATA | cut -f2 | sed 's/,/\n/g' > $TMP/genes.$COUNT.tmp

	        if [ $(wc -l $TMP/genes.$COUNT.tmp | cut -d " " -f1) -eq 0 ]
	        then
	                echo "$(timestamp) WARNING : No genomes are annotated with $f. Moving on..."
		else
			grep -Fwf $TMP/genes.$COUNT.tmp $CLUS_90 > $TMP/clus90.tmp # get genes from representatives

		        cut -f2 $TMP/clus90.tmp | sed 's/_.....$//g' | sort -u > $TMP/genomes.$COUNT.tmp # get genomes
	        fi

		COUNT=$(( COUNT + 1 ))
	done

	if [ $(cat $TMP/genes.[1-9]*.tmp | wc -l) -eq 0 ]
        then
                echo "$(timestamp) ERROR : None of the provided features could be found in this dataset. Please doublecheck input is correct (including format), alternatively function has not been annotated."
                exit 1
        fi

	cat $TMP/genomes.[1-9]*.tmp | sort | uniq -c | awk -v fc=$FCOUNT ' { if ( $1 == fc ) { print $2 } } ' > $TMP/genomes.tmp

fi

# compile results

grep -Fwhf $TMP/genomes.tmp $TAXREP > $TMP/tax_rep.tmp

# provide intermediate statistics
HGCOUNT=$(grep "GUT_GENOME" $TMP/genomes.tmp -c)
MGCOUNT=$(grep "MGBC" $TMP/genomes.tmp -c)
HSCOUNT=$(cut -f5 $TMP/tax_rep.tmp | sort -u | grep -c "GUT_GENOME")
MSCOUNT=$(cut -f5 $TMP/tax_rep.tmp | sort -u | grep -c "MGBC")

if [ $FCOUNT -eq 1 ]
then
	echo "$(timestamp) INFO : $HGCOUNT human-derived genomes across $HSCOUNT species are predicted to encode this feature."
	echo "$(timestamp) INFO : $MGCOUNT mouse-derived genomes across $MSCOUNT species are predicted to encode this feature."
else
	echo "$(timestamp) INFO : $HGCOUNT human-derived genomes across $HSCOUNT species are predicted to encode this combination of features."
        echo "$(timestamp) INFO : $MGCOUNT mouse-derived genomes across $MSCOUNT species are predicted to encode this combination of features."
fi

# analyse at level of the pangenome
echo "$(timestamp) INFO : Getting pangenome-level data for this feature."

$BINPATH/summarise_feature_function.R "$TMP" "$FEATURE"

## check output
if [ ! -f $TMP/species.tmp.tsv ]
then
        echo "$(timestamp) ERROR : summarise_feature_function.R did not run correctly. Exiting."
        exit 1
fi

# generate final output files
cut -f1-8 $TMP/species.tmp.tsv > $OUTPREF.species_summary.tsv
cut -f1,9 $TMP/species.tmp.tsv > $OUTPREF.species_genome_index.tsv

# clean up
rm -r $TMP

echo "$(timestamp) INFO : Workflow finished! Pangenome data for $FEATURE written to $OUTPREF.species_summary.tsv"

