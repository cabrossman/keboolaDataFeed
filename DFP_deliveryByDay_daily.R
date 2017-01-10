#############################################################
#                           packages and AuthFunction       #
#############################################################


rm(list = ls())

#dfp auth
dfpAuth <- function(){
  suppressMessages(library("rdfp"))
  options(rdfp.network_code = "29685107")
  options(rdfp.application_name = "MyApp")
  options(rdfp.client_id = "992031099147-71td3s047cpnmikis4qald76o4l56476.apps.googleusercontent.com")
  options(rdfp.client_secret = "Vlt2eQlMsRNeHvE8UfVA9qSy")
  dfp_auth()
}


options(stringsAsFactors = FALSE)
suppressMessages(require(forecast))
suppressMessages(library(XML))
suppressMessages(library(stringr))
suppressMessages(library(lubridate))
suppressMessages(library(dplyr))
suppressMessages(library(tidyr))
suppressMessages(library(sqldf))
suppressMessages(library(ggplot2))
suppressMessages(library(broom))
suppressMessages(library("rdfp"))
suppressMessages(library(RCurl))
dfpAuth()


#############################################################
#                           keboola FTP upload ftn         #
#############################################################


uploadFileToKeboolaFTP <- function(folder,fname = NA){
  
  suppressMessages(library(RCurl))
  
  host <- 'ftp.cloudgates.net'
  user <- 'gate-vuxiss'
  password <- '1sS6rE6vzFsQ'
  
  logFile <- NULL
  
  if(is.na(fname)){
    files <- list.files(folder)
    
    for(i in 1:length(files)){
      print(paste0(i," of ",length(files)))
      ftpText <- paste0('ftp://',user,':',password,'@',host,'/',files[i])
      filepath <- paste0(folder,"/",files[i])
      x <- ftpUpload(filepath, ftpText)
      temp <- cbind.data.frame(file = files[i], time = as.character(Sys.time()), status = x)
      row.names(temp) <- i
      logFile <- rbind(logFile,temp)
    }
    
  } else {
    ftpText <- paste0('ftp://',user,':',password,'@',host,'/',fname)
    filepath <- paste0(folder,"/",fname)
    x <- ftpUpload(filepath, ftpText)
    logFile <- cbind.data.frame(file = fname, time = as.character(Sys.time()), status = x)
    row.names(logFile) <- 1
  }
  
  return(logFile)
  
}


#############################################################
#                           API helper funciton             #
#############################################################

API_exponential_backoff_retry <- function(expr, n = 5, verbose = FALSE){
  
  for (i in seq_len(n)) {
    
    result <- try(eval.parent(substitute(expr)), silent = FALSE)
    
    if (inherits(result, "try-error")){
      
      backoff <- runif(n = 1, min = 0, max = 2 ^ i - 1)
      if(verbose){
        message("Error on attempt ", i,
                ", will retry after a back off of ", round(backoff, 2),
                " seconds.")
      }
      Sys.sleep(backoff)
      
    } else {
      if(verbose){
        message("Succeed after ", i, " attempts")
      }
      break 
    }
  }
  
  if (inherits(result, "try-error")) {
    message("Failed after max attempts")
    result <- NULL
  } 
  
  return(result)
} 

#############################################################
#                           del funciton                    #
#############################################################


