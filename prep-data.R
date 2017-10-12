library(tidyverse)
library(stringr)
library(glue)
library(magrittr)

file.create("ga")
write('\noutput_dir: "docs"', file="_bookdown.yml",append=TRUE)

replace_in_file <- function(file, pattern, replacement){
  a <- read_file(file) 
  a <- str_replace_all(a, pattern, replacement)
  write(a, file)
}

replace_in_file("index.Rmd", "A Minimal Book Example", "Writing R extensions")
replace_in_file("index.Rmd", "Yihui Xie", "R Development Core Team")
replace_in_file("index.Rmd", "Yihui Xie", "R Development Core Team")
replace_in_file("index.Rmd", "Yihui Xie", "R Development Core Team")
replace_in_file("index.Rmd", 
                "This is a minimal example of using the bookdown package to write a book. The output format for this example is bookdown::gitbook.", 
                "Writing R Extensions covers how to create your own packages, write R help files, and the foreign language (C, C++, Fortran, ...) interfaces.	")
# get epub

download.file("https://cran.r-project.org/doc/manuals/r-release/R-exts.epub", destfile = "r-exts.epub")
unzip(zipfile = "r-exts.epub")
file.remove(c("toc.ncx","titlepage.xhtml", "stylesheet.css"))

# Rename file and keep a track of file change
rename_file <- function(name){
  new_file <- gsub("(R-exts)_split_([0-9]*)", "\\2-\\1", name)
  new_file <- gsub("^0", "", new_file)
  file.rename(from = name, to = new_file)
  return(data.frame(orig = name, new = new_file))
}

file_names_change <- purrr::map_df(list.files(pattern = "R-exts"), rename_file)

html_converter <- function(file){
  file_name <- gsub("\\.html", "", file)
  system(command = glue("pandoc {file_name}.html -o {file_name}.Rmd"))
}

purrr::walk(list.files(pattern = "R-exts"), html_converter)

purrr::walk(list.files(pattern = "\\.html"), file.remove)

clean_html_rmd <- function(file){
  
  a <- readLines( file )
  
  a %<>% str_replace_all("<h1 .*>([A-Za-z0-9])", "# \\1") %>%
    str_replace_all("</h1>", "")%>% 
    str_replace_all("<h2 .*>([A-Za-z0-9])", "# \\1") %>%
    str_replace_all("</h2>", "") %>%
    str_replace_all("# [0-9]+", "# ")
  write(a, file = file)
}

purrr::walk(list.files(pattern = "Rmd"), clean_html_rmd)

clean_auto_ref <- function(file){
  
  a <- readLines( file )
  
  a %<>% str_replace_all("(R-intro)_split_([0-9]*)", "\\2-\\1") %>%
    str_replace_all("^0", "")
  write(a, file = file)
  
}

purrr::walk(list.files(pattern = "Rmd"), clean_auto_ref)

build_url_ref <- function(file){
  a <- readLines( file )
  url <- tolower(a[1]) %>%
    str_replace_all("# *", "") %>%
    str_replace_all(" ", "-")
  return(glue("{url}.html"))
}

file_names_change$url <- map(list.files(pattern = "exts.Rmd"), build_url_ref)

# Remove some useless files

file.remove(c("01-intro.Rmd","02-literature.Rmd","03-method.Rmd",
              "04-application.Rmd", "05-summary.Rmd","06-references.Rmd"))
file.remove("00-R-exts.Rmd")
file.remove("01-R-exts.Rmd")

file.append("index.Rmd", "02-R-exts.Rmd")

file.append("index.Rmd", "03-R-exts.Rmd")

# Prevent titles in index from being in the table of content

replace_in_file("index.Rmd", pattern = "(# [A-Za-z0-9 ]*)", "\\1 {-}")

file.remove(c("02-R-exts.Rmd", "03-R-exts.Rmd"))

# Manually replace url 

clean_url <- function(file, pattern, replacement){
  a <- readLines( file )
  
  clean_url <- as.character(replacement)
  names(clean_url) <- pattern
  # Because special case here
  clean_url[6] <- "writing-package-vignettes.html"
  
  a %<>% str_replace_all(clean_url)
  
  write(a, file = file)
}

purrr::walk(list.files(pattern = "Rmd"), clean_url, pattern = file_names_change$orig, replacement = file_names_change$url)


# Remove \ because it's an html troublemaker

purrr::map(list.files(pattern = "Rmd"), replace_in_file,  pattern = "\\\\", replacement = "&#92;")

# So is $

purrr::map(list.files(pattern = "Rmd"), replace_in_file,  pattern = "\\$", replacement = "&#36;")


# Some manual tweaking because this function is not perfect 

replace_in_file("04-R-exts.Rmd", "writing-package-vignettes.html#Package-types", "creating-r-packages.html#Package-types")
replace_in_file("04-R-exts.Rmd", "writing-package-vignettes.html#Package-namespaces", "creating-r-packages.html#Package-namespaces")
replace_in_file("04-R-exts.Rmd", "writing-package-vignettes.html#Encoding-issues", "creating-r-packages.html#Encoding-issues")
replace_in_file("04-R-exts.Rmd", "writing-package-vignettes.html#Writing-R-documentation-files", "writing-r-documentation-files.html")
replace_in_file("05-R-exts.Rmd", "writing-package-vignettes.html#Package-types", "creating-r-packages.html#Package-types")
replace_in_file("05-R-exts.Rmd", "writing-package-vignettes.html#Package-namespaces", "creating-r-packages.html#Package-namespaces")
replace_in_file("05-R-exts.Rmd", "writing-package-vignettes.html#Encoding-issues", "creating-r-packages.html#Encoding-issues")
replace_in_file("05-R-exts.Rmd", "writing-package-vignettes.html#Writing-R-documentation-files", "writing-r-documentation-files.html")
replace_in_file("09-R-exts.Rmd","the-r-api:-entry-points-for-c-code", "the-r-api-entry-points-for-c-code.html")

# Remove \ because it's an html troublemaker

purrr::map(list.files(pattern = "Rmd"), replace_in_file,  pattern = "\\\\", replacement = "&#92;")

# Build \o/

bookdown::render_book("index.Rmd", "bookdown::gitbook")
