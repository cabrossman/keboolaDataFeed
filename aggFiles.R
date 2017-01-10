pat <- 'OAS_delByContinent'
path <- 'C:\\Users\\christopher.brossman\\Desktop\\keboolaOUTPUT\\'
files <- list.files(path, pattern = pat)
# cnt = 1

x <- NULL
for(i in 1:length(files)){
  # cnt = cnt + 1
  # print(paste0(cnt," of ", length(files)))
  print(paste0(i,": ",files[i]))
  
  # assign(i,read.csv(paste0(path,i)))
  csv <- read.csv(paste0(path,files[i])) %>% group_by(campaign, date, geography) %>% summarise(impressions = sum(impressions), clicks = sum(clicks))
  x <- rbind(x,csv)
  rm(csv)
  
}

path2 <- 'C:\\Users\\christopher.brossman\\Desktop\\keboolaOUTPUT\\combinedFiles\\'
write.csv(x,paste0(path2,pat,'.csv'),row.names = FALSE)
rm(list = ls())

##############################################################################################

pat <- 'OAS_delByCountry'
path <- 'C:\\Users\\christopher.brossman\\Desktop\\keboolaOUTPUT\\'
files <- list.files(path, pattern = pat)
# cnt = 1

x <- NULL
for(i in 1:length(files)){
  # cnt = cnt + 1
  # print(paste0(cnt," of ", length(files)))
  print(paste0(i,": ",files[i]))
  
  # assign(i,read.csv(paste0(path,i)))
  csv <- read.csv(paste0(path,files[i])) %>% group_by(campaign, date, geography) %>% summarise(impressions = sum(impressions), clicks = sum(clicks))
  x <- rbind(x,csv)
  rm(csv)
  
}

path2 <- 'C:\\Users\\christopher.brossman\\Desktop\\keboolaOUTPUT\\combinedFiles\\'
write.csv(x,paste0(path2,pat,'.csv'),row.names = FALSE)
rm(list = ls())

##############################################################################################

pat <- 'OAS_delByState'
path <- 'C:\\Users\\christopher.brossman\\Desktop\\keboolaOUTPUT\\'
files <- list.files(path, pattern = pat)
# cnt = 1

x <- NULL
for(i in 1:length(files)){
  # cnt = cnt + 1
  # print(paste0(cnt," of ", length(files)))
  print(paste0(i,": ",files[i]))
  
  # assign(i,read.csv(paste0(path,i)))
  csv <- read.csv(paste0(path,files[i])) %>% group_by(campaign, date, geography) %>% summarise(impressions = sum(impressions), clicks = sum(clicks))
  x <- rbind(x,csv)
  rm(csv)
  
}

path2 <- 'C:\\Users\\christopher.brossman\\Desktop\\keboolaOUTPUT\\combinedFiles\\'
write.csv(x,paste0(path2,pat,'.csv'),row.names = FALSE)
rm(list = ls())

##############################################################################################

pat <- 'OAS_delByDMA'
path <- 'C:\\Users\\christopher.brossman\\Desktop\\keboolaOUTPUT\\'
files <- list.files(path, pattern = pat)
# cnt = 1

x <- NULL
for(i in 1:length(files)){
  # cnt = cnt + 1
  # print(paste0(cnt," of ", length(files)))
  print(paste0(i,": ",files[i]))
  
  # assign(i,read.csv(paste0(path,i)))
  csv <- read.csv(paste0(path,files[i])) %>% group_by(campaign, date, geography) %>% summarise(impressions = sum(impressions), clicks = sum(clicks))
  x <- rbind(x,csv)
  rm(csv)
  
}

path2 <- 'C:\\Users\\christopher.brossman\\Desktop\\keboolaOUTPUT\\combinedFiles\\'
write.csv(x,paste0(path2,pat,'.csv'),row.names = FALSE)
rm(list = ls())

##############################################################################################

pat <- 'OAS_delByMSA'
path <- 'C:\\Users\\christopher.brossman\\Desktop\\keboolaOUTPUT\\'
files <- list.files(path, pattern = pat)
# cnt = 1

x <- NULL
for(i in 1:length(files)){
  # cnt = cnt + 1
  # print(paste0(cnt," of ", length(files)))
  print(paste0(i,": ",files[i]))
  
  # assign(i,read.csv(paste0(path,i)))
  csv <- read.csv(paste0(path,files[i])) %>% group_by(campaign, date, geography) %>% summarise(impressions = sum(impressions), clicks = sum(clicks))
  x <- rbind(x,csv)
  rm(csv)
  
}

path2 <- 'C:\\Users\\christopher.brossman\\Desktop\\keboolaOUTPUT\\combinedFiles\\'
write.csv(x,paste0(path2,pat,'.csv'),row.names = FALSE)
rm(list = ls())

##############################################################################################

pat <- 'OAS_delByZip'
path <- 'C:\\Users\\christopher.brossman\\Desktop\\keboolaOUTPUT\\'
files <- list.files(path, pattern = pat)
# cnt = 1

x <- NULL
for(i in 1:length(files)){
  # cnt = cnt + 1
  # print(paste0(cnt," of ", length(files)))
  print(paste0(i,": ",files[i]))
  
  # assign(i,read.csv(paste0(path,i)))
  csv <- read.csv(paste0(path,files[i])) %>% group_by(campaign, date, geography) %>% summarise(impressions = sum(impressions), clicks = sum(clicks))
  x <- rbind(x,csv)
  rm(csv)
  
}

path2 <- 'C:\\Users\\christopher.brossman\\Desktop\\keboolaOUTPUT\\combinedFiles\\'
write.csv(x,paste0(path2,pat,'.csv'),row.names = FALSE)
rm(list = ls())

##############################################################################################

pat <- 'OAS_delByPagePos'
path <- 'C:\\Users\\christopher.brossman\\Desktop\\keboolaOUTPUT\\'
files <- list.files(path, pattern = pat)
# cnt = 1

x <- NULL
for(i in 1:length(files)){
  # cnt = cnt + 1
  # print(paste0(cnt," of ", length(files)))
  print(paste0(i,": ",files[i]))
  
  # assign(i,read.csv(paste0(path,i)))
  csv <- read.csv(paste0(path,files[i])) %>% group_by(campaign, date, url, pos) %>% summarise(impressions = sum(impressions), clicks = sum(clicks))
  x <- rbind(x,csv)
  rm(csv)
}

path2 <- 'C:\\Users\\christopher.brossman\\Desktop\\keboolaOUTPUT\\combinedFiles\\'
write.csv(x,paste0(path2,pat,'.csv'),row.names = FALSE)
rm(list = ls())
