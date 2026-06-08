# Early-public-childcare-and-fertility
Codes for replication of "Early public childcare and fertility: A longitudinal study for Europe"

# Replication package for “Early public childcare and fertility: A longitudinal study for Europe”

This repository contains the Stata replication materials for the article **“Early public childcare and fertility: A longitudinal study for Europe”** by Giovanni Minchio, University of Trento.

## Overview

The replication package reproduces the data preparation, construction of parity transitions, addition of individual- and contextual-level controls, and estimation of the main results presented in the article.

The code was developed using Stata/SE 18.0 for Mac (Intel 64-bit), revision 14 Feb 2024.

## Author

**Giovanni Minchio**  
University of Trento

Version: 1.0  
Date: June 1, 2025

## Repository structure

The repository includes all project folders.

```text
Early public childcare and fertility/
|
|--- do/                    Replication do-files uploaded with the repository
|
|--- data/                  Original EU-SILC master files
|
|--- cleaned/               Cleaned datasets used for merge and analysis
|
|--- results/
     |
     |--- tables/           Output tables
     |
     |--- graphs/
     |    |
     |    |--- exports/     Exported graph files
     |
     |--- estimates/        Stored model estimates
```

## Data availability

Data cannot be shared publicly because the analyses are based on EU-SILC microdata made available through Eurostat’s microdata access system, which requires an approved research application and access by an eligible research entity. [web:25][web:28]

Researchers who meet the access conditions can apply through the Eurostat Microdata Access procedure: [https://ec.europa.eu/eurostat/web/microdata](https://ec.europa.eu/eurostat/web/microdata). [web:25]

The analyses also use regional indicators of publicly subsidized early childhood education and care compiled from regional and national statistical offices and provided courtesy of Emmanuele Pavolini (`emmanuele.pavolini@unimi.it`). Details on the compiled dataset are discussed in Scherer and Pavolini’s 2023 article in the *Journal of European Social Policy* (33(4): 436–450, DOI: [10.1177/09589287231183169](https://doi.org/10.1177/09589287231183169)). [web:29][web:31]

For these reasons, the repository contains replication code and documentation, but not the underlying restricted microdata.

## Software requirements

Replication was developed using:

- Stata/SE 18.0
- macOS 11.7.10
- Intel-based MacBook Pro environment

User-written commands may be required depending on the contents of the individual do-files.

## How to run the replication

1. Download or clone this repository.
2. Place the project folder in your preferred working directory.
3. Store the original EU-SILC master files in the `data/` folder.
4. Open the master do-file in Stata.
5. Replace the line

```stata
cd "your directory/Early public childcare and fertility"
```

with the correct path on your local machine.
6. Run the master do-file.

## Workflow

The master do-file executes the following steps:

1. `do/1_mergeHDR.do`  
   Merges the EU-SILC master files.

2. `do/2_parity_transitions.do`  
   Generates parity transitions in EU-SILC.

3. `do/3_controls.do`  
   Adds individual-level controls and NUTS-level ECEC usage measures.

4. `do/4_results.do`  
   Produces the main analytical results.

5. `do/Z_erase.do`  
   Erases temporary or intermediate data files.

## Reproducibility note

This repository is intended to support computational reproducibility of the published analyses. Because the underlying microdata are not publicly distributed in the repository, full replication requires authorized access to the relevant EU-SILC files and the additional contextual data described above. [web:25][web:28][web:29]

## License

Unless otherwise noted, the Stata code in this repository is distributed under the BSD 3-Clause License or the MIT License, depending on the version selected by the author.

Documentation may be distributed separately under CC BY 4.0 where explicitly indicated.

Third-party data are not covered by the repository license and remain subject to the original providers’ terms.
