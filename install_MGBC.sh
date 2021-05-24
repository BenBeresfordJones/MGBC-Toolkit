#!/bin/bash

# Author: Benjamin Beresford-Jones
# Date: 23/05/2021

usage()
{
cat << EOF
Usage: MGBC_Tk install <options>

Install the MGBC-Toolkit datasets and compile. Default settings are to install databases for 'closest_tax' and 'feature_search' (requires 20 Gb memory).

Database install settings can be modified with the below options:
   -f	   Install full toolkit including blast database (requires ~60 Gb memory).
   -l	   Install reduced toolkit for only 'closest_tax' module functionality (requires <100 Mb memory).

Other options:
   -F	   Force install. Overwrites prior installed datasets.
   -h	   Show usage and exit.

EOF
}

FULL=
LITE=
FORCE=
HELP=

while getopts “flFh” OPTION
do
     case ${OPTION} in
	 f)
	     FULL=TRUE
	     ;;
         l)
             LITE=TRUE
             ;;
         F)
             FORCE=TRUE
             ;;
         h)
             HELP=TRUE
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

if [ ! -z $HELP ]
then
	usage
	exit
fi

DATA=$(pwd)/data
BINPATH=$(pwd)/bin
SRCPATH=$(pwd)/src
BLASTDBPATH=$(pwd)/blast_db

if [ $(basename -a $(pwd)) != "MGBC-Toolkit" ]
then
	echo "$(timestamp) ERROR : Please run install module from the MGBC_Tk directory."
	exit 3
fi

if [ ! -f $SRCPATH/var.init ]
then
	echo "$(timestamp) ERROR : Something went wrong... var.init cannot be found. Exiting."
	exit 1
fi

if [ ! -d $BINPATH ]
then
	echo "$(timestamp) ERROR : Something went wrong locating the binary directory... Exiting."
	exit 1
fi

if [ ! -d $DATA ]; then mkdir $DATA; fi


# dataset links
MGBC_DB_1=https://zenodo.org/record/4781762/files/mgbc-df_b1.tar.gz
MGBC_DB_2=https://zenodo.org/record/4781762/files/mgbc-df_b2.tar.gz
MGBC_DB_3=https://zenodo.org/record/4782462/files/mgbc-df_b3.tar.gz
BLAST_DB=https://zenodo.org/record/4781762/files/blast_db.tar.gz


if [ -z $FULL ] && [ ! -z $LITE ]
then
	if [ -f $SRCPATH/var.src ] && [ -f $DATA/mgbc_rep_index_26640.tsv ] && [ -z $FORCE ]
	then
		echo "$(timestamp) ERROR : LITE Toolkit is already compiled. Please use the -F option to overwrite. Exiting."
		exit 1
		usage
	elif [ -f $SRCPATH/var.src ] && [ -f $DATA/mgbc_rep_index_26640.tsv ] && [ ! -z $FORCE ]
	then
		echo "$(timestamp) INFO : Overwriting previous install."
	fi

        echo "$(timestamp) INFO : Running LITE install."

	sed "s+__BINPATH__+$BINPATH+g" $SRCPATH/var.init > $SRCPATH/var.src

        echo "$(timestamp) INFO : Installing databases."
        wget -O $DATA/mgbc-df_b1.tar.gz $MGBC_DB_1 -nv --show-progress

        echo "$(timestamp) INFO : Extracting databases."
        tar --overwrite -xf $DATA/mgbc-df_b1.tar.gz -C ./data/

        # clean up
        rm $DATA/mgbc-df_b1.tar.gz

        if [ -f $DATA/closest_tax.tsv ] && \
                [ -f $DATA/mgbc_rep_index_26640.tsv ] && \
                [ -f $DATA/uhgg_rep_index_100456.tsv ]
        then
                echo "$(timestamp) INFO : Data files installed correctly. Compiling toolkit."
        else
                echo "$(timestamp) ERROR : Something went wrong with the install... Exiting."
                exit 1
        fi

        sed -i "s+__DB1PATH__+$DATA+g" $SRCPATH/var.src

