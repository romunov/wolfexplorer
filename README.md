---
title: wolfexplorer
output: 
  html_document: 
    keep_md: yes
---
[![status](http://joss.theoj.org/papers/1250a1c97f53a38efece1c973b499104/status.svg)](http://joss.theoj.org/papers/1250a1c97f53a38efece1c973b499104)

Explorer designed to visualize complex multi-year multi-specimen data. Attached data is a subset of data from wolf monitoring of wolves in Slovenia in season 2016/2017 ([summary in English](http://www.natura2000.si/uploads/tx_library/MonitoringVolk__summary.pdf)).

### Limitations
This viewer will require you shape your data to a somewhat specific, yet general enough, format. It can display only certain coordinate systems. Luckily WGS 84 (EPSG: 4326) is one of them. Data in the application is not persistent, but this limitation is something we're thinking of relaxing in the future.

WARNING: Date slider and some other features may not be working perfectly in some browsers (looking at you, Chrome). If you experience problems, please do drop us a line and switch browsers. Testing has been done on Firefox.

### Community guidelines
1) **Contributing to the software**  
Anyone interested is welcome to contribute to the software. There are a few ways to do it.  
Firstly, if there is a feature that you would like us to add, you can open a new [issue](https://github.com/romunov/wolfexplorer/issues) with an **enhancement** tag.  
Secondly, you can fork the repository, do your magic and offer your upgraded code through a pull request. When writing code please follow [R Style Guide](https://github.com/romunov/r_style_guide). 
2) **Reporting issues or problems with the software**  
Github makes it easy to report issues with the software. Simply navigate to the [issues tab](https://github.com/romunov/wolfexplorer/issues) and check if there is an issue similar to one you are experiencing already reported. If so, you are more than welcome to add your experience in a form of a comment to that issue thread. Otherwise, do not hesitate to report a new issue, that has not been previously reported.  
3) **Seeking support**  
Feel free to contact us through [email](mailto:wolfexplorer.help@gmail.com). We are also both on twitter as [romunov](https://twitter.com/romunov) and [zkuralt](https://twitter.com/zkuralt). 

# How to run this application
## The easy way

Assuming you have all the packages installed*, starting with `shiny`, you can run this piece of code and you're off.
```r
shiny::runGitHub(repo = "wolfexplorer", username = "romunov")
```

`*` you can install packages listed in the [`app.R`](https://github.com/romunov/wolfexplorer/blob/master/app.R#L1) using something along the lines of

```
install.packages(c("shinydashboard", "leaflet", "RColorBrewer", "DT", "sp", "rgdal", "data.table", "ggplot2", "colourpicker", "tidyr", "plyr", "rgeos", "kinship2"))
```

## The manual way

First you need to clone the repository using git

```
git clone https://github.com/romunov/wolfexplorer
```

If you are using RStudio, open the project file, open `app.R` and press `Run App` button in the upper right corner of the script window.
![](./img/runapp.png)

If you are not using RStudio, just set working directory the project folder and run `runApp()`.

If all goes well, you should see the application, displayed either in RStudio viewer pane or in your default browser (preferably).

![](./img/welcome.png)

# How to format data

To start, you should load the data using `Data > Samples data` menu for raw data and parentage information to `Data > Parentage data`.

### Samples data
Samples data should come in the following raw text format:

```r
 $ x               : num  430263 430260 475503 428961 419071 ...
 $ y               : num  63602 63609 59611 75076 44413 ...
 $ date            : chr  "2012-05-30" "2012-05-30" "2011-08-27" "2011-06-23" ...
 $ sample_type     : chr  "Direct Saliva" "Direct Saliva" "Direct Saliva" "Direct Saliva" ...
 $ animal          : chr  "649" "650" "651" "652" ...
 $ sex             : chr  "M" "M" "M" "F" ...
 $ sample_name     : chr  "AH.02UE" "AH.02UH" "AH.0388" "AH.038A" ...
 $ reference_sample: chr  "AH.02UE" "AH.02UH" "AH.0388" "AH.038A" ...
```

Notice the name of columns. In this example the coordinates for `x` and `y` are "Gauss Krüger" (EPSG: 3912). You should supply WGS 84 (EPSG: 4326) coordinates for longitude and latitude, respectively, as they will be used without converting. See [GKtoWGS.R](https://github.com/romunov/wolfexplorer/blob/master/GKtoWGS.R) for implementation of conversion. This would also be the place to perhaps add your "parser" to accomodate your coordinate format.

`date` should come in the `%Y-%m-%d` form. `sample_type` right now is hard coded but this restriction will probably be relaxed in the near future. The rest should be pretty self explanatory. Animal is the designation for a group (or a singleton) of genotypes, `sex` and `sample_name` appear in the popup to aid in exploring of data.

### Parentage data (optional)
Data for parentage, derived from your favorite software, should be transformed to the following format:

```r
 $ offspring: chr  "M1UA7" "M1YFC" "M2122" "M226C" ...
 $ mother   : chr  "EE.156X" "AL.068T" "AU.0AEF" "M20PK" ...
 $ father   : chr  "AX.0E1C" "AY.0F1M" "AH.03MT" "*1" ...
 $ cluster  : chr  "1" "2" "2" "2" ...
```
Column offspring is `reference_sample` (from samples data) of a putative child, `mother` and `father` its parents and `cluster` should be "family" id. This step is optional but note that some functionality will not be available (see below).

# Navigating the application
As mentioned above, you should read in the (genetic) samples data through the `Data > Samples data` menu. Imported data should appear in a table as seen in the picture below. Feel free to browse your data using autofilter input fields.

![](./img/load_samples_data.png)

If you now head to `Explore data` menu, you should see the initial map with all samples plotted in grey. These markers are clickable. Go ahead, try it.
Upper right corner of the map should house a transparent box which now has a slider and an input field. Use the slider to filter out samples between specific dates. Note that this does not work for grey samples, but only on which animals you can select in the input field (and thus their displaying on the map).

![loaded samples and map](./img/samples_loaded_map.png)

If you also load parentage data (optional), you will be able to display selected animals' offspring as well.

![loaded parentage data](./img/loaded_parentage_data.png)

Head back to the `Explore data` menu. Notice that another input field has appeared. In the below example you can see offspring of animal `M2122`. These should be colored orange if added to the selection.

![](./img/selected_all.png)

It is also possible to plot pedigree tree. Once you've selected parentage data and selected a cluster ("family"), check `Plot pedigree` checkmark.

![](./img/parentage.png)
You can draw MCP (maximum convex polygon) for selected animals by checking the `Show MCP` checkmark. If there's only one sample, a circular polygon is drawn around that point. For two points, a buffer of 1 km is drawn around the straight line connecting the two points. *These two cases are not true MCPs but is a compromise between accuracy of MCP and visual display of limited number of points.* For three points or more, a MCP as one would expect is created.

![](./img/mcp.png)

Sliders in the sidebar should aid in visualizing overlapping points/lines.

See menu `Summary` for information on the dataset. If you filter samples by date, summary will be calculated on that subset.

![](./img/summary.png)

Legend colors can be manipulated through the `Settings` menu. Click on the input tab of the color and pick a color, any color.

![](./img/color_setting.png)

