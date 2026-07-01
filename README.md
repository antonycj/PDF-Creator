# Missing Patient Information PDF Creator
This R Script file is the automation of part of a monthly records transfer. It takes patient data and exports it PDFs. This used to be done manually. Note that the format of these PDFs had already been prescribed and this code is not attempting to change said format. *NO REAL PATIENT DATA IS INCLUDED IN THIS, any data is simulated.*

# Contents
- Purpose
- R Script
- Simulated data
- Example of PDF output
- Python data simulation code

# Purpose
The purpose of this code is to automate the extraction of patient information from an Excel spreadsheet created from an existing department SAS script and put the information for each patient into its own unique PDF file for someone to perform a record search with. The type of information included in the Excel file and the format of the PDFs are establised by the Office of Epidemeology in the Missouri Department of Health and Senior Services and the code I created here works within those established standards. 

This script was created in R Studio and utilized on authentic patient data received from SCOUT before being posted here. The data included in this repository is *NOT* said authentic data, but it is simulated data created using Python. The code for the simulation is included in this repository.

