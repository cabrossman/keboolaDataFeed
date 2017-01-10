source('~/R files/R_Functions/AuthFunctions.R')
source('~/Projects/work/KeboolaDataFeed/uploadFileToKeboolaFTP.R')
source('~/Projects/work/KeboolaDataFeed/OAS_getMarineLineItems.R')
my_credentials <- oasAuth()
path <- 'C:\\Users\\christopher.brossman\\Desktop\\keboolaOUTPUT\\'

# geo <- as.vector(available_reports %>% filter(grepl('Delivery.Campaign.Geotargeting',report_id)) %>% select(report_name))


end_date <- start_date <- Sys.Date() - 2
print(paste0('Date: ',end_date))

delByContinent <- NULL
delByCountry <- NULL
delByState <- NULL
delByDMA <- NULL
delByMSA <- NULL
delByZip <- NULL
delByPagePos <- NULL
delByDevice <- NULL

campList <- OAS_listCampPerSites(start_date = as.character(start_date), end_date = as.character(end_date))$Campaign

for(i in 1:NROW(campList)){
  print(paste0(i," of ",NROW(campList)))
  
  
  
  result <- tryCatch({
    
    continent_del <- oas_report(credentials = my_credentials, 
                                report_type = 'campaign delivery', 
                                report_name = 'continent delivery information', 
                                id = campList[i], 
                                start_date=as.character(start_date), 
                                end_date=as.character(end_date))
    
    country_del <- oas_report(credentials = my_credentials, 
                              report_type = 'campaign delivery', 
                              report_name = 'country delivery information', 
                              id = campList[i], 
                              start_date=as.character(start_date), 
                              end_date=as.character(end_date))
    
    state_del <- oas_report(credentials = my_credentials, 
                            report_type = 'campaign delivery', 
                            report_name = 'state/province delivery information', 
                            id = campList[i], 
                            start_date=as.character(start_date), 
                            end_date=as.character(end_date))
    
    dma_del <- oas_report(credentials = my_credentials, 
                          report_type = 'campaign delivery', 
                          report_name = 'dma delivery information', 
                          id = campList[i], 
                          start_date=as.character(start_date), 
                          end_date=as.character(end_date))
    
    msa_del <- oas_report(credentials = my_credentials, 
                          report_type = 'campaign delivery', 
                          report_name = 'msa delivery information', 
                          id = campList[i], 
                          start_date=as.character(start_date), 
                          end_date=as.character(end_date))
    
    zip_del <- oas_report(credentials = my_credentials, 
                          report_type = 'campaign delivery', 
                          report_name = 'zip/postal code delivery information', 
                          id = campList[i], 
                          start_date=as.character(start_date), 
                          end_date=as.character(end_date))
    
    pagePos <- oas_report(credentials = my_credentials, 
                          report_type = 'campaign delivery', 
                          report_name = 'page@position delivery information', 
                          id = campList[i], 
                          start_date=as.character(start_date), 
                          end_date=as.character(end_date))
    
    device <- oas_report(credentials = my_credentials, 
                         report_type = 'campaign delivery', 
                         report_name = 'delivery by device', 
                         id = campList[i], 
                         start_date=as.character(start_date), 
                         end_date=as.character(end_date))
    
    if(nrow(continent_del) > 0){
      
      temp <- cbind.data.frame(campaign = campList[i], date = as.character(end_date), geography = continent_del$Continent, 
                               impressions = as.numeric(continent_del$Imps), clicks = as.numeric(continent_del$Clicks))
      
      delByContinent <- rbind(delByContinent,temp)
    }
    
    if(nrow(country_del) > 0){
      
      temp <- cbind.data.frame(campaign = campList[i], date = as.character(as.character(end_date)), geography = country_del$Country, 
                               impressions = as.numeric(country_del$Imps), clicks = as.numeric(country_del$Clicks))
      
      delByCountry <- rbind(delByCountry,temp)
    }
    
    if(nrow(state_del) > 0){
      
      temp <- cbind.data.frame(campaign = campList[i], date = as.character(end_date), geography = state_del$`State-Province`, 
                               impressions = as.numeric(state_del$Imps), clicks = as.numeric(state_del$Clicks))
      
      delByState <- rbind(delByState,temp)
    }
    
    if(nrow(dma_del) > 0){
      
      temp <- cbind.data.frame(campaign = campList[i], date = as.character(end_date), geography = dma_del$Dma, 
                               impressions = as.numeric(dma_del$Imps), clicks = as.numeric(dma_del$Clicks))
      
      delByDMA <- rbind(delByDMA,temp)
    }
    
    if(nrow(msa_del) > 0){
      
      temp <- cbind.data.frame(campaign = campList[i], date = as.character(end_date), geography = msa_del$Msa, 
                               impressions = as.numeric(msa_del$Imps), clicks = as.numeric(msa_del$Clicks))
      
      delByMSA <- rbind(delByMSA,temp)
    }
    
    if(nrow(zip_del) > 0){
      
      temp <- cbind.data.frame(campaign = campList[i], date = as.character(end_date), geography = zip_del$`Zip-PostalCode`, 
                               impressions = as.numeric(zip_del$Imps), clicks = as.numeric(zip_del$Clicks))
      
      delByZip <- rbind(delByZip,temp)
    }
    
    if(nrow(pagePos) > 0){
      
      temp <- cbind.data.frame(campaign = campList[i], date = as.character(end_date), url = pagePos$Page, pos = pagePos$Position,
                               impressions = as.numeric(pagePos$Impressions), clicks = as.numeric(pagePos$Clicks))
      
      delByPagePos <- rbind(delByPagePos,temp)
    }
    
    if(nrow(device) > 0){
      
      temp <- cbind.data.frame(campaign = campList[i], date = as.character(end_date), device = device$Device,
                               impressions = as.numeric(device$Impressions), clicks = as.numeric(device$Clicks))
      
      delByDevice <- rbind(delByDevice,temp)
    }
    
    
    
  }, error = function(err) {
    
    # error handler picks up where error was generated
    print(paste("MY_ERROR:  ",err))
    #next
    
  }) 
  
}

