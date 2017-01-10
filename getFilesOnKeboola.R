library(RCurl)
library(stringr)

#get list of files on FTP
url <- "ftp://ftp.cloudgates.net"
userpwd <- "gate-vuxiss:1sS6rE6vzFsQ"
filenames <- getURL(url, userpwd = userpwd, ftp.use.epsv = FALSE, dirlistonly = TRUE) 
files <- unlist(strsplit(filenames, "\r\n"))


#get specific file on FTP
url <- "ftp://ftp.cloudgates.net/url_map.zip"
userpwd <- "gate-vuxiss:1sS6rE6vzFsQ"
bin = getBinaryURL(url, userpwd = userpwd, verbose = TRUE,
                   ftp.use.epsv = TRUE)
writeBin(bin,'url_map.zip')


url <- "ftp://ftp.cloudgates.net/OAS_delByContinent.csv"
userpwd <- "gate-vuxiss:1sS6rE6vzFsQ"
bin = getBinaryURL(url, userpwd = userpwd, verbose = TRUE,
                   ftp.use.epsv = TRUE)
writeBin(bin,'OAS_delByContinent.csv')
