##############################################
# Copyright (c) 2020 Thomas Gredig
# Email: tgredig@csulb.edu
#
# Poll Report
# ===========
# run this file to generate output DATA
# files from Zoom Polling data in Polling
# folder
##############################################


source("Config.R")
source('Polling-Answers.R')



#############################
## convert email to full name
#############################
getName <- function(em) {
  nm = gsub('\\.','',sapply(strsplit(em,'@'),'[[',1))
  gsub('\\d+','',nm)
}
getName2 <- function(name) { gsub(' ','',tolower(name)) }




####################
# load student names
####################
ds = read.csv(file.path(path.poll,file.students))
print(paste("Loading student names from:",file.students))
ds$Last.Name = gsub("'","", ds$Last.Name)
ds$name = getName2(paste(ds$First.Name,ds$Last.Name))
ds = ds[,-which(names(ds)=='Email')]
ds = ds[,-which(names(ds)=='End.of.Line.Indicator')]


####################
# load polling data
####################
print(paste("Found ",length(file.list)," polling files."))

for(fn in file.list) {
  print(paste("Loading:",fn))
  fileName = file.path(path.poll, fn)
  pollDate = gsub(".*(\\d{4}-\\d{2}-\\d{2}).*", '\\1', fileName)
  file.output = file.path(path.poll,paste0('output-polling_',pollDate,'.csv'))
  ANSWERS = myKey[pollDate][[1]]
  if(is.null(ANSWERS)) next

  d = read.csv(fileName, skip =6, header=FALSE, stringsAsFactors = FALSE)
  names(d) = c('num','qname','email','date','question','answer')
  d$name=getName(d$email)
  d$Poll = substr(d$question,1,4)
  dp = d[grep('POLL',d$question),]
  dp$name = tolower(dp$name)
  dp$question = factor(dp$question)

  print(paste("Found: ",length(levels(dp$question))," poll questions."))
  ds2=ds
  for(q in levels(dp$question)) {
    d1 = subset(dp, question==q)
    print(nrow(d1))
    q.num = as.numeric(gsub('.*(\\d):.*','\\1',q))
    d1$answer[q.num]
    dq = data.frame(
      name = d1$name,
      pts = as.numeric((d1$answer == ANSWERS[q.num]))
    )
    names(dq)[2] = paste0("Q_",q.num)
    ds2 = merge(ds2,dq,by="name",all.x=TRUE)
  }

  ds1=ds2[,-1]
  num.Questions = (ncol(ds1)-3)

  if (length(ds1)==4) { # in the event of only one question
    pt.part = as.numeric(!is.na(ds1[,4]))*2
    pt.sum = ds1[,4]
  } else {
    pt.part = apply(ds1[,-c(1,2,3)],1,function(x) {sum(is.na(x))})
    pt.sum = apply(ds1[,-c(1,2,3)],1,sum,na.rm=TRUE)
    pt.part = as.numeric((pt.part <= floor(num.Questions/2)))*2
  }


  ds1$pts = pt.sum
  ds1$part = pt.part

  poll.colname = paste0("Poll ",format(as.Date(pollDate),format="%b %d")," Points Grade")
  ds1$xx = pt.sum+pt.part
  names(ds1)[which(names(ds1)=='xx')] = poll.colname
  ds1$`End-of-Line Indicator` = "#"

  write.csv(ds1, file=file.output, row.names=FALSE)
  print(paste("Saved to: ",file.output))
}


########################
# merge all output files
#########################

output.file.list = dir(path.poll, pattern='output-polling')
ds2 = ds
for(f in output.file.list) {
  d = read.csv(file.path(path.poll,f))
  head(d)
  d = d[,-grep("Q_",names(d))]
  d = d[,-grep("pts",names(d))]
  d = d[,-grep("part",names(d))]
  ds2 = merge(ds2, d, by="OrgDefinedId")
}


ds2 = ds2[,-grep(".x",names(ds2))]
ds2 = ds2[,-grep(".y",names(ds2))]


########################
# save output file
#########################
write.csv(ds2,file=OUTPUT_D2L, row.names = FALSE)