elif [ -z $FULL ] && [ -z $LITE ]
then
        if [ -f $SRCPATH/var.src ] && [ -f $DATA/tax_rep_index.tsv ] && [ -z $FORCE ]
        then
                echo "$(timestamp) ERROR : Toolkit is already compiled. Please use the -F option to overwrite. Exiting."
                exit 1
                usage
        elif [ -f $SRCPATH/var.src ] && [ -f $DATA/tax_rep_index.tsv ] && [ ! -z $FORCE ]
	then
                echo "$(timestamp) INFO : Overwriting previous install."
        fi

	echo "$(timestamp) INFO : Running DEFAULT install."

	sed "s+__BINPATH__+$BINPATH+g" $SRCPATH/var.init > $SRCPATH/var.src

	echo "$(timestamp) INFO : Installing databases."
	wget -O $DATA/mgbc-df_b1.tar.gz $MGBC_DB_1 -nv --show-progress
	wget -O $DATA/mgbc-df_b2.tar.gz $MGBC_DB_2 -nv --show-progress

	echo "$(timestamp) INFO : Extracting databases. Please be patient."
	tar --overwrite -xf $DATA/mgbc-df_b1.tar.gz -C ./data/
	tar --overwrite -xf $DATA/mgbc-df_b2.tar.gz -C ./data/

	# clean up
	rm $DATA/mgbc-df_b1.tar.gz $DATA/mgbc-df_b2.tar.gz

	if [ -f $DATA/closest_tax.tsv ] && \
		[ -f $DATA/mgbc_rep_index_26640.tsv ] && \
		[ -f $DATA/uhgg_rep_index_100456.tsv ] && \
		[ -f $DATA/ips.out.tsv ] && \
		[ -f $DATA/eggnog.out.tsv ] && \
		[ -f $DATA/tax_rep_index.tsv ] && \
		[ -f $DATA/clus90_clusmem.tsv ]
	then
		echo "$(timestamp) INFO : Data files installed correctly. Compiling toolkit."
	else
		echo "$(timestamp) ERROR : Something went wrong with the install... Exiting."
		exit 1
	fi

	sed -i "s+__DB1PATH__+$DATA+g" $SRCPATH/var.src
	sed -i "s+__DB2PATH__+$DATA+g" $SRCPATH/var.src

