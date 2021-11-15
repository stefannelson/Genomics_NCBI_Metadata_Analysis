# Required Packages
# for more info, see https://bioconnector.github.io/workshops/r-ncbi.html#entrez_fetch()
library(rentrez)
library(XML)
library(lubridate)
library(dplyr)

# May be helpful to have NCBI API key as described 
# here: https://cran.r-project.org/web/packages/rentrez/vignettes/rentrez_tutorial.html#getting-started-with-the-rentrez
set_entrez_key("11c1de631580da44a5ae812abb5357a3ff09")
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

metadata_subset$asmupdatedate = as.Date(metadata_subset$asmupdatedate)
metadata_subset$lastupdatedate = as.Date(metadata_subset$lastupdatedate)
metadata_subset$seqreleasedate = as.Date(metadata_subset$seqreleasedate)
metadata_subset$submissiondate = as.Date(metadata_subset$submissiondate)


# Export for visualizations
save(metadata_subset, file = "metadata.RData")

