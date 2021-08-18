require(tidyverse)

####Read Extracurricular Activities Data
activities17 <- read_csv("data_raw/extra_curricular_activities_certified_2016-17.csv")

#Subset to Racine
activities17 <- subset(activities17, COUNTY == "Racine")

summary(activities17)
View(activities17)

#Split into district and school levels
activities17_dist <- subset(activities17, AGENCY_TYPE == "School District")
activities17 <- subset(activities17, AGENCY_TYPE != "School District")


#Convert Char -> Factor for first 11 rows
activities17[,c(1:11)] <- lapply(activities17[,c(1:11)], as.factor)

summary(activities17)

#Convert Char -> Double for last column
activities17$PARTICIPATION_RATE <- as.numeric(activities17$PARTICIPATION_RATE)

#Remove NAs - where Fall Enrollment == 0 (Why is this???)
View(subset(activities17, is.na(PARTICIPATION_RATE)))
table(activities17$GRADE_GROUP, activities17$FALL_ENROLLMENT_GRADE_6_12) ##confirms that all 84 NAs are Elementary Schools, where enrollment 6_12 == 0

activities17 <- subset(activities17, FALL_ENROLLMENT_GRADE_6_12 != 0)

####Read Truancy Data
truancy17 <- read_csv("data_raw/habitual_truancy_certified_2016-17.csv")

#Subset to Racine
truancy17 <- subset(truancy17, COUNTY == "Racine")

summary(truancy17)
View(truancy17)

#Split into district and school levels
truancy17_dist <- subset(truancy17, AGENCY_TYPE == "School District")
truancy17 <- subset(truancy17, AGENCY_TYPE != "School District")

#Convert Char -> Factor for first 12 rows
truancy17[,c(1:12)] <- lapply(truancy17[,c(1:12)], as.factor)

summary(truancy17)

#convert last column to numeric:
truancy17$STUDENTS_HABITUALLY_TRUANT <- as.numeric(truancy17$STUDENTS_HABITUALLY_TRUANT)
##leave NAs until post-merge

####Merge by school code
##Goal - keep all records by subgroups in truancy, but drop any schools not contained in activities

#Get list of activities school codes

schoolcodes <- unique(activities17$SCHOOL_CODE)
schoolnames <- unique(activities17$SCHOOL_NAME)
View(schoolcodes)
View(schoolnames)

##There are 20 unique school codes, 32 unique school names (in subsetted activities dataset). Not sure why.
##Originally 47 codes, 60 school names, for both truancy and activities.

##To simplify, let's just stick with school totals, drop disaggregated data for now

truancy17 = subset(truancy17, GROUP_BY == "All Students")
##drop rows that are redundant after the merge:

truancy17 = truancy17[,c(5, 6, 9, 10, 13:15)]

View(truancy17)
summary(truancy17)

##Merge, keeping all activities records, dropping truancy records w/ no corresponding activities data.
##Cannot merge by school code - these do not match school names.

complete <- merge(activities17, truancy17, by = "SCHOOL_NAME", all.x = T)
#School Names worked fine...

View(complete)
summary(complete)

##fix truancy rate again:
complete$TRUANCY_RATE <- as.numeric(complete$TRUANCY_RATE)

summary(complete)
View(subset(complete, is.na(TRUANCY_RATE)))
##unclear why truancy rates are missing for 21 NAs. Probably best to leave these out of scatter for now.

write_csv(complete, "data_tidy/complete.csv")




