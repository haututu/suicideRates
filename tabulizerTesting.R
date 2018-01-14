library(tabulizer)
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

getTables <- function(urls) {
  
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
  
  colnames(out) <- c("year", "agegp", "num", "rate")
  
  return(out)
  
}

urls <- getUrl(2011:2017)
names(urls) <- 2011:2017

data <- getTables(urls) %>% 
          filter(!(agegp == "" | num == "" | agegp == "5-9"))

data[c("agegp", "year")] <- lapply(data[c("agegp", "year")], as.ordered)
data[c("num", "rate")] <- lapply(data[c("num", "rate")], function(x) {as.numeric(levels(x))[x]})

ggplot(filter(data, agegp %in% c("20-24", "Total")), aes(x=year, y=rate, group=agegp)) +
  geom_line()

ggplotly(ggplot(data, aes(x=year, y=rate, group=agegp, color=agegp)) +
           geom_line() +
           theme_classic()
         )

ggplotly(ggplot(filter(data, agegp != "Total"), aes(x=year, y=num, group=agegp, color=agegp)) +
           geom_line() +
           theme_minimal()
         )


