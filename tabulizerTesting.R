library(tabulizer)
library(magrittr)
library(tidyr)
library(dplyr)
library(ggplot2)
library(plotly)

#Setup data
getUrl <- function(year){
  
  out <- c()
  
  for (i in 1:length(year)) {
    if (year[i] < 2016) {
      
      yearCode <- paste(year[i]-1, "-", year[i]-2000, sep="")
      
      out <- append(out, paste("https://coronialservices.justice.govt.nz/assets/Documents/Publications/", 
                               yearCode, 
                               "-annual-provisional-suicide-figures.pdf", 
                               sep=""
                               )
                    )
      
    } else {
      
      out <- append(out, ifelse(year[i] == 2016, 
                                "https://coronialservices.justice.govt.nz/assets/Documents/Publications/2016-provisional-suicide-figures.pdf",
                                "https://coronialservices.justice.govt.nz/assets/Documents/Publications/2016-17-annual-provisional-suicide-figures-20170828.pdf"
                                )
                    )
      
    }
  }
  
  if (2011 %in% year) {
    out[match(2011, year)] <- "https://coronialservices.justice.govt.nz/assets/Documents/Publications/2010-11-annual-provisional-suicide-figures-media-release.pdf"
  }
  
  if (2012 %in% year) {
    out[match(2012, year)] <- "https://coronialservices.justice.govt.nz/assets/Documents/Publications/2011-12-annual-provisional-suicide-figures-media-release.pdf"
  }
  
  return(out)
}

#Inconsistent document layout means I hardcode different page references :(
getAgeTables <- function(urls) {
  
  out <- data.frame()
  
  for (i in 1:length(urls)) {
    
    if (names(urls)[i] %in% c(2011, 2012)) {
      page <- ifelse(names(urls)[i] == 2011, 3, 4) 
      raw <- as.data.frame(extract_tables(urls[i], pages=page)[[1]][,c(1, 9, 11)])
    } else {
      raw <- as.data.frame(extract_tables(urls[i], pages=2)[[1]][,c(1, 11, 14)])
    }
    
    out <- rbind(out, data.frame(rep(names(urls)[i], length(raw[,1])), raw))
    
  }
  
  colnames(out) <- c("year", "category", "num", "rate")
  
  return(out)
  
}

#This allows you to pull any page from the latest release
getLatestTable <- function(page) {
  extract_tables(urls[length(urls)], pages = page)
}

#Generate URLS and name
urls <- getUrl(2011:2017)
names(urls) <- 2011:2017

##########################Get age data
age <- getAgeTables(urls) %>% 
  filter(!(category == "" | num == "" | category == "5-9"))

age[c("category", "year")] <- lapply(age[c("category", "year")], as.ordered)
age[c("num", "rate")] <- lapply(age[c("num", "rate")], function(x) {as.numeric(levels(x))[x]})
age %<>% mutate(measure = factor("age"))

##########################Get region data (page 6)
region <- filter(data.frame(getLatestTable(6)), X1 != "DHB Region") %>%
  select(-X12)
colnames(region) <- c("category", 2008:2017)
region <- gather(region, "year", "num", 2:11) %>%
  mutate(num = as.numeric(num))

#Load population data from NZ.Stat to calculate rates for regions
pop <- read.csv("regionalPopulation.csv") %>%
  mutate(year = as.factor(year))

region <- full_join(region, pop, by = c("category", "year")) %>%
  mutate(rate = num / pop * 100000, measure = factor("region")) %>%
  select(-pop)

##########################Get ethnicity data

#Found it easier to get the rates and numbers seperate
#Start with getting the rates
ethnicity.rate <- data.frame(getLatestTable(3)[[1]]) %>%
  select(X2, X6, X9, X12, X14)

ethnicity.rate <- ethnicity.rate[3:length(ethnicity.rate$X2),] %>%
  mutate(X14 = as.numeric(
    purrr::map(
      strsplit(as.character(X14), " "), 2
      )
    ),
    X2 = 2008:2017
    )
      
colnames(ethnicity.rate) <- c("year", "asian", "maori", "pacific", "european and other")

ethnicity.rate <- gather(ethnicity.rate, "category", "rate", 2:5) %>%
  mutate(measure = "ethnicity")

#Now get the counts/numbers
ethnicity.count <- data.frame(getLatestTable(3)[[1]]) %>%
  select(X2, X4, X7, X8, X11, X14) %>%
  mutate(X9 = paste(as.character(X7), as.character(X8), sep = "")) %>%
  select(-X7, -X8)

ethnicity.count <- ethnicity.count[3:length(ethnicity.count$X2),] %>%
  mutate(X14 = as.numeric(
    purrr::map(
      strsplit(as.character(X14), " "), 1
    )
  ),
  X2 = 2008:2017
  )

colnames(ethnicity.count) <- c("year", "asian", "pacific", "european and other", "maori")

ethnicity.count <- gather(ethnicity.count, "category", "num", 2:5)

#Merge num column onto rates
ethnicity <- merge(ethnicity.rate, ethnicity.count, by=c("year", "category"))

##########################Merge data
dat <- rbind(age, region[,colnames(age)], ethnicity[,colnames(age)])

dat$year <- ordered(dat$year, 2008:2017)
dat$num <- as.numeric(dat$num)

saveRDS(dat, "suicideApp/dat.RDS")

