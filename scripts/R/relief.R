 # args -> [file, database, bin number (1...x=C1/C2)]
 # ex. -> $ Rscript scripts/R/relief.R yeast6 boundary

 # load libraries
library("mongolite")
library("CORElearn")

boundary = 0.06

 # initial variables
args = commandArgs()
db.name = args[6]
if (!is.na(args[7])) {
	boundary = as.numeric(args[7])
}

 # open mongo connection
collname = paste(db.name, sep="")
conn = mongo(collname, db.name)
alldata = conn$find()

output = attrEval(names(alldata[length(alldata)]), alldata, estimator="Relief", ReliefIterations=300)

output

fileBoundary <- read.table(text="filename       boundary",header=TRUE)
dir.create(paste("datasets/final/relief/", db.name, "/", sep=""), showWarnings = FALSE)

for (y in 1:length(output)) {
	newdata = alldata
	counter = 0

	#remove negligible columns
	for (x in 1:length(output)) {
		if (abs(as.double(output[[x]])) <= abs(as.double(output[[y]]) )) {
			  counter=counter+1
				newdata = newdata[ , !(names(newdata) %in% names(output[x]))]
		}
	}

  datasetfilename = paste(db.name, counter, sep="_")
	fileBoundary <- rbind(fileBoundary, data.frame(filename = datasetfilename, boundary = abs(output[[y]])))
	write.csv(newdata, paste("datasets/final/relief/", db.name, "/", datasetfilename, ".csv", sep=""), row.names=F, quote = FALSE)
}

write.csv(fileBoundary, paste("datasets/final/relief/",db.name, "/", db.name, "_boundary.csv", sep=""), row.names=F, quote = FALSE)
# close mongo connection
rm(conn)
