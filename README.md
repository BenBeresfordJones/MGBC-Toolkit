![logo](https://github.com/BenBeresfordJones/MGBC/blob/main/MGBC_logo.png?raw=true)

[![DOI](https://zenodo.org/badge/370188822.svg)](https://zenodo.org/badge/latestdoi/370188822)

MGBC-Toolkit
============


This repository contains the wrapper scripts for accessing the taxonomic locations of functions between the human and mouse gut microbiotas using the [Mouse Gastrointestinal Bacteria Catalogue (MGBC)](https://github.com/BenBeresfordJones/MGBC).

## Contents ##
* [Prerequisites](#Prerequisites)
* [Installing the Toolkit](#Installing-the-Toolkit)
* [Running the Toolkit](#Running-the-Toolkit)
* [Module descriptions](#Module-descriptions)
  * [closest_taxa](#1-closest_taxa)
  * [feature_search](#2-feature_search)
  * [hm_blast](#3-hm_blast)


## Prerequisites ##
For non-bioinformaticians aiming to install and run the Toolkit on a personal device, the following executables must be installed and added to the `$PATH` variable:
* [wget](https://formulae.brew.sh/formula/wget#default) 
* GNU Bash utilities:
   * [coreutils](https://formulae.brew.sh/formula/coreutils#default)
   * [gnu-sed](https://formulae.brew.sh/formula/gnu-sed#default)
   * [gnu-tar](https://formulae.brew.sh/formula/gnu-tar#default)

These are standard bioinformatics tools that can be installed using [Homebrew](https://brew.sh). After installing the above utilities, add them to your `$PATH` variable by adding the following lines of code to one of `~/.profile`, `/etc/paths` or `~/.bashrc` (depending on your system):
```
PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"
PATH="/usr/local/opt/gnu-tar/libexec/gnubin:$PATH"
```
Files can be edited using the `nano` utility, e.g. `nano /etc/paths`. Exit the file (ctrl X) and save changes (Y, Enter). After sourcing the file, e.g. `. /etc/paths`, you should be able to install and run the Toolkit.


## Installing the Toolkit ##

To install the Toolkit, first clone this GitHub repository.

```
git clone https://github.com/BenBeresfordJones/MGBC-Toolkit
``` 

In the cloned repository, run the install script to install the required datasets and compile the Toolkit. Multiple options are provided for installing the Toolkit, and balance different levels of functionality with memory requirements. The default settings install the intermediate-size Toolkit (~20 Gb) that supports both the `closest_taxa` and the `feature_search` modules.

```
sh install_MGBC.sh <options>
``` 
Options:  
`-l` installs a reduced Toolkit (<100 Mb). Only supports the `closest_taxa` module.  
`-f` installs the FULL Toolkit (~60 Gb). Supports the `hm_blast` module.  
`-F` forces install. Overwrites prior installations.  

__Note:__ The full install will take some time (~20 minutes) to download and upack datasests.  

Finally, add the `MGBC_Tk` repository to your `$PATH` variable in `~/.profile`.
```
export PATH="/path/to/MGBC-Toolkit":$PATH
``` 

The installation process changes access permissions for the Toolkit automatically. However, if any 'permission' errors are seen, please run the following from the MGBC-Toolkit directory.
```
chmod -R +x bin
```

## Running the Toolkit ##

The MGBC-Toolkit provides multiple modules for identifying the taxonomic locations of functions of interest between the gut microbiotas of humans and mice. In addition, the Toolkit provides pan-function comparisons between species, to identify the most closely functionally related to species of interest in each host.

```
MGBC_Tk <module> <options>
``` 
Modules:  
`closest_taxa`   -> Find the closest taxonomically and functionally related species between hosts  
`feature_search` -> Find taxonomic locations of functional annotations (features) between hosts  
`hm_blast`       -> Identify taxonomic locations of protein coding sequences between hosts  


## Module descriptions ##

### 1) `closest_taxa` ###
Identifies host-specific and shared taxa, and returns the closest taxonomically and functionally related bacterial species for a supplied taxon of interest. 


__Usage:__
```
MGBC_Tk closest_taxa -i <SPECIES/GENOME_ID> -o <OUTFILE>
``` 
Arguments:  
`-i` Species taxon ([GTDB r95 taxonomy](https://gtdb.ecogenomic.org)) or genome id to query between hosts. [REQUIRED]  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; E.g. "Bacteroides finegoldii", GUT_GENOME000122, or MGBC000577  
`-o` Specify output file to write to. [REQUIRED]    


__Output:__  

Tab-separated output is written to the file supplied with `-o`:
```
Direction	Database	Reference_genome	Query_genome	Distance	Reference_taxonomy	Query_taxonomy
H2M	taxonomy	GUT_GENOME000122	MGBC000577	0.0370861949	d__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;g__Bacteroides;s__Bacteroides finegoldii	d__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;g__Bacteroides;s__Bacteroides xylanisolvens
H2M	all_annotations	GUT_GENOME000122	MGBC144733	0.126133176313989	d__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;g__Bacteroides;s__Bacteroides finegoldii	d__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;g__Bacteroides;s__Bacteroides caecimuris
H2M	CAZY.eggnog	GUT_GENOME000122	MGBC000465	0.120585713066765	d__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;g__Bacteroides;s__Bacteroides finegoldii	d__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;g__Bacteroides;s__Bacteroides ovatus
H2M	ENZYME.eggnog	GUT_GENOME000122	MGBC144733	0.153708760727894	d__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;g__Bacteroides;s__Bacteroides finegoldii	d__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;g__Bacteroides;s__Bacteroides caecimuris
H2M	GO.eggnog	GUT_GENOME000122	MGBC144528	0.065349722059964	d__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;g__Bacteroides;s__Bacteroides finegoldii	d__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;g__Bacteroides;s__Bacteroides congonensis
H2M	GO.ips	GUT_GENOME000122	MGBC144733	0.0740960848955073	d__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;g__Bacteroides;s__Bacteroides finegoldii	d__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;g__Bacteroides;s__Bacteroides caecimuris
H2M	InterPro.FAMILY	GUT_GENOME000122	MGBC144733	0.165490408236035	d__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;g__Bacteroides;s__Bacteroides finegoldii	d__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;g__Bacteroides;s__Bacteroides caecimuris
H2M	InterPro.ips	GUT_GENOME000122	MGBC144733	0.148322559056494	d__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;g__Bacteroides;s__Bacteroides finegoldii	d__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;g__Bacteroides;s__Bacteroides caecimuris
H2M	KEGG.eggnog	GUT_GENOME000122	MGBC144733	0.19345098129567	d__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;g__Bacteroides;s__Bacteroides finegoldii	d__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;g__Bacteroides;s__Bacteroides caecimuris
H2M	MetaCyc.ips	GUT_GENOME000122	MGBC000577	0.0608922418359543	d__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;g__Bacteroides;s__Bacteroides finegoldii	d__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;g__Bacteroides;s__Bacteroides xylanisolvens
H2M	MODULE.eggnog	GUT_GENOME000122	MGBC140467	0.0992936796831323	d__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;g__Bacteroides;s__Bacteroides finegoldii	d__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;g__Bacteroides;s__
H2M	PATHWAY.eggnog	GUT_GENOME000122	MGBC144733	0.0691588381965163	d__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;g__Bacteroides;s__Bacteroides finegoldii	d__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;g__Bacteroides;s__Bacteroides caecimuris
H2M	PATHWAY.ips	GUT_GENOME000122	MGBC000324	0.0240883127789142	d__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;g__Bacteroides;s__Bacteroides finegoldii	d__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;g__Bacteroides;s__Bacteroides thetaiotaomicron
H2M	REACTION.eggnog	GUT_GENOME000122	MGBC144528	0.114821031379945	d__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;g__Bacteroides;s__Bacteroides finegoldii	d__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;g__Bacteroides;s__Bacteroides congonensis
H2M	Reactome.ips	GUT_GENOME000122	MGBC000324	0.0735072656222904	d__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;g__Bacteroides;s__Bacteroides finegoldii	d__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;g__Bacteroides;s__Bacteroides thetaiotaomicron
```
Considering the example outfile for `MGBC_Tk closest_taxa -i "Bacteroides finegoldii" -o Bf_cltax.tsv` above: 
* Column 1 (`Direction`) indicates the direction of comparison: 
   * H2M means a human species was provided, and the closest taxonomic/functional mouse species has been returned, i.e. in this case.
   * M2H indicates the reverse i.e. a mouse species was supplied, and human species returned.
   * If a species is shared between hosts, the output file will contain data for both H2M and M2H analyses.
* Column 2 (`Database`) indicates the databases that have been queried. 
   * `taxonomy` indicates the closest taxonomic species, in this case `Bacteroides xylanisolvens`. 
   * Multiple functional databases are queried but these are not equivalent: 
      * `all_annotations` combines all functional schemes, and therefore has the best resolution for functional relatedness.
      * `InterPro.ips` and `InterPro.family` compare all the InterPro entries or just the protein family entries respectively.
      * `KEGG.eggnog` compares all KO groups.
   * All of the above agree that `Bacteroides caecimuris` is likely to be the closest functionally related mouse species (H2M) to human `Bacteroides finegoldii` at a pan-function level.
   * `CAZY.eggnog` queries only the [Carbohydrate-Active enZYmes](http://www.cazy.org). This suggests that `Bacteroides ovatus` might be more closely related when only considering these functions.
* Columns 3 (`Reference_genome`) and 6 (`Reference_taxonomy`) contain the genome-id and the species taxonomy for the provided species.
* Columns 4 (`Query_genome`) and 7 (`Query_taxonomy`) contain the genome-id and the species taxonomy of the closest related species in the other host.
* Column 5 (`Distance`) is the distance between genomes, but is database-specific.


### 2) `feature_search` ###
Finds the taxonomic locations (genomes and species) of supplied functional features. Can analyse multiple functional annotation schemes from eggNOG emapper-v2 and InterProScan v5.

__Requirements:__
* `R` (tested v3.6.0); requires Rscript to be executable via `$PATH`

__Usage:__
```
MGBC_Tk feature_search -d <DATASET> -i <FEATURE> -p <PREFIX> -o <OUTDIR>
``` 
Arguments:  
`-d` Dataset to search, one of EGGNOG or INTERPROSCAN [REQUIRED]  
`-i` Feature id(s) from one of the searchable schemes: [REQUIRED]  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; EGGNOG:  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; KEGG	 e.g. K00929, 2.7.2.7, ko00650, M00027, R01688  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; CAZy	 e.g. GH48  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; GO	 e.g. GO:0047761  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; INTERPROSCAN:  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; InterPro e.g. IPR011245  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; BioCyc	 e.g. PWY-4321  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Reactome e.g. R-HSA-964975  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; KEGG (ENZYME or PATHWAY)  e.g. 2.7.2.7, ko00650  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; GO	 e.g. GO:0047761  
`-p` Prefix for output files [default: "\<FEATURE>.\<DATASET>"]  
`-o` Directory to write to [default: "."]   

__Note:__
Multiple feature ids from the same scheme can be provided with `<-i>` as a comma-separated list (e.g. IPR011245,IPR014079). This will only return data for genomes that encode all features supplied.  


__Output:__  
Two output files are generated.
1) `<OUTDIR>/<PREFIX>.species_summary.tsv`: tab-separated file containing the taxonomic locations of the supplied feature(s) at the pangenome-level.
```
Feature	Species_rep	Pangenome_frac	Positive_genomes	Total_genomes	Species	Host	Taxonomy
K00929	GUT_GENOME017427	0.983480176211454	2679	2724	s__Alistipes putredinis	HUMAN	d__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Bacteroidales;f__Rikenellaceae;g__Alistipes;s__Alistipes putredinis
K00929	GUT_GENOME001734	0.990350431691214	1950	1969	s__Bacteroides uniformis	HUMAN	d__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;g__Bacteroides;s__Bacteroides uniformis
K00929	GUT_GENOME143505	0.935005117707267	1827	1954	s__Phocaeicola dorei	HUMAN	d__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;g__Phocaeicola;s__Phocaeicola dorei
K00929	GUT_GENOME283914	0.959669079627715	928	967	s__Acetatifactor sp900066565	HUMAN	d__Bacteria;p__Firmicutes_A;c__Clostridia;o__Lachnospirales;f__Lachnospiraceae;g__Acetatifactor;s__Acetatifactor sp900066565
...
```
   * `Feature` is the functional annotation provided with `-i`.
   * `Species_rep` is the representative genome for the pangenome species cluster
   * `Pangenome_frac` is the proportion of genomes that belong to this species cluster that have been annotated with this function.
   * `Positive_genomes` is the absolute number of genomes of this species cluster that have been annotated with this function.
   * `Total_genomes` is the total number of genomes constituting this species cluster.
   * `Species` is the species level taxon and `Taxonomy` is the full taxonomy for the species cluster.
   * `Host` indicates which host this pangenome pertains to.

2) `<OUTDIR>/<PREFIX>.species_genome_index.tsv`: this tab-separated file contains the taxonomic locations of the supplied feature(s) at the genome-level.
   * `Feature` is the functional annotation provided with `-i`.
   * `Positive_genome_ids` is a colon-separated list of genomes for each taxon in output file 1 that are annotated with this feature.


### 3) `hm_blast` ###

Finds the taxonomic locations (genomes and species) of supplied sequence-level features, either genes or proteins.

__Requirements:__
* `R` (tested v3.6.0); requires Rscript to be executable via `$PATH`
* `blast` (tested v2.7.1)  


__Note:__ This module requires the FULL install option `<-f>` to be included when installing the Toolkit.

  
__Usage:__
```
MGBC_Tk hm_blast -i <PATH/TO/SEQ> -t <SEQTYPE> -s <SEQID> -o <OUTDIR> -p <PREFIX>
``` 
Arguments:  
`-i` Path to sequence input file [REQUIRED]  
`-t` Sequence type, either NUCL for nucleotide or PROT for protein [REQUIRED]  
`-s` Sequence identity to use as threshold for filtering results [default: 50]  
`-n` Number of threads [default: 1]  
`-o` Directory to write to [default: "."]  
`-p` Prefix for output files [default: "<feature>.<database>"]  

 __Output:__  
Three output files are generated.
1) `<OUTDIR>/<PREFIX>.species_summary.tsv`: tab-separated file containing the taxonomic locations of the supplied gene/protein sequence at the pangenome-level.
```
Species_rep	Gene_frac	Positive_genomes	Total_genomes	Mean_seq_id	Max_seq_id	Min_seq_id	Mean_bit_score	Ref_90_id	Species	Host	Taxonomy
GUT_GENOME001734	0.000507872016251904	1	1969	100	100	100	517	GUT_GENOME039282_00094	s__Bacteroides uniformis	HUMAN	d__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;g__Bacteroides;s__Bacteroides uniformis
MGBC108822	1	15	15	100	100	100	517	GUT_GENOME039282_00094	s__Phocaeicola dorei	MOUSE	d__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;g__Phocaeicola;s__Phocaeicola dorei
GUT_GENOME017427	0.000367107195301028	1	2724	99.593	99.593	99.593	514	GUT_GENOME039282_00094	s__Alistipes putredinis	HUMAN	d__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Bacteroidales;f__Rikenellaceae;g__Alistipes;s__Alistipes putredinis
GUT_GENOME143505	0.953940634595701	1864	1954	98.406	100	95.862	507.6	GUT_GENOME039282_00094	s__Phocaeicola doreiHUMAN	d__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;g__Phocaeicola;s__Phocaeicola dorei
GUT_GENOME001321	0.0294117647058824	1	34	97.967	97.967	97.967	506	GUT_GENOME039282_00094	s__Longicatena caecimuris	HUMAN	d__Bacteria;p__Firmicutes;c__Bacilli;o__Erysipelotrichales;f__Erysipelotrichaceae;g__Longicatena;s__Longicatena caecimuris
...
```
   * `Species_rep` is the representative genome for the pangenome species cluster.
   * `Gene_frac` is the proportion of genomes that belong to this pangenome that are predicted to encode this gene product.
   * `Positive_genomes` is the absolute number of genomes of this pangenome that are predicted to encode this gene product.
   * `Total_genomes` is the total number of genomes constituting this species cluster.
   * `Mean_seq_id`, `Max_seq_id`, `Min_seq_id` and `Mean_bit_score` are descriptive statistical values for this gene cluster.
   * `Ref_90_id` is the representative sequence of the gene cluster. 
        * __Note__: Genes are clustered at 90% sequence identity, so multiple gene clusters can exist for the same pangenome cluster.
   * `Species` is the species level taxon and `Taxonomy` is the full taxonomy for the species cluster.
   * `Host` indicates which host this pangenome pertains to.

2) `<OUTDIR>/<PREFIX>.gene_data.tsv`: this tab-separated file contains the genome- and gene-level data for each taxon-resolved gene cluster from output file 1.
   * `Species_rep` is the representative genome for the pangenome species cluster.
   * `Positive_genome_ids` is a colon-separated list of genomes for each taxon in output file 1 that are annotated with this gene cluster.
   * `All_genes` is a colon-separated list of the genes for each taxon in output file 1 that are annotated with this gene cluster.

3) `<OUTDIR>/<PREFIX>.blast.qc`: this file contains the raw blast output data for the input sequence.
   * Columns are: `Reference_id`, `Query_id`, `Sequence_identity`, `Bit-score`, `P-value`
 
 
