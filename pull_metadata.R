# Required Packages
# for more info, see https://bioconnector.github.io/workshops/r-ncbi.html#entrez_fetch()
library(rentrez)
library(XML)
library(lubridate)
library(dplyr)
library(XML)

# May be helpful to have NCBI API key as described 
# here: https://cran.r-project.org/web/packages/rentrez/vignettes/rentrez_tutorial.html#getting-started-with-the-rentrez
set_entrez_key("")
Sys.getenv("ENTREZ_KEY")

# We're looking at the assembly database; here are the options for it
# entrez_db_searchable("assembly")

# This does a search query for IDs corresponding to a 
# particular type of organism
res = entrez_search(db = "assembly", term = "eucaryotes", 
                    retmax = 99999, use_history = FALSE)

# The summary function takes a bunch of ids in a database, returning all the 
# needed metadata to munge!
step = 300
sum = entrez_summary(db = "assembly", id = res$ids[1:(step-1)], always_return_list = FALSE)
for (i in seq(step,length(res$ids), step)) {
  print("i:")
  print(i)
  new = entrez_summary(db = "assembly", id = res$ids[i:(i+step-1)], always_return_list = FALSE)
  sum = append(sum, new)
  Sys.sleep(0.1)
}

#############################################################################
# Taking the list of list structure down to a data.frame
#############################################################################
metadata_df = as.data.frame(do.call("rbind", sum))

# Remove column names
rownames(metadata_df) = NULL

# Remove uneeded/empty/unusable columns
metadata_subset = metadata_df %>% select(-rsuid, -latestaccession, -synonym, 
                                         -ucscname, -ensemblname, -assemblyclass,
                                         -gb_bioprojects, -gb_projects, -rs_bioprojects,
                                         -rs_projects, -biosource, -anomalouslist,
                                         -exclfromrefseq, -propertylist, -fromtype,
                                         -ftppath_assembly_rpt, -ftppath_stats_rpt,
                                         -ftppath_regions_rpt, -ftppath_genbank,
                                         -ftppath_refseq, -busco, -meta)

# API pull made everything into a list; here's a quick fix
for (name in colnames(metadata_subset)) {
  metadata_subset[[name]] = unlist(metadata_subset[[name]]) 
}

metadata_subset$asmupdatedate = ymd(metadata_subset$asmupdatedate)
metadata_subset$lastupdatedate = ymd(metadata_subset$lastupdatedate)
metadata_subset$seqreleasedate = ymd(metadata_subset$seqreleasedate)
metadata_subset$submissiondate = ymd(metadata_subset$submissiondate)
metadata_subset$scaffoldn50 = as.numeric(metadata_subset$scaffoldn50)

metadata_subset$scaffoldn50 = as.numeric(metadata_subset$scaffoldn50)
metadata_subset$contign50 = as.numeric(metadata_subset$contign50)
metadata_subset$coverage = as.numeric(metadata_subset$coverage)

# metadata$asmupdatedate = ymd(metadata$asmupdatedate)
# metadata$lastupdatedate = ymd(metadata$lastupdatedate)
# metadata$seqreleasedate = ymd(metadata$seqreleasedate)
# metadata$submissiondate = ymd(metadata$submissiondate)
# metadata$scaffoldn50 = as.numeric(metadata$scaffoldn50)
# 
# metadata$scaffoldn50 = as.numeric(metadata$scaffoldn50)
# metadata$contign50 = as.numeric(metadata$contign50)
# metadata$coverage = as.numeric(metadata$coverage)



#############################################################################
# Let's pull some taxonomy information and join it with our existing df
#############################################################################
step = 300
taxa = entrez_fetch(db = "taxonomy", id = metadata_subset$taxid[1:(step-1)], 
                    rettype = "xml", parsed = TRUE)
taxa = xmlToList(taxa)
for (i in seq(step,length(metadata_subset$taxid), step)) {
  print(i)
  new = entrez_fetch(db = "taxonomy", id = metadata_subset$taxid[i:(i+step-1)], 
                     rettype = "xml", parsed = TRUE)
  new = xmlToList(new)
  taxa = append(taxa, new)
  Sys.sleep(0.1)
}


## Before turning this into a dataframe, there are some size mismatches that
## need to be addressed. Mainly, delete the "othername" and "properties" 
for (i in 1:length(taxa)) {
  taxa[[i]] = taxa[[i]][!(names(taxa[[i]]) %in% c("Properties", "OtherNames"))]
}


# Okay, ready to convert! There are some TaxID repeats so we'll get rid of those
taxa_df = as.data.frame(do.call("rbind", taxa))
taxa_df = taxa_df %>% 
  select(TaxId, Division, Lineage) %>%
  distinct(TaxId, .keep_all = TRUE) 


# Do the same unlisting routine as before..
for (name in colnames(taxa_df)) {
  taxa_df[[name]] = unlist(taxa_df[[name]]) 
}

# Now, combine the two dataframes by TaxID! 
# This will give some additional identifiers to help with subsetting.
metadata = left_join(metadata_subset, taxa_df, by = c("taxid" = "TaxId"))

# test = strsplit(metadata$Lineage, "; ")
# column = c()
# for (i in 1:length(test)) {
#   organism = test[[i]]
#   column = c(column, organism[3])
# }
# metadata$Clade = column

# Export for visualizations
save(metadata, file = "metadata.RData")

