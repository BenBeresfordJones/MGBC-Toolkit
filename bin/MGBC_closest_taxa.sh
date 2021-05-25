#!/bin/bash

# Author: Benjamin Beresford-Jones
# Date: 13/05/2021

usage()
{
cat << EOF
Usage: MGBC_Tk closest_taxa <options>

MGBC species comparison - Identify the most closely related gut bacterial species between humans and mice.

Options:
   -i	   Species taxon (GTDB r95 taxonomy) or genome id to query between hosts. [REQUIRED]
		E.g. "Bacteroides finegoldii", GUT_GENOME000122, or MGBC000577
   -o      Specify output file to write to. [REQUIRED]

EOF
}

FEATURE=
OUTFILE=

while getopts “i:o:” OPTION
do
     case ${OPTION} in
	 i)
	     FEATURE=${OPTARG}
	     ;;
         o)
             OUTFILE=${OPTARG}
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

## source variable paths
. ___VARPATH___


## check commandline inputs

if [ -z "$FEATURE" ]
then
	echo "$(timestamp) ERROR : Please supply a species taxon or a genome id to query with the -i flag."
	usage
	exit 2
fi

if [ -z $OUTFILE ]
then
	echo "$(timestamp) ERROR : Please supply a file to write output to with the -o flag."
	usage
	exit 2
fi

# get species representative genome
if $(echo $FEATURE | grep -q "^MGBC")
then
        TAXA=
        REP=$(grep -Fw "$FEATURE" $MGENREP | cut -f2 | sort -u)
elif $(echo $FEATURE | grep -q "^GUT_GENOME")
then
        TAXA=
        REP=$(grep -Fw "$FEATURE" $HGENREP | cut -f2 | sort -u)
else
        FSPEC="s__${FEATURE}"
        TAXA=TRUE
        REP=$(grep -Fwh "$FSPEC" $MGENREP $HGENREP | cut -f2 | sort -u)
fi


# check if a genome rep has been found
if [ -z "$REP" ]
then
	echo "$(timestamp) ERROR : No records for this taxon/genome exist. Please ensure that the species name is correct according to GTDB r95. Alternatively this species has not been represented in the gut microbiota of humans or mice. Exiting."
	usage
	exit 2
fi

# header
printf "Direction\tDatabase\tReference_genome\tQuery_genome\tDistance\tReference_taxonomy\tQuery_taxonomy\n" > $OUTFILE

if [ $(echo $REP | wc -w) == 1 ]
then
        if $(echo $REP | grep -q "^MGBC")
        then
             HOST="MOUSE"
             if [ -z $TAXA ]
             then
                echo "$(timestamp) INFO : MOUSE-derived genome supplied. Identifying the closest related HUMAN species."
             else
                echo "$(timestamp) INFO : This species is MOUSE-SPECIFIC."
             fi

             awk -v genrep="$REP" ' $2 == genrep ' $CLTAX | sed 's/^/M2H\t/g' >> $OUTFILE

        elif $(echo $REP | grep -q "^GUT_GENOME")
        then
             HOST="HUMAN"
             if [ -z $TAXA ]
             then
                echo "$(timestamp) INFO : HUMAN-derived genome supplied. Identifying the closest related MOUSE species."
             else
                echo "$(timestamp) INFO : This species is HUMAN-SPECIFIC."
             fi

             awk -v genrep="$REP" ' $2 == genrep ' $CLTAX | sed 's/^/H2M\t/g' >> $OUTFILE
        fi


elif [ $(echo $REP | wc -w) == 2 ]
then
	HOST="SHARED"
	echo "$(timestamp) INFO : This species is SHARED between host microbiotas."

	R1=$(echo $REP | cut -f1 -d " ")
	awk -v genrep="$R1" ' $2 == genrep ' $CLTAX | sed 's/^/H2M\t/g' >> $OUTFILE
	R2=$(echo $REP | cut -f1 -d " ")
        awk -v genrep="$R2" ' $2 == genrep ' $CLTAX | sed 's/^/M2H\t/g' >> $OUTFILE

else
	echo "$(timestamp) ERROR : Something went wrong, and multiple species have been selected. Exiting."
	exit 1
fi

echo "$(timestamp) INFO : Closest taxonomic and functional species data written to $(readlink -f $OUTFILE)."

