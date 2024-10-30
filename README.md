 # dataRetrieval

## Summary
1. [What is ipchem.dataretrieval?](#what-is-ipchemdataretrieval)
2. [Overview](#overview)
3. [Installation](#installation)
4. [Available data on IPCHEM](#available-data-on-ipchem-site)
5. [How to download a data package](#how-to-download-a-data-package)
6. [Extracting information from JSON strings](#extracting-information-from-json-strings)
    * [Extract all the key value pairs](#extract-all-the-key-value-pairs)
    * [Extract a subset ot key value pairs](#extract-a-subset-of-key-value-pairs)
7. [Searching for data packages](#searching-for-data-packages)
    * [Summary file](#summary-file)
    * [Start of exploring the data packages](#start-of-exploring-the-data-packages)
    * [Example: select and filter the datasets](#example-select-and-filter-the-datasets)
    * [Example: select and filter any column from summary file](#example-select-and-filter-any-column-from-summary-file)
    * [Short version for `retrieve_info()`](#short-vesion-for-retrieve_info)
    * [Example: using `isin()` for filtering](#example-using-isin-for-filtering)
    * [Example: creating a pipeline](#example-creating-a-pipeline)
    * [Example: filtering without a pipeline](#example-filtering-without-a-pipeline)
8. [Create URLs and download data packages](#create-urls-and-download-data-packages)
    * [Download data from a single URL](#download-data-from-a-single-url-download_files)
    * [Download data from multiple URLs](#download-data-from-multiple-urls-download_files)
9. [Metadata](#metadata)

## What is ipchem.dataretrieval?

It is an R package that helps the users to browse through the data packages available on IPCHEM site and download them.

## Overview

You will learn how to select the necessary information from IPCHEM site and download it in your computer.

To have a concret example, let's consider the user wants to see the concentration of lead 
- in the atmosphere, 
- in Romania,
- during year 2011, 
- in different cities. 

```
library(ipchem.dataretrieval)

# download the data and create a data frame under the following conditions

df <- retrieve_media(filter = (media == "Atmosphere")) %>% 
    retrieve_chemical_name(filter = (chemical_name == "lead")) %>% 
    retrieve_period(filter = (period == 2011)) %>% 
    retrieve_location(filter = isin(location, "ROU")) %>% 
    create_package_url() %>%
    head(1) %>% 
    download_files() 

```
Now you have the data frame and you can start analysing the information.

## Installation
The package is hosted on Gitlab and to isntall int, the user will need package `remotes` first:

1. Install package `remotes`: `install.packages("remotes")`.
5. Run the command `remotes::install_gitlab(repo = "ipchem-toolbox/dataretrieval/ipchem-dataretrieval-r", host = "https://code.europa.eu")`
6. If pointed, it is up to the user to update the packages or not.



## Available data on IPCHEM site

The IPCHEM database contains millions of records with measurement for different chemicals found in all types of environments, all over the globe.

The data is collected by as series of organizations and IPCHEM brings together all data packages, stores them and bring everything to a standard form.

The is structured in a hierarchical, starting with highest grouping level:

- substance => in IPCHEM is the analyte measured in a sample. This includes mostly classical chemicals, but includes also analytes such as Particulate Matter (PM 2.5 or PM10) or process-generated materials such as dust. 
- module => thematic area of the measurements 
- media => medium which was sampled and analysed in the measurement   
- dataset => a collection of data, published or curated by a single agent, and available for access or download in one or more representation
- package => a file containing a subset of the data records of a dataset grouped by chemical, media and period. Cumulative packages help downloading whole datasets, divided by period in the case of regular data collections (e.g. EFSAMOPER)
- record => *single measurement* (individual measurement made at one point in time); *aggregated data* (a set of one statistical values (e.g. mean, percentile, etc.), obtained by aggregating several individual measurements)


A summary file with all the information found on the site, can be found here: https://ipchem.jrc.ec.europa.eu/public/IPCHEM_public_dataset_packages.csv

## How to download a data package

### Download directly from the site


A user can retrieve a package by goin directly to IPCHEM site: [ipchem.jrc.ec.europa.eu](https://ipchem.jrc.ec.europa.eu/).

On the main page, click the yellow button that says *Search data by Chemical, mMedia and Country*. 

![main_page](./documents/page_1.png)

To replicate the same example as the one in the *Overview* section, a user must:
- write the chemical *lead* in the top box
- select the green round button for *Environment Monitoring Data*
- click on *Metadata Info* under *AIRBASE*

![second_page](./documents/page_2.png)

On the next page the user must click on *Data Package* tab. The table provided here can be filtered and sorted until the necessary data package is found. For this example, the user will search for chemical *lead* for year 2011. 

The country is not provided in this table. The information card on the left shows the countries where the information is available.

Pressing the download button, a ZIP file will be downloaded. The ZIP file contains a CSV with data in regards to the selected filters.

![third_page](./documents/page_3.png)

![fourth_page](./documents/page_4.png)

Now that the file is available in the computer, the user will start to upload it in the environment and use it.

### Download using dataretrieval package

There is faster way to get the same data package directly in your R environment.

Before a user can download a data package from IPCHEM site, a URL must be available.

Using the same example as above, the user will copy and paste the URL of the ZIP file. 

`download_files` function is used to download data from one or multiple URLs. If the URL points to a ZIP archive that contains a CSV, the CSV file will be extracted and transformed into a data frame.

```
library(magrittr)

url <- "https://ipchem.jrc.ec.europa.eu/public/AIRBASE/2011/IPCHEM_AIRBASE_98304447-a89e-44bf-86be-4061ee55bd76.zip"

df <- url %>%
    download_files()

df
```

![table_1](./documents/table_1.png)




## Extracting information from JSON strings

### Extract all the key value pairs

Once the URL to the ZIP archive from IPCHEM is available, the full functionality of `download_files` will go through two steps: 
- download ZIP archive
- extract the CSV file and temporary store CSV
- transform into a data frame
- explode JSON strings and add as culumns in the data frame

To be mentioned that each CSV file resulting from the archive provided by IPCHEM, contains a column with JSON that stores all the information of a record. 

Although the functions exported by *dataretrieval* package are designed to work with data provided by IPCHEM, they can be used for other data sources as long as they follow some restrictions.

One of the restrictions of `download_files` it that the ZIP archive must contain just one CSV file. Otherwise will return an exception.

The result of the following script is a data frame that contains a column called *SOURCE DATA*.

Each row from *SOURCE DATA* is a string in JSON format. Some of the keys from this JSON are already transformed into columns in the data frame.

To expand all of them key value pairs from JSON into the initial data frame, a user will use `expand_json()` function. The mandatory argument is the name of the column with JSON strings. 

```
url <- "https://ipchem.jrc.ec.europa.eu/public/AIRBASE/2011/IPCHEM_AIRBASE_98304447-a89e-44bf-86be-4061ee55bd76.zip"


df <- url %>%
    download_files() %>%
    expand_json(json_col = "SOURCE DATA")
```

To see the difference, the first image is the data frame with *SOURCE DATA* column and the second image is the data frame with the columns expanded from JSON. 

For ease, only the first row was tranposed and displayed.

![table_2](./documents/table_2.png)

![table_3](./documents/table_3.png)


The functions are compatible with the pipe operator.

### Extract a subset of key value pairs

Some data packages contain a large number of rows. Extracting the JSON will add further information, thus expanding the number of columns and increasing the memory footprint.

A user could need only a few of the key value pairs from JSON. In this istuation, there is no need to transform all the key value pairs into columns inside the data frame.

Before expanding the JSON strings, the user can explore what are the key available and what information they contain.

To have a fast script and low memory footprint, the exploration of JSON strings can be done before they are expanded.

Function *json_to_df()* creates a data frame with 3 rows: key name, value and type. 

The script below downloads a data package and transforms it into a data frame. Then the first row from column *SOURCE DATA* is taken and `json_to_df()` is applied. 


```
url <- "https://ipchem.jrc.ec.europa.eu/public/AIRBASE/2011/IPCHEM_AIRBASE_98304447-a89e-44bf-86be-4061ee55bd76.zip"


df <- url %>%
    download_files()

# keep the first JSON from the data frame
json_sample <- df[["SOURCE DATA"]][1]

json_sample_df <- json_to_df(json_sample)

```
The table below shows only the first 8 key value pairs.

![table_4](./documents/table_4.png)

Assuming that the user needs only 3 columns, the script for generating the data can continue as follows.

```
keep_nodes <- c("Altitude (m)", "Statistic Name", "Sampling Matrix")

df <- df %>%
    expand_json(json_col = "SOURCE DATA", keep_nodes = keep_nodes)
```

Or if the users knows prior to download what keys to keep.

```
url <- "https://ipchem.jrc.ec.europa.eu/public/AIRBASE/2011/IPCHEM_AIRBASE_98304447-a89e-44bf-86be-4061ee55bd76.zip"

df <- url %>%
    download_files() %>%
    expand_json(json_col = "SOURCE DATA", keep_nodes = keep_nodes)
```

The path to obtain the data frame with the expanded JSON string can be even shorter, because `download_files()` is designed to also extract JSON in one go.

If argument `exp_jsn` is `TRUE` than argumet `json_col` becomes mandatory, so it will point to the column with JSON strings. `keep_nodes` can be ommited if the user wants all the data from JSON.

```
df <- url %>%
    download_files(exp_jsn = TRUE, json_col = "SOURCE DATA", keep_nodes = keep_nodes)
```

## Searching for data packages

### Summary file

As mentioned in chapter 3, IPCHEM site contains a CSV file that keeps count off all data packages available. For convenience this file will be called *summary file*. 

The address of this file is: [https://ipchem.jrc.ec.europa.eu/public/IPCHEM_public_dataset_packages.csv](https://ipchem.jrc.ec.europa.eu/public/IPCHEM_public_dataset_packages.csv)

The summary file is obtained by a user by calling `load_summary()` function. A data frame called *chem_summary* will be added to the environment. 

```
load_summary()

head(chem_summary)
```

![table_5](./documents/table_5.png)

Around *chem_summary* data frame a series of functions were created so a user can easely search for a certain data package or explore what information the site offers.

*chem_summary* should not be altered, otherwise the results won't be the correct ones. If a user changes this data frame and still want's to explore the structure of the data, it is advisable to call again `load_summary()` and get a fresh copy. 

Before it is delivered to the environment, the summary file suffers a few modification to make easy to work with.

A user can ask why not *chem_summary* is already included in the package? Why the user must download it again in each new session? The answer is simple. Because IPCHEM adds very often new data packages. If the summary file was included in the *dataretrieval* package, each time the summary file was update, so the package must have been updated and published. Thus creating unnecesary *dataretrieval* updates. The purpose is to offer the user the newest information as fast as possible and this was the solution.

### Start of exploring the data packages

`retrieve_info()` helps the user to navigate easy through the structure of the summary file and to generate the links that host each data package. It works by applying filters over the summary file and retrieving unique rows.

**THERE IS NO NEED TO HAVE THE SUMMARY FILE BEFORE THE CALL OF `retrieve_info()`**. The function will check if the summary file is present and if not, it will download it.

`retrieve_info()` is designed to work in a pipeline and the user can chain up many calls of this function until the results are obtained. 

The output is always a data frame with unique rows.

The definition of the function starts with:
```
retrieve_info <- function(..., target, filter){
    #body
}
```

`retrieve_info()` has a mandatory argument called `target` which is the columns from the summary file the user wants to explore.

`filter` argument is an expression that will be applied only to the target. The output of the expression must be a boolean value (TRUE or FALSE) and should contain the target, otherwise it will be disregarded.

`...` can contain named arguments or a data frame. Every argument that is placed before `target` is considered a filter for the whole summary file. This is how `show_info()` can be placed in a pipeline, because the output of the first call is a data frame that will be a filter in the next call.


### Example: select and filter the datasets

In the summary file the datasets are in the column called *dataset*.

To get a unique list of the datasets, `retrieve_info()` is called with the mandatory argument `target` which will have the value of columns from the summary file.

```
retrieve_info(target = "dataset")
```
![table_6](./documents/table_6.png)

The next calls of the function are equivalent to the one above. 

The user can chose to put the value of `target` in single, double quotes or unquoted. There is also wrapper function the argument `target` can be ommited and the same results are obtained. The name of the function is self explanatory.

```
# unquoted argument value
retrieve_info(target = dataset)

# wrapper function
retrieve_dataset()
```

Depending on the target there can be a lot of unique results.

The user has filtering option. Taking the same example as in previus chapter. let's assume the user wants to keep only the datasets that contain the string *AIR*. To achieve this a logical expression is constructed.


```
library(stringr)

retrieve_info(target = dataset, filter = isin(dataset, "AIR"))

# or equivalent
retrieve_dataset(filter = isin(dataset, "AIR"))
```

![table_7](./documents/table_7.png)

On it's own, this statement does not offer much information. It is just a confirmation of what is found in the summary table.

### Example: select and filter any column from summary file

Any column from the summary table can appear as the `target` argument in `retrieve_info()`. The following pieces of code provides the user a short overview of what can be selected and filtered.

Taking the example of *media*:

```
# without filter
retrieve_info(target = media)

# or
retrieve_media()
```
![table_8](./documents/table_8.png)

```
# with filter, only media that contains with 'Atm'
retrieve_info(target = media, filter = isin(media, 'Atm'))

# or
retrieve_media(filter = isin(media, 'Atm'))
```

![table_9](./documents/table_9.png)

### Short vesion for `retrieve_info()`

The next function calls are groupped into a single script. The user can chose the short or the long wrinting funtion that includes *target* argument.

For the the remaining of the presentation, mostly the short version will be used.

```
retrieve_info(target = chemical_name)
retrieve_chemical_name()

retrieve_info(target = cas_number)
retrieve_cas_number()

retrieve_info(target = period)
retrieve_period()

retrieve_info(target = media)
retrieve_media()

retrieve_info(target = dataset)
retrieve_dataset()

retrieve_info(target = location)
retrieve_location()

```

There is also a special function that takes two targets. Because in most cases *chemical_name* has attached to it a unique *cas_number*, it is bettter to present them together. It works in the same way as the previous functions.

```
retrieve_chem_cas()
```

Only 6 columns from the summary table have a dedicated wrapper function: *chemical_name, cas_number, media, dataset, period, location*. All the other columns, *package, filesize, records, id*, have a very large number of unique valus and most of filters applied to them will result in a handful of results. They can still be explored through `retrieve_info`, with the corresponding target.

### Example: using `isin()` for filtering


The user wants to see if there are records for lead concentration in the atmosphere in Romania. The script looks like this:

```
retrieve_chemical_name(filter = (chemical_name == "lead")) %>%
    retrieve_media(filter = (media == "Atmosphere")) %>%
    retrieve_location(filter = (stringr::str_detect(location, "ROU")))
```
![table_15](./documents/table_15.png)

The result is a data frame with 13 rows. Each record from *location* column contais the string *ROU* which is the ISO code for Romania. 

One data package contains multiple countries. There is no possibility to filter out a data package that contains one sigle country. There are only a few exceptions to this.

To obtain this result, the user must work with regular expressions that match one or more countries. 

Let's consider the user wants the same data for Romania or Spain. The filter will be:

```
stringr::str_detect(location, "ROU|ESP")
```

The bar between country codes is translated as *or*. 

A simpler version is to use `isin()`. The equivalent for the expression above is:

```
isin(location, c("ROU", "ESP"), type = "any")
```

The function performs a partial matching of the values *ROU* and *ESP* over each row from column *location*.

The argument `type = "any"` (default) points the function to search if any of *ROU* or *ESP* is part of the location.

The other possible value is `type = "all"`. The function will search if both *ROU* and *ESP* appear in the same time in the *location* column.  

The same logic applies to all columns that contain character strings. *Chemical_name*, for example, is sometimes hard to find and rather than trying to find the exact chemical, the user can try to search for a part of the name of the chemical.

Let's see all the chemicals that contain *lead*.

```
retrieve_chemical_name(filter = isin(chemical_name, "lead"))
```
![table_16](./documents/table_16.png)

This is very different from the case when the user knowns that the exact name is *lead*. 

```
retrieve_chemical_name(filter = (chemical_name == "lead"))
```

Any expression is valid as long as it refers to the *target* argument and it outputs `TRUE` of `FALSE`.  

### Example: creating a pipeline

Let's assume the user wants to see what are the datasets that provide data for atmosphere.

The first step is to select from media only *Atmosphere*.

```
retrieve_media(filter = (media == "Atmosphere"))
```
![table_9](./documents/table_9.png)

The user will select all the datasets that have to do with *Atmosphere*:

```
library(magrittr)

retrieve_media(filter = (media == "Atmosphere")) %>%
    retrieve_dataset()

```

![table_10](./documents/table_10.png)

The last column (target) invoked becomes the first column in the resulted data frame. These are all unique results. They appear many time in the summary file because they refer to different chemicals, period, location etc.

Because the functions work in a pipeline, the output of the first call `retrieve_media()`, which is only *Atmosphere*, becomes input for the next call, `retrieve_dataset()`. Thus only datasets for specified media are returned. 

But the point here is to show the user that at least one record satifies its criteria of selection.

The user want to see if these datasets provide information for chemical *lead* in the atmosphere.

```
retrieve_media(filter = (media == "Atmosphere")) %>%
    retrieve_dataset() %>%
    retrieve_chemical_name(filter = (chemical_name == "lead"))

```

![table_11](./documents/table_11.png)

Only *AIRBASE* and *AIRQUALITY* have information about *lead*.

Next the user decides that its analysis requires data no older that 2015. The script will be modified to include the new selection criteria.

```
retrieve_media(filter = (media == "Atmosphere")) %>%
    retrieve_dataset() %>%
    retrieve_chemical_name(filter = (chemical_name == "lead")) %>%
    retrieve_period(filter = (period >= 2015))

```
![table_12](./documents/table_12.png)

The results show that information for *lead* in the atmosphere is available for years 2015 and 2016 and the data is provide by *AIRQUALITY*.

the process can go on until the user found the information need. As mentioned, filters can be applied over each column of the summary file using dedicated function or the general `retrieve_info()`.


### Example: filtering without a pipeline

As mentioned, to be able to put in a pipeline functions from `retrieve_...` suite, the functions must accept filters before the `target` argument.

The filters placed before `target` (when explicit) or `filter` (when `target` is implicit) must have the name of any column from summary file. Otherwise the filters will be skipped.

The user wants to select all chemicals that contain *lead*:

```
retrieve_chemical_name(filter = isin(chemical_name, "lead"))
```
![table_22](./documents/table_22.png)

The `target` argument is implicit and has the value *chemical_name*. `filter` argument says what chemical to keep.

Any argument that comes before `target` / `filter` is also a filter and those filters can refer to any other column from the *chem_summary*.

The user wants to filter all the chemicals that contain *lead* from dataset *EMPODAT*.

```
retrieve_chemical_name(dataset = "EMPODAT", filter = isin(chemical_name, "lead"))
```

![table_23](./documents/table_23.png)

The user wants to filter all the chemicals that contain *lead* from datasets *EMPODAT* and *ESBUBA*, during year *2015*.

```
retrieve_chemical_name(dataset = c("ESBUBA","EMPODAT"), period = 2015, filter = isin(chemical_name, "lead"))
```

![table_24](./documents/table_24.png)

Each argument before `target` / `filter` will be searched using partial matching. For example, the argument `dataset = c("ESBUBA","EMPODAT")` will search through the *dataset* column if it contains the values *ESBUBA* or *EMPODAT*.

First side effect is that the user can search also partial names, like `dataset = c("ESB","EMP")`. The user must be aware that other datasets might also contain the string *ESB* or *EMP*.

```
retrieve_chemical_name(dataset = c("ESB","EMP"), period = 2015, filter = isin(chemical_name, "lead"))
```

![table_25](./documents/table_25.png)

Second side effect is that the `filter` argument can be replaced with and explicit argument. 

```
retrieve_chemical_name(dataset = c("ESBUBA","EMPODAT"), period = 2015, chemical_name = "lead")
```

![table_26](./documents/table_26.png)

A third side effect of partial matching and the possibility to create a pipeline, is that data frames are considered filters too.

```
df = data.frame(dataset = c("ESBUBA"), period = 2015, chemical_name = "lead")

retrieve_chemical_name(df)
```

![table_27](./documents/table_27.png)

The user must know about these options, but the general recomendation is to use the pipeline version which is more clean and clear.


## Create URLs and download data packages

To download a data package the users needs the URL where it is stored on IPCHEM. Remember that the recipe to create the url for a packages is: http://ipchem.jrc.ec.europa.eu/public/{DATASET}/{PERIOD}/{PACKAGE} .

Following the previous example where the user searches for concentration of lead in the atmosphere, it is time to generate the URLs. 

`create_package_url()` is designed to run in a pipeline with `retrieve_info()`. 

If it is called without argumets, it will create URLs for all packages in the summary file, except the ones *period* is missing.

`create_package_url()` uses elipsys and any argument is considered as a filter for the summary file.

The output is a list of urls.

```
retrieve_media(filter = (media == "Atmosphere")) %>%
    retrieve_dataset() %>%
    retrieve_chemical_name(filter = (chemical_name == "lead")) %>%
    retrieve_period(filter = (period >= 2015)) %>%
    create_package_url()
```
![table_13](./documents/table_13.png)

Now the user has the URLs for selection criteria. The data can be download in 3 ways:
- mannualy copy-paste the URLs and go in a browser
- create a for loop using `download_files()` function
- continue the pipeline with `download_files()`

The last option is for sure the most appealing because it is fast and easy to implement.

### Download data from a single URL: `download_files()`

If the pipeline for selecting data and creating URLs, outputs a single URL, than the user can invoke `download_files()`.

As seen, the example bellow produces 2 URLs. The user will take only the first entry. 

```
retrieve_media(filter = (media == "Atmosphere")) %>%
    retrieve_dataset() %>%
    retrieve_chemical_name(filter = (chemical_name == "lead")) %>%
    retrieve_period(filter = (period >= 2015)) %>%
    create_package_url() %>%
    head(1) %>%
    download_files()
```
![table_14](./documents/table_14.png)

The output is a data frame.

The user can go further with the example and expand also the JSON strings while keeping only a few key value pair. Remeber that in chapter 5 we showed how to explore the information contained in JSON. That process applies here also. But for convenence, let't assume the user already know the keys.

```
nodes <- c("Concentration", "MeasurementType")

df <- retrieve_media(filter = (media == "Atmosphere")) %>%
    retrieve_dataset() %>%
    retrieve_chemical_name(filter = (chemical_name == "lead")) %>%
    retrieve_period(filter = (period >= 2015)) %>%
    create_package_url() %>%
    head(1) %>%
    download_files(exp_jsn = TRUE, json_col = "SOURCE DATA", keep_nodes = nodes)

# print only the last 6 columns
df[, 17:21]
```
![table_17](./documents/table_17.png)

### Download data from multiple URLs: `download_files()`

`download_files()` can take as first argument also a list of URLs. It will return a list of data frames. The name of the list element is the same as the *package* name.

The user will use the same example, over the full list that contains two URLs.

```
retrieve_media(filter = (media == "Atmosphere")) %>%
    retrieve_dataset() %>%
    retrieve_chemical_name(filter = (chemical_name == "lead")) %>%
    retrieve_period(filter = (period >= 2015)) %>%
    create_package_url() %>%
    download_files()
```

![table_18](./documents/table_18.png)

Looking over the output, there are two data frames gathered in a list. 

The task of combining, joining or concatenating the data frames, belongs to the user.

`download_files()` can expand the JSON strings.  

```
nodes <- c("Concentration", "MeasurementType")

ls <- retrieve_media(filter = (media == "Atmosphere")) %>%
    retrieve_dataset() %>%
    retrieve_chemical_name(filter = (chemical_name == "lead")) %>%
    retrieve_period(filter = (period >= 2015)) %>%
    create_package_url() %>%
    download_files(exp_jsn = TRUE, json_col = "SOURCE DATA", keep_nodes = nodes)

# print the last 6 columns
ls[[1]][15:21]
ls[[2]][15:21]
```

The data packages can have different datasets. This means the structure of JSON strings is different from one dataset to another. Expanding the JSON strings must take this account when argument `keep_nodes` is present.

If `keep_nodes` is present, it must contain at least a key from each dataset.

As an example, the user has a list of URLs comming from two datasets, *AIRBASE* and *AIRQUALITY*.

The user wants to download the data packages and expand the JSON column. Only 2 keys will be kept and both of them are from *AIRQUALITY* dataset.

The script will return an error because *AIRBASE* does not contain the keys.

```
nodes <- c("UnitOfMeasurement", "Concentration")
url_list <- c(
    "https://ipchem.jrc.ec.europa.eu/public/AIRQUALITY/2015/IPCHEM_AIRQUALITY_75600abc-35dd-402b-ac9e-c8854e30e7b8.zip",
    "https://ipchem.jrc.ec.europa.eu/public/AIRBASE/2011/IPCHEM_AIRBASE_98304447-a89e-44bf-86be-4061ee55bd76.zip"
)

ls <- download_files(url_list, exp_jsn=TRUE, json_col = "SOURCE DATA", keep_nodes = nodes)
```

![table_19](./documents/table_19.png)

The solution is to provide key for both data packages. In some situation, the same information has a different name from one dataset to another.

```
nodes <- c("UnitOfMeasurement", "Concentration", "Statistic Name", "Statistics Percentage Valid")

ls <- download_files(url_list, exp_jsn=TRUE, json_col = "SOURCE DATA", keep_nodes = nodes)

# show only the last 3 columns
ls[[1]][, 19:21]
ls[[2]][, 19:21]
```
![table_20](./documents/table_20.png)

If a user provides a set of keys to keep, than at least one key must be found in each data package. The keys that are not found are skipped. But if all of the keys are not found, it will return an error.

As a warning, the user must be carreful at the amount of data it will download. Once started, the process will end when all the data is downloaded or when the computer is out of memory.

## Metadata

There is another place where the user can search information about the data offered on the site. 

Each dataset has a prospect called *metadata information*. It is a JSON file that details how and where the data was collected.

To obtain the metadata JSON file for a specific data set, the user can call the function `retrieve_meta()`. 

As input, the function takes the name of one or multiple data sets. The output is a list of lists, each key from the JSON file being a node in the list. If the name of a data set cannot be found, the function will skip it and will continue with the rest of the names.

```
dts <- c("AIRBASE", "NAIADES")
jsn <- retrieve_meta(dts)
jsn
```
![table_21](./documents/table_21.png)

Disclaimer: the output of the examples presented in this document might change over time because IPChem database is in a perpetual process of integrating new data sources.