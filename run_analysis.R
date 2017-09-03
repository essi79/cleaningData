library(dplyr)

trainingFilePath = "UCI HAR Dataset/train/X_train.txt"
trainingLabelsFilePath = "UCI HAR Dataset/train/y_train.txt"
testFilePath ="UCI HAR Dataset/test/X_test.txt"
testLabelsFilePath = "UCI HAR Dataset/test/y_test.txt"
featureLabelsFilePath = "UCI HAR Dataset/features.txt"
trainSubjectsFilePath = "UCI HAR Dataset/train/subject_train.txt"
testSubjectsFilePath = "UCI HAR Dataset/test/subject_test.txt"
activitiesFilePath = "UCI HAR Dataset/activity_labels.txt"

trainingData <- read.table(trainingFilePath, sep="", header=FALSE, stringsAsFactors = FALSE)
trainingLabels <- read.table(trainingLabelsFilePath, sep="", header=FALSE, stringsAsFactors = FALSE)
testData <- read.table(testFilePath, sep="", header=FALSE, stringsAsFactors = FALSE)
testLabels <- read.table(testLabelsFilePath, sep="", header=FALSE, stringsAsFactors = FALSE)
featureLabels <- read.table(featureLabelsFilePath, sep="", header=FALSE, stringsAsFactors = FALSE)
testSubjects <- read.table(testSubjectsFilePath, sep="", header=FALSE, stringsAsFactors = FALSE)
trainingSubjects <- read.table(trainSubjectsFilePath, sep="", header=FALSE, stringsAsFactors = FALSE)
activities <- read.table(activitiesFilePath, sep="", header=FALSE, stringsAsFactors = FALSE)

names(trainingSubjects) <- "subject"
names(testSubjects) <- "subject"
names(trainingLabels) <- "activityCode"
names(testLabels) <- "activityCode"
names(featureLabels) <- c("rowID","featureName")
featureLabels <- mutate(featureLabels,fullFeatureName=paste(rowID,featureName))
names(trainingData) <- featureLabels$fullFeatureName
names(testData) <- featureLabels$fullFeatureName
names(activities) <- c("activityCode", "activityDesc")

trainingLabels <- merge(trainingLabels, activities, by.x="activityCode", by.y = "activityCode", sort = FALSE)
testLabels <- merge(testLabels, activities, by.x="activityCode", by.y = "activityCode", sort = FALSE)

trainingLabels <- select(trainingLabels,activityDesc)
testLabels <- select(testLabels, activityDesc)

trainingData <- mutate(trainingData,obsType = "training")
testData <- mutate(testData, obsType = "test")

trainingData <- cbind(trainingLabels, trainingData)
testData <- cbind(testLabels, testData)

trainingData <- cbind(trainingSubjects, trainingData)
testData <- cbind(testSubjects, testData)

allData <- rbind(trainingData, testData)

allData <- select(allData, subject, activityDesc, obsType, grep("mean|std",names(allData)))

groupedData <- group_by(allData, subject, activityDesc, obsType)

featureMeansBySubjectActivity <- summarize_each(groupedData,funs(mean))
          
write.table(featureMeansBySubjectActivity,file="tidyData.txt",row.names= FALSE)
