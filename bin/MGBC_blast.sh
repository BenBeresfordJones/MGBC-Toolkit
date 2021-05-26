#!/bin/bash

usage()
{
cat << EOF
usage: $0 options

MGBC sequence search - Blasts input sequence against the MGBC human-mouse protein catalogue.

OPTIONS:
   -i      Path to sequence input file [REQUIRED]
   -t	   Sequence type, either NUCL for nucleotide or PROT for protein [REQUIRED]
   -s      Sequence identity to use as threshold for filtering results [default: 50]
   -o      Directory to write to [default: "."]
   -p      Prefix for output files [default: "<-i>"]

EOF
}

BLAST_IN=
SEQ_ID=
SEQ_TYPE=
OUT=
PREFIX=

while getopts “i:t:s:o:p:” OPTION
do
     case ${OPTION} in
         i)
             BLAST_IN=${OPTARG}
             ;;
         o)
             OUT=${OPTARG}
             ;;
         s)
             SEQ_ID=${OPTARG}
             ;;
	 t)
	     SEQ_TYPE=${OPTARG}
	     ;;
	 p)
	     PREFIX=${OPTARG}
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


## check install
if [ ! -f ___VARPATH___ ]
then
	echo "ERROR : Please run install module first. Exiting."
	exit 1
fi



if [ -z $(which Rscript) ]
then
	echo "$(timestamp) ERROR : No path variable for Rscript (r/3.6.0). Please load R, or add Rscript to path. Exiting."
	exit 35
fi

if [ -z $(which blastp) ] || [ -z $(which blastx) ]
then
	echo "$(timestamp) ERROR : No path variable for blastp/blastx. Please load blast/2.7.1, or add blast commands to path. Exiting."
	exit 35
fi

## source variable paths
. ___VARPATH___


if [ -z $BLAST_IN ]
then
     echo "$(timestamp) ERROR : Please supply a path to the sequence file to blast using the -i flag."
     usage
     exit 2
fi

if [ ! -f $BLAST_IN ]
then
     echo "$(timestamp) ERROR : The sequence file specified does not exist. Exiting."
     usage
     exit 2
fi

if [ -z $SEQ_TYPE ]
then
     echo "$(timestamp) ERROR : Please specify the sequence type (NUCL or PROT) using the -t flag."
     usage
     exit 2
fi

if $(echo "NUCLEOTIDE" | grep -iq "^$SEQ_TYPE")
then
	echo "$(timestamp) INFO : Nucleotide sequence specified, running blastx."
	SEQ_TYPE="NUCL"
elif $(echo "PROTEIN" | grep -iq "^$SEQ_TYPE")
then
	echo "$(timestamp) INFO : Protein sequence specified, running blastp."
	SEQ_TYPE="PROT"
else
	echo "$(timestamp) ERROR : Please specify the sequence type (NUCL or PROT) using the -t flag."
        usage
        exit 2
fi


if [ -z $SEQ_ID ]
then
     SEQ_ID=50
fi


if [ -z $OUT ]
then
     OUT=$(pwd)
fi

if [ ! -d $OUT ]; then mkdir -p $OUT; fi

if [ -z $PREFIX ]
then
	PREFIX=$(basename $BLAST_IN | sed 's/\(.*\)\..*/\1/')
fi

OUTPREF=$(readlink -f $OUT/$PREFIX)

TMP=$OUTPREF.TMP
if [ ! -d $TMP ]; then mkdir $TMP; fi


if [ $SEQ_TYPE == "PROT" ]
then
	echo "$(timestamp) INFO : Running blastp."
	blastp -query $BLAST_IN -db $CLUS_100_REP -outfmt '6 qseqid sseqid pident bitscore evalue length qlen slen' -evalue 1e-5 -max_target_seqs 50000 -out $TMP/blast.out
elif [ $SEQ_TYPE == "NUCL" ]
then
	echo "$(timestamp) INFO : Running blastx."
	blastx -query $BLAST_IN -db $CLUS_100_REP -outfmt '6 qseqid sseqid pident bitscore evalue length qlen slen' -evalue 1e-5 -max_target_seqs 50000 -out $TMP/blast.out
fi

if [ ! -f $TMP/blast.out ]
then
	echo "$(timestamp) ERROR : Something went wrong with blast. Exiting."
	exit 1
fi

echo "$(timestamp) INFO : Analysing blast output."

awk -v SEQ_ID=$SEQ_ID ' $3 >= SEQ_ID && $4 >= 50 ' $TMP/blast.out > $TMP/qc.out # filter output by qc value
cut -f2 $TMP/qc.out | sort -u > $TMP/genes.tmp # get rep gene hits
grep -Fwf $TMP/genes.tmp $CLUS_100 > $TMP/clus100.tmp # expand gene list to cluster members
cut -f2 $TMP/clus100.tmp | grep -Fwf - $CLUS_90 > $TMP/clus90.tmp # get clus90 reps
grep -Fwf $TMP/genes.tmp $TMP/clus100.tmp | cut -f2 | sed 's/_.....$//g' | grep -Fwf - $TAXREP > $TMP/tax_rep.tmp # tax-rep metadata

echo "$(timestamp) INFO : Getting genome-level analyses."

while read REF100
do
	QC=$(grep -Fw "$REF100" $TMP/qc.out | head -n1) # take the highest p-value match for multiple hits
	REF90=$(grep -Fw "$REF100" $TMP/clus100.tmp | cut -f2 | grep -Fwf - $TMP/clus90.tmp | cut -f1 | sort | uniq -c | sort -rg | head -n1 | grep -o -e "GUT_GENOME.*" -e "MGBC.*")
	grep -Fw "$REF100" $TMP/clus100.tmp | cut -f2 | sed 's/_.....$//g' | while read GENOME
	do
		TAXONOMY=$(awk -v genome=$GENOME ' $1 == genome ' $TMP/tax_rep.tmp)

		printf "$TAXONOMY\t$QC\t$REF90\n"
	done
done < $TMP/genes.tmp > $TMP/genome_summary.tsv

echo "$(timestamp) INFO : Getting pangenome-level analyses."

$BINPATH/summarise_MGBC_blast.R "$TMP"

if [ ! -f $TMP/species.tmp.tsv ]
then
	echo "$(timestamp) ERROR : summarise_MGBC_blast.R did not run correctly, exiting."
	exit 1
fi

cut -f1-8,11- $TMP/species.tmp.tsv > $OUTPREF.species_summary.tsv
cut -f1,9,10 $TMP/species.tmp.tsv > $OUTPREF.gene_data.tsv

mv $TMP/qc.out $OUTPREF.blast.qc

# clean up
rm -r $TMP

echo "$(timestamp) INFO : Workflow finished! Pangenome data written to $OUTPREF.species_summary.tsv"