delByContinent2 <- delByContinent %>% group_by(campaign, date, geography) %>% summarise(impressions = sum(impressions), clicks = sum(clicks))
delByCountry2 <- delByCountry %>% group_by(campaign, date, geography) %>% summarise(impressions = sum(impressions), clicks = sum(clicks))
delByState2 <- delByState %>% group_by(campaign, date, geography) %>% summarise(impressions = sum(impressions), clicks = sum(clicks))
delByDMA2 <- delByDMA %>% group_by(campaign, date, geography) %>% summarise(impressions = sum(impressions), clicks = sum(clicks))
delByMSA2 <- delByMSA %>% group_by(campaign, date, geography) %>% summarise(impressions = sum(impressions), clicks = sum(clicks))
delByZip2 <- delByZip %>% group_by(campaign, date, geography) %>% summarise(impressions = sum(impressions), clicks = sum(clicks))
delByPagePos2 <- delByPagePos %>% group_by(campaign, date, url, pos) %>% summarise(impressions = sum(impressions), clicks = sum(clicks))
delByDevice2 <- delByDevice %>% group_by(campaign, date, device) %>% summarise(impressions = sum(impressions), clicks = sum(clicks))

# write.csv(delByContinent2, paste0(path,'OAS_delByContinent_',end_date,'.csv'), row.names = FALSE)
# write.csv(delByCountry2, paste0(path,'OAS_delByCountry_',end_date,'.csv'), row.names = FALSE)
# write.csv(delByState2, paste0(path,'OAS_delByState_',end_date,'.csv'), row.names = FALSE)
# write.csv(delByDMA2, paste0(path,'OAS_delByDMA_',end_date,'.csv'), row.names = FALSE)
# write.csv(delByMSA2, paste0(path,'OAS_delByMSA_',end_date,'.csv'), row.names = FALSE)
# write.csv(delByZip2, paste0(path,'OAS_delByZip_',end_date,'.csv'), row.names = FALSE)
# write.csv(delByPagePos2, paste0(path,'OAS_delByPagePos_',end_date,'.csv'), row.names = FALSE)

write.csv(delByContinent2, paste0(path,'OAS_delByContinent.csv'), row.names = FALSE)
write.csv(delByCountry2, paste0(path,'OAS_delByCountry.csv'), row.names = FALSE)
write.csv(delByState2, paste0(path,'OAS_delByState.csv'), row.names = FALSE)
write.csv(delByDMA2, paste0(path,'OAS_delByDMA.csv'), row.names = FALSE)
write.csv(delByMSA2, paste0(path,'OAS_delByMSA.csv'), row.names = FALSE)
write.csv(delByZip2, paste0(path,'OAS_delByZip.csv'), row.names = FALSE)
write.csv(delByPagePos2, paste0(path,'OAS_delByPagePos.csv'), row.names = FALSE)
write.csv(delByDevice2, paste0(path,'OAS_delByDevice.csv'), row.names = FALSE)
logFile <- uploadFileToKeboolaFTP(path)


marineLineItems <- OAS_getTargetingByLineItem(campaign_list = campList[campList!= 'default'])
write.csv(marineLineItems$campaign_dim, paste0(path,'OAS_campaign_dim.csv'), row.names = FALSE, na = '')
write.csv(marineLineItems$allTargetingData, paste0(path,'OAS_allTargetingData.csv'), row.names = FALSE, na = '')
write.csv(marineLineItems$pageTargetedData, paste0(path,'OAS_pageTargetedData.csv'), row.names = FALSE, na = '')
write.csv(marineLineItems$campaign_pos, paste0(path,'OAS_campaign_pos.csv'), row.names = FALSE, na = '')
write.csv(marineLineItems$bc_tar, paste0(path,'OAS_brand_targeting.csv'), row.names = FALSE, na = '')

logFile <- uploadFileToKeboolaFTP(path)
logFile$file_download_date <- end_date
hist.log <- read.csv(paste0(path,'logFile.csv'))

newLogFile <- rbind(logFile,hist.log)
write.csv(newLogFile,paste0(path,'logFile.csv'), row.names = FALSE)


