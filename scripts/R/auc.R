# args -> [file, database, source]
 # ex. -> $ Rscript scripts/R/ensemble.R yeast6 ens_1

 # load libraries
library("mongolite")
library("ROCR")

 # initial variables
args = commandArgs()
db.name = args[6];
db.collection_name = args[7];
doc.name = args[8];
conn = mongo(paste(db.collection_name, "_test", sep=""), db.name)
testdata = conn$find()
conn = mongo(doc.name, db.name)
ens = conn$find()

 # Confidence
Conf <- function(data, prob) {
   result = data.frame()
   labels = as.numeric(as.factor(data[, ncol(data)]))-1
   for (x in 1:nrow(data)) {
      if (!is.vector(prob)) result = rbind(result, c(as.numeric(prob[x, 2]), labels[x]))
      if (is.vector(prob)) result = rbind(result, c(as.numeric(prob[x]), labels[x]))
   }
   return(result)
}

 # compute AUC
conf = Conf(testdata, ens)
pred = prediction(conf[, 1], conf[, 2])
perf = performance(pred, "auc")

auc = matrix(nrow = 1, ncol = 2)
colnames(auc) = c("Method", "AUC")
doc.namex = ""
if (doc.name == "ens_1") doc.namex = "SplitBal"
if (doc.name == "edbc") doc.namex = "EDBC"
auc[1, 1] = doc.namex
auc[1, 2] = as.numeric(slot(perf, "y.values")[1])

 # return result
conn = mongo(paste("auc", db.collection_name, doc.name, sep="_"), db.name)
if (conn$count() > 0) conn$drop()
conn$insert(as.data.frame(auc))

 # close mongo connection
rm(conn)
