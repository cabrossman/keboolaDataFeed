source('~/R files/R_Functions/AuthFunctions.R')
my_credentials <- oasAuth()
start_date <- as.Date('2016-01-01')
end_date <- Sys.Date()
path <- 'C:\\Users\\christopher.brossman\\Desktop\\keboolaOUTPUT\\'

# geo <- as.vector(available_reports %>% filter(grepl('Delivery.Campaign.Geotargeting',report_id)) %>% select(report_name))
 
for(j in 1:100){
  end_date <- start_date <- as.Date('2016-08-15') - j
  print(paste0('Date: ',end_date))
  
  delByContinent <- NULL
  delByCountry <- NULL
  delByState <- NULL
  delByDMA <- NULL
  delByMSA <- NULL
  delByZip <- NULL
  delByPagePos <- NULL
  
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
      
      
      
      
    }, error = function(err) {
      
      # error handler picks up where error was generated
      print(paste("MY_ERROR:  ",err))
      #next
      
    }) 
    
  }
  
  write.csv(delByContinent, paste0(path,'OAS_delByContinent_',end_date,'.csv'), row.names = FALSE)
  write.csv(delByCountry, paste0(path,'OAS_delByCountry_',end_date,'.csv'), row.names = FALSE)
  write.csv(delByState, paste0(path,'OAS_delByState_',end_date,'.csv'), row.names = FALSE)
  write.csv(delByDMA, paste0(path,'OAS_delByDMA_',end_date,'.csv'), row.names = FALSE)
  write.csv(delByMSA, paste0(path,'OAS_delByMSA_',end_date,'.csv'), row.names = FALSE)
  write.csv(delByZip, paste0(path,'OAS_delByZip_',end_date,'.csv'), row.names = FALSE)
  write.csv(delByPagePos, paste0(path,'OAS_delByPagePos_',end_date,'.csv'), row.names = FALSE)
  
}