elif [ ! -z $FULL ] && [ -z $LITE ]
then
        if [ -f $SRCPATH/var.src ] && [ -f $BLASTDBPATH/mmseqs_cluster_rep.fa.pal ] && [ -f $DATA/clus100_clusmem.tsv ] && [ -z $FORCE ]
        then
                echo "$(timestamp) ERROR : FULL Toolkit is already compiled. Please use the -F option to overwrite. Exiting."
                exit 1
                usage

        elif [ -f $SRCPATH/var.src ] && [ -f $BLASTDBPATH/mmseqs_cluster_rep.fa.pal ] && [ -f $DATA/clus100_clusmem.tsv ] && [ ! -z $FORCE ]
	then
                echo "$(timestamp) INFO : Overwriting previous install."
        fi


	if [ -f $SRCPATH/var.src ] && [ -f $DATA/tax_rep_index.tsv ] && [ -z $FORCE ]
        then
                echo "$(timestamp) INFO : DEFAULT Toolkit is already compiled. Skipping re-install, and installing blast database."

		echo "$(timestamp) INFO : Running FULL install."

                wget -O $DATA/mgbc-df_b3.tar.gz $MGBC_DB_3 -nv --show-progress
                wget $BLAST_DB -nv --show-progress

                echo "$(timestamp) INFO : Extracting databases. Please be patient."
                tar --overwrite -xf $(pwd)/blast_db.tar.gz
                rm $(pwd)/blast_db.tar.gz

                tar --overwrite -xf $DATA/mgbc-df_b3.tar.gz -C ./data/
                rm $DATA/mgbc-df_b3.tar.gz

                # check install
                if [ -f $DATA/closest_tax.tsv ] && \
                        [ -f $DATA/mgbc_rep_index_26640.tsv ] && \
                        [ -f $DATA/uhgg_rep_index_100456.tsv ] && \
                        [ -f $DATA/ips.out.tsv ] && \
                        [ -f $DATA/eggnog.out.tsv ] && \
                        [ -f $DATA/tax_rep_index.tsv ] && \
                        [ -f $DATA/clus90_clusmem.tsv ] && \
                        [ -f $DATA/clus100_clusmem.tsv ] && \
                        [ -f $BLASTDBPATH/mmseqs_cluster_rep.fa.pal ]
                then
                        echo "$(timestamp) INFO : Data files installed correctly. Compiling toolkit."
                else
                        echo "$(timestamp) ERROR : Something went wrong with the install... Exiting."
                        exit 1
                fi

                sed -i "s+__DB3PATH__+$DATA+g" $SRCPATH/var.src
                sed -i "s+__BDBPATH__+$BLASTDBPATH+g" $SRCPATH/var.src

        elif [ -f $SRCPATH/var.src ] && [ -f $DATA/tax_rep_index.tsv ] && [ ! -z $FORCE ]
	then
                echo "$(timestamp) INFO : DEFAULT Toolkit is already compiled. Overwriting previous install."

	        echo "$(timestamp) INFO : Running FULL install."

		sed "s+__BINPATH__+$BINPATH+g" $SRCPATH/var.init > $SRCPATH/var.src

	        echo "$(timestamp) INFO : Installing databases."
	        wget -O $DATA/mgbc-df_b1.tar.gz $MGBC_DB_1 -nv --show-progress
	        wget -O $DATA/mgbc-df_b2.tar.gz $MGBC_DB_2 -nv --show-progress
                wget -O $DATA/mgbc-df_b3.tar.gz $MGBC_DB_3 -nv --show-progress
                wget $BLAST_DB -nv --show-progress

	        echo "$(timestamp) INFO : Extracting databases. Please be patient."
	        tar --overwrite -xf $DATA/mgbc-df_b1.tar.gz -C ./data/
	        tar --overwrite -xf $DATA/mgbc-df_b2.tar.gz -C ./data/

	        rm $DATA/mgbc-df_b1.tar.gz $DATA/mgbc-df_b2.tar.gz

                tar --overwrite -xf $(pwd)/blast_db.tar.gz
		rm $(pwd)/blast_db.tar.gz

                tar --overwrite -xf $DATA/mgbc-df_b3.tar.gz -C ./data/
		rm $DATA/mgbc-df_b3.tar.gz

		# check install
	        if [ -f $DATA/closest_tax.tsv ] && \
	                [ -f $DATA/mgbc_rep_index_26640.tsv ] && \
        	        [ -f $DATA/uhgg_rep_index_100456.tsv ] && \
	      	        [ -f $DATA/ips.out.tsv ] && \
	                [ -f $DATA/eggnog.out.tsv ] && \
	                [ -f $DATA/tax_rep_index.tsv ] && \
	                [ -f $DATA/clus90_clusmem.tsv ] && \
                        [ -f $DATA/clus100_clusmem.tsv ] && \
			[ -f $BLASTDBPATH/mmseqs_cluster_rep.fa.pal ]
	        then
	                echo "$(timestamp) INFO : Data files installed correctly. Compiling toolkit."
	        else
	                echo "$(timestamp) ERROR : Something went wrong with the install... Exiting."
	                exit 1
	        fi

	        sed -i "s+__DB1PATH__+$DATA+g" $SRCPATH/var.src
	        sed -i "s+__DB2PATH__+$DATA+g" $SRCPATH/var.src
		sed -i "s+__DB3PATH__+$DATA+g" $SRCPATH/var.src
		sed -i "s+__BDBPATH__+$BLASTDBPATH+g" $SRCPATH/var.src

	else # install from scratch

                echo "$(timestamp) INFO : Running FULL install."

                sed "s+__BINPATH__+$BINPATH+g" $SRCPATH/var.init > $SRCPATH/var.src

                echo "$(timestamp) INFO : Installing databases."
                wget -O $DATA/mgbc-df_b1.tar.gz $MGBC_DB_1 -nv --show-progress
                wget -O $DATA/mgbc-df_b2.tar.gz $MGBC_DB_2 -nv --show-progress
                wget -O $DATA/mgbc-df_b3.tar.gz $MGBC_DB_3 -nv --show-progress
                wget $BLAST_DB -nv --show-progress

                echo "$(timestamp) INFO : Extracting databases. Please be patient."
                tar --overwrite -xf $DATA/mgbc-df_b1.tar.gz -C ./data/
                tar --overwrite -xf $DATA/mgbc-df_b2.tar.gz -C ./data/

                rm $DATA/mgbc-df_b1.tar.gz $DATA/mgbc-df_b2.tar.gz

                tar --overwrite -xf $(pwd)/blast_db.tar.gz
                rm $(pwd)/blast_db.tar.gz

                tar --overwrite -xf $DATA/mgbc-df_b3.tar.gz -C ./data/
                rm $DATA/mgbc-df_b3.tar.gz

                # check install
                if [ -f $DATA/closest_tax.tsv ] && \
                        [ -f $DATA/mgbc_rep_index_26640.tsv ] && \
                        [ -f $DATA/uhgg_rep_index_100456.tsv ] && \
                        [ -f $DATA/ips.out.tsv ] && \
                        [ -f $DATA/eggnog.out.tsv ] && \
                        [ -f $DATA/tax_rep_index.tsv ] && \
                        [ -f $DATA/clus90_clusmem.tsv ] && \
                        [ -f $DATA/clus100_clusmem.tsv ] && \
                        [ -f $BLASTDBPATH/mmseqs_cluster_rep.fa.pal ]
                then
                        echo "$(timestamp) INFO : Data files installed correctly. Compiling toolkit."
                else
                        echo "$(timestamp) ERROR : Something went wrong with the install... Exiting."
                        exit 1
                fi

                sed -i "s+__DB1PATH__+$DATA+g" $SRCPATH/var.src
                sed -i "s+__DB2PATH__+$DATA+g" $SRCPATH/var.src
                sed -i "s+__DB3PATH__+$DATA+g" $SRCPATH/var.src
                sed -i "s+__BDBPATH__+$BLASTDBPATH+g" $SRCPATH/var.src

	fi

fi

chmod a+x $BINPATH/*.sh
sed -i "s+___VARPATH___+$SRCPATH/var.src+g" ./MGBC_Tk
sed -i "s+___VARPATH___+$SRCPATH/var.src+g" $BINPATH/MGBC_closest_taxa.sh
sed -i "s+___VARPATH___+$SRCPATH/var.src+g" $BINPATH/MGBC_feature.sh
sed -i "s+___VARPATH___+$SRCPATH/var.src+g" $BINPATH/MGBC_blast.sh

echo "$(timestamp) INFO : Install complete."
