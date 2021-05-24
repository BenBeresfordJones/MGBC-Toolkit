#!/usr/bin/env Rscript

args = commandArgs(trailingOnly=TRUE)

if (length(args)==0) {
	stop("Please supply the path and stem of the output files.n", call.=FALSE)
} 

TMPDIR=args[1]

df <- read.delim(file = paste(TMPDIR, "genome_summary.tsv", sep="/"), header=F, 
	col.names=c("Genome", "Species", "Rank", "Taxonomy", "Species_rep", "Host", "Total_species_genome_count", "Qseqid", "Ref_id_100", "Pident", "Bitscore", "e_value", "length", "qlen", "slen", "Ref_id_90"))

l1 <- lapply(split(df, f=df$Ref_id_90), function(x) { 

	x$Species_rep <- droplevels(x$Species_rep)

	l2 <- lapply(split(x, f=x$Species_rep), function(y) {
		GCOUNT=length(unique(y$Genome))
		TCOUNT=unique(y$Total_species_genome_count)
		MAXID=max(y$Pident)
		MINID=min(y$Pident)
		MEANID=round(mean(y$Pident), digits =3)
		S_FRAC=GCOUNT/TCOUNT
		MBS=round(mean(y$Bitscore), digits=1)

		data.frame(Species_rep=unique(y$Species_rep), 
				Gene_frac=S_FRAC, 
				Positive_genomes=GCOUNT, 
				Total_genomes=TCOUNT, 
				Mean_seq_id=MEANID, 
				Max_seq_id=MAXID, 
				Min_seq_id=MINID, 
				Mean_bit_score=MBS, 
				Positive_genome_ids=paste(y$Genome, collapse = ":"), 
				All_genes=paste(y$Ref_id_100, collapse = ":"), 
				Ref_90_id=unique(y$Ref_id_90), 
				Species=unique(y$Species), 
				Host=unique(y$Host),
				Taxonomy=unique(y$Taxonomy))
	})

	do.call("rbind", l2)
})

out_df <- do.call("rbind", l1)

out_df <- out_df[order(out_df$Mean_seq_id, decreasing = TRUE),]

write.table(x=out_df, file=paste(TMPDIR, "species.tmp.tsv", sep="/"), sep="\t", quote=F, row.names=F)
