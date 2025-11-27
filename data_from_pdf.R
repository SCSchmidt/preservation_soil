## Script to retrieve soil based preservation values from Kibblewhite et al 2015 (https://www.sciencedirect.com/science/article/pii/S0048969715004854#t0020)

### using Danielle Navarro's tutorial https://blog.djnavarro.net/posts/2023-06-16_tabulizer/

library(tabulapdf)
library(dplyr)
library(tidyr)
library(tibble)
library(purrr)
library(janitor)
library(stringr)


pdf_file <- "./pdf_data/Kibblewhite_etal_2015.pdf" # load PDF

#get_page_dims(pdf_file) # dimensions to get an idea of page size

## Appendix A

# region as a vector containing the top, left, bottom and right coordinates
region <- c(100, 0, 793, 595)

s12 <- extract_tables(pdf_file, 
               pages = 12,
               guess = FALSE,
               area = list(region) 
               )[[1]]


region <- c(80, 0, 470, 595)

s13a <- extract_tables(pdf_file, 
                      pages = 13,
                      guess = FALSE,
                      area = list(region) )[[1]]

app_A <- rbind(s12,s13a)

# the reference group hadn't been filled in all the rows -> needs to be filled via names in WRB 1998

app_A$Ref_group <- str_split_fixed(app_A$`Name in WRB 1998`, pattern = " ", n = 2)[,2]

app_A$Ref_group[app_A$Ref_group == ""] <- app_A$`Reference group`[app_A$Ref_group == ""]
app_A$Ref_group[app_A$`Name in WRB 1998` == "Chernozem"] <- "Chernozem"

app_A_neu <- app_A |> select(-`Reference group`) # new column Ref_group has all the infos, delete the old one

## Same for Appendix B

region <- c(530, 0, 730, 595)

s13b <- extract_tables(pdf_file, 
                       pages = 13,
                       guess = FALSE,
                       area = list(region) )[[1]]


region <- c(80, 0, 793, 595)

s14 <- extract_tables(pdf_file, 
                       pages = 14,
                       guess = FALSE,
                       area = list(region) )[[1]]



region <- c(80, 0, 270, 595)s

s15 <- extract_tables(pdf_file, 
                      pages = 15,
                      guess = FALSE,
                      area = list(region) )[[1]]

app_B <- rbind(s13b, s14, s15)

app_B$Ref_group <-  str_split_fixed(app_B$`Name in WRB 1998`, pattern = " ", n = 2)[,2]
app_B$Ref_group[app_B$Ref_group == ""] <- app_B$`Reference group`[app_B$Ref_group == ""]
app_B$Ref_group[app_B$`Name in WRB 1998` == "Chernozem"] <- "Chernozem"


app_B_neu <- app_B |> select(-`Reference group`)

## both appendices talk about soil groups, therefore can be added into one table 

appendix <- left_join(app_B_neu, app_A_neu)

# the name for col ...4 had been one level up -> Rename by write column to a new col and delete old one
appendix$TypicalClimate <- appendix$...4 
appendix <- appendix |> select(-"...4")


## save

save(appendix, file = "./data/appendix_kibblewhite_etal_2015_A+B.RData")
