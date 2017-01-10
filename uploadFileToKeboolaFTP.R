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

