# Required Packages
# for more info, see https://bioconnector.github.io/workshops/r-ncbi.html#entrez_fetch()
library(rentrez)
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
sum = entrez_summary(db = "assembly", id = res$ids[1:(step-1)], always_return_list = TRUE)
for (i in seq(step,length(res$ids), step)) {
  print("i:")
  print(i)
  new = entrez_summary(db = "assembly", id = res$ids[i:(i+step-1)], always_return_list = TRUE)
  sum = append(sum, new)
  Sys.sleep(0.1)
}

save(sum, file = "metadata.RData")

