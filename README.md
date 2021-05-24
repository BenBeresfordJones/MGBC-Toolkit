MGBC-Toolkit
============

This repository contains the wrapper scripts for accessing the taxonomic locations of functions between the human and mouse gut microbiotas using the [Mouse Gastrointestinal Bacteria Catalogue (MGBC)](https://github.com/BenBeresfordJones/MGBC).

## Contents ##
* [Installing the Toolkit](#Installing-the-Toolkit)
* [Running the Toolkit](#Running-the-Toolkit)
* [Module descriptions](#Module-descriptions)
  * [closest_taxa](#1-closest_tax)
  * [feature_search](#2-feature_search)
  * [hm_blast](#3-hm_blast)


## Installing the Toolkit ##

To install the Toolkit, first clone this GitHub repository.

```
git clone https://github.com/BenBeresfordJones/MGBC-Toolkit
``` 

In the cloned repository, run the install script to install the required datasets and compile the Toolkit. Multiple options are provided for installing the Toolkit, and balance different levels of functionality with memory requirements. The default settings install the intermediate-size Toolkit (~20 Gb) that supports both the 'closest_taxa' and the 'feature_search' modules.

```
sh install_MGBC.sh
``` 
Options:  
`-l` installs a reduced Toolkit (<100 Mb). Only supports the closest_taxa module.  
`-f` installs the FULL Toolkit (~60 Gb). Supports the 'hm_blast' module.  
`-F` forces install. Overwrites prior installations.  



Finally, add the `MGBC_Tk` repository to your `$PATH` variable. 


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
MGBC_Tk closest_taxa -i <species/genome_id> -o <output_file>
``` 
Arguments:  
`-i` Species taxon or genome id to query between hosts. [REQUIRED]  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;E.g. "Bacteroides finegoldii", GUT_GENOME000122, or MGBC000577  
`-o` Specify output file to write to. [REQUIRED]    


### 2) `feature_search` ###
Finds the taxonomic locations (genomes and species) of supplied functional features. Can analyse multiple functional annotation schemes from eggNOG emapper-v2 and InterProScan v5.

__Requirements:__
* `R` (tested v3.6.0); requires Rscript to be executable via `$PATH`

__Usage:__
```
MGBC_Tk feature_search -d <dataset> -i <species/genome_id> -p <prefix> -o <output_file>
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
`-p` Prefix for output files [default: "\<feature>.\<database>"]  
`-o` Directory to write to [default: "."]  

__Note:__
Multiple feature ids from the same scheme can be provided with `<-i>` as a comma-separated list (e.g. IPR011245,IPR014079). This will only return data for genomes that encode all features supplied.  

### 3) `hm_blast` ###

Finds the taxonomic locations (genomes and species) of supplied sequence-level features, either genes or proteins. Can analyse multiple functional annotation schemes from eggNOG emapper-v2 and InterProScan v5.

__Requirements:__
* `R` (tested v3.6.0); requires Rscript to be executable via `$PATH`
* `blast` (tested v2.7.1)
__Note:__ This module requires the FULL install option `<-f>` to be included when installing the Toolkit.

  
__Usage:__
```
MGBC_Tk hm_blast -i <path/to/sequence> -t <seqtype> -s <seqid> -o <output_file> -p <prefix>
``` 
Arguments:  
`-i` Path to sequence input file [REQUIRED]  
`-t` Sequence type, either NUCL for nucleotide or PROT for protein [REQUIRED]
`-s` Sequence identity to use as threshold for filtering results [default: 50]
`-o` Directory to write to [default: "."]  
`-p` Prefix for output files [default: "<feature>.<database>"]  
