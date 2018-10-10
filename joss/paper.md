---
title: 'wolfexplorer: a tool for visualization and exploration of complex multi-year multi-specimen datasets'
tags:
  - spatio-temporal genetic data
  - shinydasboard
  - R
authors:
  - name: Roman Luštrik
  orcid:  0000-0002-1410-8253
  affiliation: 1
  - name: Žan Kuralt
  orcid: 0000-0001-7201-4282
  affiliation: 2
affiliations:
  - name: Genialis, Inc.
  index: 1
  - name: Biotechnical faculty, University of Ljubljana, Jamnikarjeva 101, SI-1000 Ljubljana, Slovenia
  index: 2
date: October 2018
bibliography: paper.bib
---

# Summary

Non-invasive genetic sampling has become an accessible method for monitoring wild animal populations, whereas visualising such multi-specimen data in both spatial and temporal context has proven to be an arduous task. Conventional approach utilising GIS software suffers from a lack of interactivity, particularly when analysing many samples from numerous animals simultaneously. Yet such datasets, if disentangled properly, offer an invaluable insight into movement patterns, habitat utilization and life histories of studied animals. 

Here we present wolfexplorer - a tool for visualization and exploration of complex multi-year multi-specimen datasets. Package, incorporating user-friendly GUI, is written in R, and presents an example of a novel approach in data exploration. It is aimed at helping researchers interpret complex datasets, giving them ability to examine spatial information and genetic lineages step-by-step.

Central piece of the application is a map and an inputs panel that enables users to select samples from animals of interest. In case dataset contains a temporal component, filtering by date is also available. When spatial data is complemented with parentage data, functionality of the package is expanded with the ability to plot family pedigrees on-the-fly and suggestions of currently displayed animals’ offspring.

Brief instructions on how to install and use the application are available at https://github.com/romunov/wolfexplorer, where sample dataset from Monitoring of Conservation Status of Wolves in Slovenia in 2016/2017 [@Bartol:2017] is also supplied. Even though the name may indicate its inevitable connection to wolves, the application performs well with any dataset of this kind. 

Wolfexplorer requires `shinydashboard` [@shinydashboard], `shinyjs` [@shinyjs], `leaflet` [@leaflet], `RColorBrewer` [@rcolorbrewer], `DT` [@dt], `sp` [@pebesma2005; @bivand2013], `rgdal` [@rgdal], `data.table` [@data.table], `ggplot2` [@ggplot2], `colourpicker` [@colourpicker], `tidyr` [@tidyr], `plyr` [@plyr], `rgeos` [@rgeos], `kinship2` [@kinship2] and `htmltools` [@htmltools].

# Acknowledgements

We thank Charlie Thompson for his contribution to the app.

# Use

Wolfexplorer has already been used for exploration of data gathered in different projects dealing with wolves in Slovenia, Croatia and Slovakia.

# References
