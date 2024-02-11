# Material for Chapter 20 - Book: Biomarkers for Alzheimer’s Disease Drug Development

## Purpose
This page provides the material necessary to complete the protocol described <br>
in <strong>'In Silico Models to Validate Novel Blood-Based Biomarkers'</strong> (<em>chapter 20 </em>) in the book <br>
><strong>Biomarkers for Alzheimer’s Disease Drug Development</strong><br>
Methods in Molecular Biology, vol. 2785, Robert Perneczky (ed.) <br>
https://doi.org/10.1007/978-1-0716-3774-6_20

## Getting started

### Prerequisites
The code was written in R, version >3.5

### Installation
This repository can be cloned using following command <br>
```
git clone https://github.com/ansmor/springer_chapter
```
## Data
Data used in the protocol can be downloaded from
- [The Human Protein Atlas](https://www.proteinatlas.org/about/download), for the data named <em>normal_tissue.tsv</em> in section 3.3
- [Human MSigDB](https://www.gsea-msigdb.org/gsea/msigdb/collections.jsp), for the data named <em>c5.go.v2023.1.Hs.symbols.gmt</em> in section 3.4
- the [data](data/cluster.txt) folder in this repository, for the data names <em>cluster.txt</em> in section 3.5.2 (representing an example of manually created biological clusters)

## Scripts
The scripts used in the protocol can be found in the [scripts](scripts) directory:<br>

- for <strong><em>section 2.3</em></strong> [R packages](scripts/section_2.3.R)<br>
- for <strong><em>section 3.3</em></strong> [Blood-Based Biomarker Expression in the Brain](scripts/section_3.3.R)<br>
- for <strong><em>section 3.4</em></strong> [Functional Enrichment Analysis](scripts/section_3.4.R)<br>
- for <strong><em>section 3.5</em></strong> [Network analysis](scripts/section_3.5.R)<br>
- for <strong><em>section 3.5.1</em></strong> [Network analysis - Style](scripts/section_3.5.1.R)<br>
- for <strong><em>section 3.5.3</em></strong> [Network analysis - Clustering into Biological Functions](scripts/section_3.5.3.R)<br>
