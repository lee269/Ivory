library(foreign)
library(utils)
library(readxl)
library(RTextTools)
library(splitstackshape)
library(here)


#Clear environment
rm(list = ls())

# Function to import text from questions given in Qlist

import_text <- function(fname, Qlist, func = read_excel) {
  
  #import text for all questions
  df <- func(fname, sheet="text responses", range="A1:AD5716")
  
  #for each question in Qlist, append codes
  for (i in seq(1,nrow(Qlist))) {
    q_codes <- func(fname, sheet=Qlist[i,1], range=Qlist[i,2])
    #cbind(df,vector(mode = "numeric", length = length(df$`Response ID`))) #doesn't like this! Surely I can append directly?
    df[match(q_codes$`Response ID`, df$`Response ID`), ncol(df)+1] <- apply(q_codes,1,match,x=1) - 1
    colnames(df)[ncol(df)] <- paste(Qlist[i,1],"code",sep = "_",collapse = NULL)
  }
  
  return(df)
}



wd <- "//LER329FS/m991728$/Random Jobs/Ivory/"
setwd(wd)

fname <- "Response master spreadsheet 040118 - non sensitive - v1 - final.xlsx"

#matrix containing question numbers (sheet names in .xlsx) for which to retreive a code, and the data range in the respective code sheet
Qlist <- cbind(c("Q1", "Q2", "Q3"), 
               c("A1:J5716", "A1:G5716", "A1:H5716")
)

#import data and match codes for questions in Qlist
df <- import_text(here("data", "consultation", fname), Qlist)

#rename Q1 text
colnames(df)[2] <- "Q1_text"
colnames(df)[3] <- "Q2_text"
colnames(df)[4] <- "Q3_text"

# remove any documents with " NA " - it causes algorithms to fall down
if (length(grep(" NA ",df$Q1_text)) > 0) df <- df[-grep(" NA ",df$Q1_text),]
if (length(grep(" NA ",df$Q2_text)) > 0) df <- df[-grep(" NA ",df$Q2_text),]
if (length(grep(" NA ",df$Q3_text)) > 0) df <- df[-grep(" NA ",df$Q3_text),]

#trim df down to text that has a Q1 code
df <- df[!is.na(df$Q1_code),]

#replace "NA" Q2 and Q3 text with a whitespace
df$Q2_text[is.na(df$Q2_text)] <- " "
df$Q3_text[is.na(df$Q3_text)] <- " "

# re-code text into new categories
df$Q1_code[df$Q1_code==3 | df$Q1_code==4 | df$Q1_code==5 | df$Q1_code==6 | df$Q1_code==7] <- 2
df$Q1_code[df$Q1_code==8 | df$Q1_code==9] <- 3

# amalgamate text
df <- data.frame(df,Q123_text=paste(df$Q1_text, df$Q2_text, df$Q3_text, sep=""))

# AMALGAMATED TEXT
doc_matrix <- create_matrix(df$Q123_text, language="english", removeNumbers=TRUE, stemWords=TRUE, removeSparseTerms = .4)
# Q1 TEXT ONLY
#doc_matrix <- create_matrix(df$Q1_text, language="english", removeNumbers=TRUE, stemWords=TRUE, removeSparseTerms = .4)


#build a stratified training set (need indices only, hence match back to full data set)
strat <- stratified(df,"Q1_code",0.8)
train_samp <- match(strat$Response.ID,df$Response.ID)
test_samp <- seq(1,nrow(df))[-train_samp]

# Make container
container <- create_container(doc_matrix, df$Q1_code, trainSize=train_samp, testSize=test_samp, virgin=FALSE)

#train models
SVM <- train_model(container, "SVM")
GLMNET <- train_model(container, "GLMNET") #THIS FALLS DOWN
MAXENT <- train_model(container, "MAXENT")
SLDA <- train_model(container, "SLDA")
RF <- train_model(container, "RF")
BOOSTING <- train_model(container, "BOOSTING")
NNET <- train_model(container, "NNET")
TREE <- train_model(container, "TREE")
BAGGING <- train_model(container, "BAGGING")

# classify models
SVM_CLASS <- classify_model(container, SVM)
#GLMNET_CLASS <- classify_model(container, GLMNET)
SLDA_CLASS <- classify_model(container, SLDA) # THIS PRODUCES AN ERROR on Q1 text alone, but not on amalgamated Q123 text
MAXENT_CLASS <- classify_model(container, MAXENT)
RF_CLASS <- classify_model(container, RF)
BOOSTING_CLASS <- classify_model(container, BOOSTING)
NNET_CLASS <- classify_model(container, NNET)
TREE_CLASS <- classify_model(container, TREE)
BAGGING_CLASS <- classify_model(container, BAGGING)

# only 4 algorithms make it through the classification stage. Produce analytics on these...

# create analytics
analytics <- create_analytics(container, cbind(SVM_CLASS, MAXENT_CLASS, RF_CLASS, BOOSTING_CLASS))
summary(analytics)

# write summary info to data frame
topic_summary <- analytics@label_summary
alg_summary <- analytics@algorithm_summary
ens_summary <-analytics@ensemble_summary
doc_summary <- analytics@document_summary

# cross validate to identify best ensemble algorithms
#SVM_CV <- cross_validate(container, 4, "SVM")
#GLMNET_CV <- cross_validate(container, 4, "GLMNET")
#SLDA_CV <- cross_validate(container, 4, "SLDA")
#MAXENT_CV <- cross_validate(container, 4, "MAXENT")
#RF_CV <- cross_validate(container, 4, "RF")
#BOOSTING_CV <- cross_validate(container, 4, "BOOSTING")



