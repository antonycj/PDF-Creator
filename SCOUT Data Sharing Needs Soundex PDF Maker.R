#####################################################################################################################
#####################################################################################################################
##### Creating Not Linked PDFs                            ###########################################################
##### created by David Jackson                            ###########################################################
##### Created on 7/1/2026                                 ###########################################################
##### Revised on                                          ###########################################################
#####################################################################################################################
##### Purpose: The purpose of this R script is to be a supplement to the SCOUT data share SAS code.           #######
##### the SAS SCOUT data share code should create an Excel spreadsheet with names and information of          #######
##### patients that are in SCOUT, but not eHARS, and we need to search their record.                          #######
##### This excel sheet was supposed to be used to create PDF files with the each patient respectively and put #######
##### in a file for record search to be done. This R script automates the process.                            #######
#####################################################################################################################
#####################################################################################################################

##### Necessary Packages to Install and import
# install.packages("readxl", "tidyverse") # if you do not have these packages downloaded, uncomment and run this line
library(readxl)
library(tidyr)
library(dplyr)
#####################################################################################################################


#####################################################################################################################
##### Step 1: Import the Excel Spreadsheet #####
# note that you can go to File > Import Dataset > From Excel and then browse to the dataset
# if you do this way, ensure that the box for "first row as "First Row as Names" is checked
# and the data is imported into the set called "dataset"

dataset <- read_excel("N:/HARS/HIV SCOUT/SCOUT Reports/2026 Monthy Scout Reports/MayNotLinked.xlsx") # Replace this with the path to the current dataset
View(dataset)
dataset <- as.data.frame(dataset)
#####################################################################################################################


#####################################################################################################################
##### Step 2: Adjusting Variables #####

## Combine Address and city into into one variable ##
dataset <- unite(dataset, col = "new_address", Add., City, Zip, sep = ", ", remove = FALSE)


## Recode Race from Race codes ##
## note that there are two different options here. Use option 1 if there are values in both Race1 and Race2. ##
## use option 2 if there are only values in Race1 ##
# Option 1: run this first part if there are any values for Race2 #
dataset <- dataset %>%                              
  mutate(New_Race1 = recode_values(Race1,
      "R1" ~ "American Indian/Alaska Native",
      "R2" ~ "Asian",
      "R3" ~ "Black/African American",
      "R4" ~ "Native Hawaiian/ Pacific Islander",
      "R5" ~ "White",
      "UNK" ~ "Unknown"
  ))
dataset <- dataset %>%
  mutate(New_Race2 = recode_values(Race2,
      "R1" ~ "American Indian/Alaska Native",
      "R2" ~ "Asian",
      "R3" ~ "Black/African American",
      "R4" ~ "Native Hawaiian/ Pacific Islander",
      "R5" ~ "White",
      "UNK" ~ "Unknown"
  ))
# Combine the two new Race variables into a single race variabel seperated by a comma for the report
dataset <- unite(dataset, col = "Race", New_Race1, New_Race2, sep = ",", remove = FALSE) 



# Option 2: Run this if there are no values for Race 2
dataset <- dataset %>%                              
  mutate(Race = recode_values(Race1,
        "R1" ~ "American Indian/Alaska Native",
        "R2" ~ "Asian",
        "R3" ~ "Black/African American",
        "R4" ~ "Native Hawaiian/ Pacific Islander",
        "R5" ~ "White",
        "UNK" ~ "Unknown"
  ))
# note that the variable name race is included in the renaming of the values, so there is no need for the
# naming that took place in the "unite()" command in option 1



## Recode Ethnicity from code to name ##
dataset <- dataset %>%
  mutate(new_ethnicity = recode_values(Ethnicity,
         "E1" ~ "Hispanic",
         "E2" ~ "Not Hispanic"
  ))

## Combine Name for PDF File ##
# note that this is only used for naming the PDF, not in the PDF itself
dataset <- dataset %>% 
  tidyr::unite(col = "name_for_pdf", `F Name`, MI, `L Name`, sep = " ", na.rm = TRUE, remove = FALSE) %>%
  mutate(name_for_pdf = toupper(name_for_pdf))


