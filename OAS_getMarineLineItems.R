OAS_getTargetingByLineItem <- function(campaign_list = NULL){
  options(stringsAsFactors=FALSE)
  library(dplyr)
  
  
  # x <- OAS_listCampPerSites()
  # campaign_list <- x[x$Campaign != 'default',1]$Campaign
  
  #If the campaign list supplied is null then the program goes to download everycampaign
  if(is.null(campaign_list)){
    date <- as.Date('2016-03-31')
    while(date < Sys.Date() + 90){
      print(paste0("date: ",as.character(date)))
      x <- OAS_listCampPerSites(start_date = as.character(date - 90), end_date = as.character(date))
      y <- x[x$Campaign != 'default',1]
      campaign_list <- rbind(campaign_list, y)
      campaign_list <- unique(campaign_list)
      date <- date + 91
    }
    campaign_list <- campaign_list[['Campaign']]
  }
  
  #this downloads all the creative keys and filters for just those in the campaign_list
  # campByPos <- oas_list(oasAuth(), 'Creative',
  #                       search_criteria=list(newXMLNode("CampaignId", "33316-1_13371_DYC-FR_YWFR-SRDT-RT3-300x250"))
  #                       )
  # campByPos <- oas_list(oasAuth(), 'Creative',
  #                       search_criteria=list(newXMLNode("Domain", "www.yachtworld.com"))
  # )
  campByPos <- oas_list(oasAuth(), 'Creative')
  campByPos <- campByPos %>% filter(CampaignId %in% campaign_list) %>% select(id = Id,  campaign_id = CampaignId, position = Positions)
  campByPos <- unique(campByPos)
  
  #here we download all the campaign keys. This is especially important for DMA requests
  # continent_keys <- oas_list_code(oasAuth(), 'Continent')
  # country_keys <- oas_list_code(oasAuth(), 'Country')
  # state_keys <- oas_list_code(oasAuth(), 'State')
  # DMA_keys <- oas_list_code(oasAuth(), 'DMA')
  # MSA_keys <- oas_list_code(oasAuth(), 'MSA')
  
  
  
  #here is whwere we start the big loop. We loop through each campaign in the list and download relevant pieces of information
  allTargetingData <- NULL; marinePos <- NULL; d <- NULL; pageTargetedData <- NULL; bc_tar <- NULL;
  for (c in 1:length(campaign_list)){
    
    #download the campaign through API read. Here are downloads
    print(paste0(c," of ",length(campaign_list)))
    r <- oas_read(credentials=oasAuth(), request_type='Campaign', id=campaign_list[c])
    t <- r$Response$Campaign$Target
    p <- r$Response$Campaign$Content$ManageSites$SiteAllocation$SiteTierDefault$SiteTierSites
    
    
    
    #here is the campaign dim downloads
    d1 <- data.frame(campaign_id=if(is.null(r$Response$Campaign$Overview$Id)) NA else r$Response$Campaign$Overview$Id, 
                     insertion_order=if(is.null(r$Response$Campaign$Overview$InsertionOrderId)) NA else r$Response$Campaign$Overview$InsertionOrderId, 
                     advertiser=if(is.null(r$Response$Campaign$Overview$AdvertiserId)) NA else r$Response$Campaign$Overview$AdvertiserId,
                     CampaignGroupId=if(is.null(r$Response$Campaign$Overview$CampaignGroups$CampaignGroupId)) NA else r$Response$Campaign$Overview$CampaignGroups$CampaignGroupId,
                     bookedImps= if(is.null(r$Response$Campaign$Schedule$Impressions)) NA else as.numeric(r$Response$Campaign$Schedule$Impressions),
                     bookedClicks= if(is.null(r$Response$Campaign$Schedule$Clicks)) NA else as.numeric(r$Response$Campaign$Schedule$Clicks),
                     priority= if(is.null(r$Response$Campaign$Schedule$PriorityLevel)) NA else as.numeric(r$Response$Campaign$Schedule$PriorityLevel),
                     weight= if(is.null(r$Response$Campaign$Schedule$weight)) NA else as.numeric(r$Response$Campaign$Schedule$weight),
                     DeliveryRate = if(is.null(r$Response$Campaign$Schedule$DeliveryRate)) NA else r$Response$Campaign$Schedule$DeliveryRate,
                     ImpOverRun = if(is.null(r$Response$Campaign$Schedule$ImpOverrun)) NA else r$Response$Campaign$Schedule$ImpOverrun,
                     DailyImp = if(is.null(r$Response$Campaign$Schedule$DailyImp)) NA else r$Response$Campaign$Schedule$DailyImp,
                     start_date=if(is.null(r$Response$Campaign$Schedule$StartDate)) NA else r$Response$Campaign$Schedule$StartDate,
                     end_date=if(is.null(r$Response$Campaign$Schedule$EndDate)) NA else r$Response$Campaign$Schedule$EndDate,
                     inventory_reservation=if(is.null(r$Response$Campaign$Overview$InventoryReservation)) NA else r$Response$Campaign$Overview$InventoryReservation,
                     pages=if(is.null(r$Response$Campaign$Pages$Url)) NA else r$Response$Campaign$Pages$Url,
                     contracted_revenue=if(is.null(r$Response$Campaign$Billing$ContractedRevenue)) NA else r$Response$Campaign$Billing$ContractedRevenue,
                     BillOffContracted=if(is.null(r$Response$Campaign$Billing$BillOffContracted)) NA else r$Response$Campaign$Billing$BillOffContracted,
                     cpm=if(is.null(r$Response$Campaign$Billing$Cpm)) NA else as.numeric(r$Response$Campaign$Billing$Cpm),
                     cpc=if(is.null(r$Response$Campaign$Billing$Cpc)) NA else as.numeric(r$Response$Campaign$Billing$Cpc),
                     cpa=if(is.null(r$Response$Campaign$Billing$Cpa)) NA else as.numeric(r$Response$Campaign$Billing$Cpa),
                     FlatRate=if(is.null(r$Response$Campaign$Billing$FlatRate)) NA else as.numeric(r$Response$Campaign$Billing$FlatRate),
                     Currency=if(is.null(r$Response$Campaign$Billing$Currency)) NA else r$Response$Campaign$Billing$Currency,
                     BillingNotes=if(is.null(r$Response$Campaign$Billing$Notes)) NA else r$Response$Campaign$Billing$Notes
    )
    
    d <- rbind(d, d1)
    
    
    
    
    
    
    
    #get all positions downloads
    marinePosDet <- campByPos %>% filter(campaign_id == campaign_list[c])
    if(NROW(marinePosDet) > 0 ){
      for(k in 1:NROW(marinePosDet)){
        #api Call
        w <- oas_read(oasAuth(), 'Creative', id = marinePosDet$id[k], campaign_id = marinePosDet$campaign_id[k])$Response$Creative$Positions
        pos_value <- c()
        if(length(w) > 0){
          for(z in 1:length(w)){
            pos_value <- rbind(pos_value, w[[z]])
          }
        }
        temp <- cbind.data.frame(campaign_id = campaign_list[c], position = pos_value)
        marinePos <- rbind(marinePos, temp)
      }
    }
    
    #brand/class split targeting
    trim <- function (x) gsub("^\\s+|\\s+$", "", x)
    if(t$SearchType == 'A' && length(t$SearchTerm) > 0 && t$SearchTerm != ' '){
      terms <- unlist(strsplit(t$SearchTerm, ","))
      kv <- unlist(strsplit(terms,"="))
      kv <- unlist(strsplit(kv,"="))
      if(length(kv) %% 2 == 1){
        terms <- unlist(strsplit(t$SearchTerm, ","))
        kv <- unlist(strsplit(terms,c("=","-")))
        kv <- unlist(strsplit(kv,"="))
      }
      
      k1 <- NULL; v1 <- NULL
      for(k_v in 1:length(kv)){
        if(k_v %% 2 == 1){
          k1 <- rbind(k1,kv[k_v])
          
        } else {
          v1 <- rbind(v1,kv[k_v])
        }
        
      }
      k2 <- tolower(iconv(trim(k1), "UTF-8", "UTF-8",sub=''))
      v2 <- tolower(iconv(trim(v1), "UTF-8", "UTF-8",sub=''))
      
      temp123 <- cbind.data.frame(campaign_id = campaign_list[c], key = k2, value = v2)
      bc_tar <- rbind(bc_tar, temp123)
    }
    
    #here is the brand/class/geo targeting
    totalCampData <- NULL
    if(length(t) > 0){
      for(i in 1:length(t)){
        key <- names(t)[i]
        value <- c()
        if(length(t[[i]]) > 0){
          for(j in 1:length(t[[i]])){
            value <- rbind(value, t[[i]][[j]])
          }
        } else {
          value <- NA
        }
        temp <- cbind.data.frame(key = key, value = value)
        totalCampData <- rbind(totalCampData, temp)
      }
      campDF <- cbind.data.frame(camp = campaign_list[c], key = totalCampData$key, value = totalCampData$value)
      allTargetingData <- rbind(allTargetingData, campDF)
    }
    
    
    #store page data
    totalCampData <- NULL
    if(length(p) > 0){
      for(i in 1:length(p)){
        key <- names(p[[i]])
        value <- c()
        if(length(key) > 0){
          type <- ifelse(is.null(p[[i]]$Type),NA,p[[i]]$Type)
          section_id <- ifelse(is.null(p[[i]]$SectionId),NA,p[[i]]$SectionId)
          site_domain <- ifelse(is.null(p[[i]]$SiteDomain),NA,p[[i]]$SiteDomain)
        } 
        temp <- cbind.data.frame(type, section_id, site_domain)
        totalCampData <- rbind(totalCampData, temp)
      }
      campDF <- cbind.data.frame(camp = campaign_list[c], type = totalCampData$type, section_id = totalCampData$section_id, site_domain = totalCampData$site_domain)
      
      pageTargetedData <- rbind(pageTargetedData, campDF)
      
    }#end of page data functions
    
    
  } #end of loop
  
  campaign_info <- list(campaign_dim = unique(d), allTargetingData = unique(allTargetingData), 
                        pageTargetedData = unique(pageTargetedData), campaign_pos = unique(marinePos), 
                        bc_tar = unique(bc_tar))
  
  return(campaign_info)
  
} # end of function