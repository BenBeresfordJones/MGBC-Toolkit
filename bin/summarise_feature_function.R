#!/usr/bin/env Rscript

# read commandline arguments
args = commandArgs(trailingOnly=TRUE)

if (length(args)!=2) {
	stop("Please supply the correct arguments.n", call.=FALSE)
} 

TMPDIR=args[1]
FEATURE=args[2]

## load data
d <- read.delim(file = paste(TMPDIR, "tax_rep.tmp", sep="/"), header=F, 
	col.names=c("Genome", "Species", "Rank", "Taxonomy", "Species_rep", "Host", "Total_species_genome_count"))

g <- read.delim(file = paste(TMPDIR, "genomes.tmp", sep="/"), header=F, col.names="Genome")

## run analysis
d <- d[d$Genome %in% g$Genome,]
d$Feature <- FEATURE

l1 <- lapply(split(d, f=d$Species_rep), function(x) {
	GCOUNT=length(unique(x$Genome))
	TCOUNT=unique(x$Total_species_genome_count)
	S_FRAC=GCOUNT/TCOUNT
	SPECIES=unique(x$Species)

	if (length(SPECIES) >= 2) { # clean up any discontinuities between non-species taxonomic assignments due to GTDB-Tk - get lowest ranked assignment
		if (any(grep(pattern = "g__", SPECIES))) {
			S_TMP=SPECIES[grep(pattern = "g__", SPECIES)]
			SPECIES=S_TMP[1]
	} else if (any(grep(pattern = "f__", SPECIES))) {
                        S_TMP=SPECIES[grep(pattern = "f__", SPECIES)]
                        SPECIES=S_TMP[1]
	} else if (any(grep(pattern = "o__", but$Species))) {
                        S_TMP=SPECIES[grep(pattern = "o__", SPECIES)]
                        SPECIES=S_TMP[1]
	} else if (any(grep(pattern = "c__", but$Species))) {
                        S_TMP=SPECIES[grep(pattern = "c__", SPECIES)]
                        SPECIES=S_TMP[1]
        }
	}

	data.frame(Feature=unique(x$Feature),
			Species_rep=unique(x$Species_rep), 
			Pangenome_frac=S_FRAC,
			Positive_genomes=GCOUNT,
			Total_genomes=TCOUNT,
			Species=SPECIES,
			Host=unique(x$Host),
			Taxonomy=unique(x$Taxonomy[x$Species == SPECIES]),
			Positive_genome_ids=paste(x$Genome, collapse = ":"))
	})


out_df <- do.call("rbind", l1)

out_df <- out_df[order(out_df$Positive_genomes, decreasing = TRUE),]

write.table(x=out_df, file=paste(TMPDIR, "species.tmp.tsv", sep="/"), sep="\t", quote=F, row.names=F)