DFP_getDeliveryInfo <- function(
  date = Sys.Date() - 2,
  column1 = 'TOTAL_LINE_ITEM_LEVEL_IMPRESSIONS',
  column2 = 'TOTAL_LINE_ITEM_LEVEL_CLICKS'
){
  
  print(date)
  #column = 'AD_SERVER_IMPRESSIONS'
  start_year = as.numeric(format(date, "%Y"))
  start_month = as.numeric(format(date, "%m"))
  start_day = as.numeric(format(date, "%d"))
  end_year = as.numeric(format(date, "%Y"))
  end_month = as.numeric(format(date, "%m"))
  end_day = as.numeric(format(date, "%d"))
  start_date <- list(year=start_year, month=start_month, day=start_day)
  end_date <- list(year=end_year, month=end_month, day=end_day)
  
  #pagePos
  delByKV <- list(reportJob =
                    list(reportQuery =
                           list(dimensions = 'LINE_ITEM_NAME',
                                dimensions = 'AD_UNIT_ID',
                                dimensions = 'CUSTOM_CRITERIA',
                                adUnitView = 'FLAT',
                                columns = column1, 
                                columns = 'TOTAL_LINE_ITEM_LEVEL_TARGETED_IMPRESSIONS',
                                columns = column2, 
                                startDate = start_date,
                                endDate = end_date,
                                dateRangeType = 'CUSTOM_DATE'
                                #, statement=list(query="WHERE LINE_ITEM_NAME = '26334-1_13157_NelsonsSpeed_M-BTOL-SR-T-320x80-WESTMI'")
                           )))
  
  #regeion
  geo_request_reg <- list(reportJob =
                            list(reportQuery =
                                   list(dimensions = 'LINE_ITEM_NAME',
                                        dimensions = 'REGION_NAME',
                                        adUnitView = 'FLAT',
                                        columns = column1, 
                                        columns = column2,
                                        startDate = start_date,
                                        endDate = end_date,
                                        dateRangeType = 'CUSTOM_DATE'
                                        #, statement=list(query="WHERE LINE_ITEM_NAME = '26334-1_13157_NelsonsSpeed_M-BTOL-SR-T-320x80-WESTMI'")
                                   )))
  
  #zip
  geo_request_zip <- list(reportJob =
                            list(reportQuery =
                                   list(dimensions = 'LINE_ITEM_NAME',
                                        dimensions = 'POSTAL_CODE',
                                        adUnitView = 'FLAT',
                                        columns = column1, 
                                        columns = column2,
                                        startDate = start_date,
                                        endDate = end_date,
                                        dateRangeType = 'CUSTOM_DATE'
                                        #, statement=list(query="WHERE LINE_ITEM_NAME = '26334-1_13157_NelsonsSpeed_M-BTOL-SR-T-320x80-WESTMI'")
                                   )))
  
  #DeviceCategory 
  delByDevice <- list(reportJob =
                        list(reportQuery =
                               list(dimensions = 'LINE_ITEM_NAME',
                                    dimensions = 'DEVICE_CATEGORY_NAME',
                                    adUnitView = 'FLAT',
                                    columns = column1, 
                                    columns = column2, 
                                    startDate = start_date,
                                    endDate = end_date,
                                    dateRangeType = 'CUSTOM_DATE'
                                    #, statement=list(query="WHERE LINE_ITEM_NAME = '26334-1_13157_NelsonsSpeed_M-BTOL-SR-T-320x80-WESTMI'")
                               )))
  
  
  print('downloading KV data')
  delByKV_data <- API_exponential_backoff_retry(dfp_full_report_wrapper(delByKV))
  pagePos_data <- delByKV_data[grepl("^pos",delByKV_data$Dimension.CUSTOM_CRITERIA),]
  KV_data <- delByKV_data[!grepl("^pos",delByKV_data$Dimension.CUSTOM_CRITERIA),]
  
  print('downloading region data')
  geo_data_reg <- API_exponential_backoff_retry(dfp_full_report_wrapper(geo_request_reg))
  print('downloading zip data')
  geo_data_zip <- API_exponential_backoff_retry(dfp_full_report_wrapper(geo_request_zip))
  print('downloading device data')
  delByDevice_data <- API_exponential_backoff_retry(dfp_full_report_wrapper(delByDevice))
  
  kv_names <- c('line_item_name', 'ad_unit_id', 'key_val', 'line_item_id', 'custom_targeting_value_id','ad_unit_name','tot_impressions','target_impression', 'clicks')
  device_names <- c('line_item_name', 'device_category_name', 'line_item_id', 'device_category_id','impressions', 'clicks')
  geo_names <- c('line_item_name', 'geo', 'line_item_id', 'geo_id','impressions', 'clicks')
  
  names(pagePos_data) <- names(KV_data) <- kv_names
  names(geo_data_reg) <- names(geo_data_zip) <- geo_names
  names(delByDevice_data) <- device_names
  
  
  pagePos_data$date <- as.character(date)
  KV_data$date <- as.character(date)
  geo_data_reg$date <- as.character(date)
  geo_data_zip$date <- as.character(date)
  delByDevice_data$date <- as.character(date)
  
  del_list <- list(pagePos_data = pagePos_data, KV_data = KV_data, geo_data_reg = geo_data_reg, 
                   geo_data_zip = geo_data_zip, delByDevice_data = delByDevice_data)
  
  return(del_list)
}

#############################################################
#                           run time                        #
#############################################################
#dfpAuth()
path <- 'C:\\Users\\christopher.brossman\\Desktop\\keboolaOUTPUT\\'
#d_date <- as.Date('2016-01-01')

#for(i in 0:365){
#d <- d_date + i
d <- Sys.Date() - 2
dfp_del_list <- DFP_getDeliveryInfo(d)

#removes non utf-8 chars
pagePos_data <- as.data.frame(sapply(dfp_del_list$pagePos_data,function(x1) iconv(x1,"UTF-8","UTF-8", sub = '')))
KV_data <- as.data.frame(sapply(dfp_del_list$KV_data,function(x1) iconv(x1,"UTF-8","UTF-8", sub = '')))
geo_data_reg <- as.data.frame(sapply(dfp_del_list$geo_data_reg,function(x1) iconv(x1,"UTF-8","UTF-8", sub = '')))
geo_data_zip <- as.data.frame(sapply(dfp_del_list$geo_data_zip,function(x1) iconv(x1,"UTF-8","UTF-8", sub = '')))
delByDevice_data <- as.data.frame(sapply(dfp_del_list$delByDevice_data,function(x1) iconv(x1,"UTF-8","UTF-8", sub = '')))


print('writing files to drive')
write.csv(pagePos_data, paste0(path,'DFPdelByPagePos.csv'), row.names = FALSE, na = "")
write.csv(KV_data, paste0(path,'DFPdelByKV.csv'), row.names = FALSE, na = "")
write.csv(geo_data_reg, paste0(path,'DFPdelByRegion.csv'), row.names = FALSE, na = "")
write.csv(geo_data_zip, paste0(path,'DFPdelByZIP.csv'), row.names = FALSE, na = "")
write.csv(delByDevice_data, paste0(path,'DFPdelByDevice.csv'), row.names = FALSE, na = "")
print('finished')
#}

uploadFileToKeboolaFTP(path)