## change dob, cd4 dt, and vl dt to chr instead of date ##
class(dataset$DOB)
dataset$DOB <- as.character((dataset$DOB))
class(dataset$DOB) # double check that its character 

class(dataset$`CD4 Dt`)
dataset$`CD4 Dt` <- as.character(dataset$`CD4 Dt`)
class(dataset$`CD4 Dt`) # double check that its character 

class(dataset$`VL Dt`)
dataset$`VL Dt` <- as.character(dataset$`VL Dt`)
class(dataset$`VL Dt`) # double check that its character 
#####################################################################################################################


#####################################################################################################################
##### Step 3: Prework for the function #####
# Here are the variables we will include in the PDF
vars <- c(
  "STATENO",
  "F Name",
  "L Name",
  "MI",
  "DCN",
  "SSN",
  "DOB",
  "sex",
  "Phone Number",
  "new_address",
  "Race",
  "new_ethnicity",
  "scout_risk",
  "CD4 Dt",
  "CD4 #",
  "VL Dt",
  "VL #",
  "Undect"
)


# creating variable labels for the PDF
labels <- c(
  "STATENO" = "StATENO",
  "F Name" = "First Name",
  "L Name" = "Last Name",
  "MI" = "MI",
  "DCN" = "DCN",
  "SSN" = "SSN",
  "DOB" = "DOB",
  "sex" = "Sex",
  "Phone Number" = "Phone Number",
  "new_address" = "Address",
  "Race" = "Race",
  "new_ethnicity" = "Ethnicity",
  "scout_risk" = "Scout Riskt",
  "CD4 Dt" = "CD4 dt",
  "CD4 #" = "CD4 #",
  "VL Dt" = "VL DT",
  "VL #" = "VL DT",
  "Undect" = "Undetected"
)


# here is the output location of the PDF. Change as necessary
output_dir <- "//SDHLFILP4086/Database/HARS/Post SWMC labs/Needs Soundex"
if (!dir.exists(output_dir))dir.create(output_dir)

# here is creating the name_for_pdf as the item that will title each pdf
name_for_pdf <- dataset$name_for_pdf
#####################################################################################################################


#####################################################################################################################
##### Step 4: create Function to convert rows to PDF #####
write_pdf <- function(row, vars, labels, file_path, wrap_width = 90) {
  vars_present <- Filter(function(v) !is.na(row[[v]]) && row[[v]] != "", vars)
  
  raw_lines <- sapply(vars_present, function(v){
    display_name <- if (v %in% names(labels)) labels[[v]] else v
    paste0(display_name, ": ", row[[v]])
  })
  
wrapped <- unlist(lapply(raw_lines, function(l) strwrap(l, width = wrap_width)))
if (length(wrapped) == 0) wrapped <- ""

pdf(file_path, width = 8.5, height = 11)
par(mar = c(1, 1, 1, 1))
plot.new()
plot.window(xlim = c(0, 1), ylim = c(0, 1))

text(
  x = 0.05,
  y = 0.98,
  labels = "SCOUT not eHARS",
  adj = c(0, 1),
  cex = 1.3,
  font = 2,
  family = "sans"
)

n <- length(wrapped)
y_step <- min(0.045, 0.9 / n)

for (i in seq_along(wrapped)) {
  text(
    x = 0.05,
    y = 0.95 - (i-1) * y_step,
    labels = wrapped[i],
    adj = c(0, 1),
    cex = 1.1,
    family = "sans"
  )
}
dev.off()
}
#####################################################################################################################


#####################################################################################################################
##### Step 5: Loop through rows to apply function #####
# this should create PDFs for each of the patients in the excel file
for (i in seq_len(nrow(dataset))){
  row <- dataset[i, ]
  file_name <- paste0(row[["name_for_pdf"]], ".pdf")
  file_path <- file.path(output_dir, file_name)
  write_pdf(row, vars, labels, file_path)
}
#####################################################################################################################
