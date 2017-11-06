###################Set Up#####################################################



set.seed(123)
setwd("C:/Users/jalee/Desktop/Machine Learning Course")
library(rpart)
library(caTools)
library(e1071)
library(rpart.plot)
library(ggplot2)
library(Hmisc)
library(usdm)

##Load Data##
df <- read.csv("adult.csv", header = F)
#Rename features for simplicity
colnames(df) <- c("Age", "Work_Class", "Sampling_Weight", "Highest_Education", "Education_Num", 
                  "Martial_Status", "Occupation", "Relationship", "Race", "Sex", "Cap_Gain", "Cap_Loss",
                  "Hours_Per_Week", "Native_Country", "Income")



#####################INITIAL, SIMPLE DATA EXPLORATION########################################



###Age
sum(is.na(df$Age)) #none

summary(df$Age)
hist(df$Age)
#
#   Min: 17.00  1st Qu: 28.00  Median: 37.00   
#   Mean:  38.58     3rd Qu: 48.00    Max:90.00 
#                  
#   data skewed right slightly, 75% of adults in dataset are younger than 48yrs old
#   50% of adults in data set lie between 28yrs old and 48yrs old
#   age data has a range of 73 years

###Work Class
str(df$Work_Class)
summary(df$Work_Class)
barchart(df$Work_Class)

ggplot(data = df) +
  geom_bar(mapping = aes(x = df$Work_Class))

#
# Never-worked: 7
# Without-pay: 14
# Might be able to leave those 21 datapoints out
# Most people work for private corporations, followed by self employed (not incorporated), then
# local government, then unknown, then state government, then self employed (incorporated), then
# federal gov, and lastly by without pay and never worked
#

###Race
summary(df$Race)

ggplot(data = df) +
  geom_bar(mapping = aes(x = df$Race))

ggplot(df, aes(x = df$Race)) +  
  geom_bar(aes(y = (..count..)/sum(..count..)))

# White: ~85.43%
27816/32561

# Black: ~9.6% 
3124/32561

# American-Indian-Eskimo: ~0.96%
311/32561

# Asian-Pacific-Island: ~3.2%
1039/32561

# Other: ~0.8%
271/32561

# The data is pretty representative of the US population (using 2010 Census data)
# White 2010 Census:                       ~72.4%
# Black 2010 Census:                       ~12.6%
# Asian 2010 Census:                        ~4.8%
# Native American/Alaskan Natives:          ~0.9%
# Native Hawaiians/Other Pacific Islanders: ~0.2%
# Two or More races:                        ~2.9%
# Some other race:                          ~6.2%

###Sex
summary(df$Sex)
ggplot(data = df) +
  geom_bar(mapping = aes(x = df$Sex))

ggplot(df, aes(x = df$Sex)) +  
  geom_bar(aes(y = (..count..)/sum(..count..)))

#female: ~33.1%
10771/32561
#male: ~66.9% 
21790/32561

# The data is disproportionately male
# According the Bureau of Labor Statistics, the workforce is 47% female and 53% male


###Hours
summary(df$Hours_Per_Week)
ggplot() +
  geom_histogram(mapping = aes(x = df$Hours_Per_Week), data = df, stat = "bin",
                 binwidth = 10, bins = 6
                 )
#   Min: 1.00  1st Qu: 40.00  Median: 40.00  
#   Mean:  40.44     3rd Qu: 45.00    Max:99.00 
#   Data is slightly skewed right, and there are some extreme outliers
#   Most people work less than 50 hours a week
#   75% of people work between 40 and 45 hours a week
#   25% of adults in the dataset work between 1 and 40 hours a week
#   Interestingly, adults that have reported never working, also reported working
#     for some hours **s

###Native Country
summary(df$Native_Country)
country_count <- data.frame(Name = df$Native_Country)
summary(country_count)

# Top three countries by frequency:
#   USA     :      29170 (~89.6%)
#   Mexico  :        643 (`2.00%)
#   Unknown :        582 (~1.8%)
#   Other   :       2165 (~6.65%)


###QUICK RECAP USING DESCRIB(), HEAD(), SUMMARY(), AND STR()
head(df)
str(df)
summary(df)
describe(df)
# Most people (75%) make less than or equal to 50K USD annually 



#############################Relationships Between Variables###################



#totals 
sum(df$Income==" >50K") #7841
# 24.1% of adults make more than 50K USD

#Race -- White
sum(df$Race==" White") #27816
sum(df$Income==" >50K" & df$Race==" White") #7117
sum(df$Income==" >50K" & df$Race!=" White") #724
sum(df$Income==" <=50K" & df$Race==" White") #20699
# White adults make up 90.77% of adults making more than 50K USD
# Non-white adults make up 9.23% of adults making more than 50K USD
# 25.6% of White adults make more than 50K USD

#Race -- Black
sum(df$Race==" Black") #3124
sum(df$Income==" >50K" & df$Race==" Black") #387
sum(df$Income==" >50K" & df$Race!=" Black") #7454
sum(df$Income==" <=50K" & df$Race==" Black") #2737
# Black adults make up 5% of adults making more than 50K USD
# 4.95% of Black adults make more than 50K USD


#Race -- Amer-Indian-Eskimo
sum(df$Race==" Amer-Indian-Eskimo") #311
sum(df$Income==" >50K" & df$Race==" Amer-Indian-Eskimo") #36
sum(df$Income==" >50K" & df$Race!=" Amer-Indian-Eskimo") #7805
sum(df$Income==" <=50K" & df$Race==" Amer-Indian-Eskimo") #275
# Amer-Indian-Eskimo adults make up 0.5% of adults making more than 50K USD
# 11.6% of Amer-Indian-Eskimo adults make more than 50K USD

#Race -- Amer-Indian-Eskimo
sum(df$Race==" Asian-Pac-Islander") #1039
sum(df$Income==" >50K" & df$Race==" Asian-Pac-Islander") #276
sum(df$Income==" >50K" & df$Race!=" Asian-Pac-Islander") #7565
sum(df$Income==" <=50K" & df$Race==" Asian-Pac-Islander") #763
# Asian-Pac-Islander adults make up 3.5% of adults making more than 50K USD
# 26.56% of Asian-Pac-Islander adults make more than 50K USD

#Race -- Other
sum(df$Race==" Other") #271
sum(df$Income==" >50K" & df$Race==" Other") #25
sum(df$Income==" >50K" & df$Race!=" Other") #7816
sum(df$Income==" <=50K" & df$Race==" Other") #246
# Adults of Other race make up 0.03% of adults making more than 50K USD
# 10.16% of Other adults make more than 50K USD


#Sex -- Male
sum(df$Sex==" Male") #21790
sum(df$Sex==" Male" & df$Income==" >50K") #6662
sum(df$Sex==" Male" & df$Income!=" >50K") #15128
# 30.6% of Male adults make more than 50K USD annually
# 85% of adults making more than 50K USD annually are Male

#Sex == Female
sum(df$Sex==" Female") #10771
sum(df$Sex==" Female" & df$Income==" >50K") #1179
sum(df$Sex==" Female" & df$Income!=" >50K") #9592
# 11% of Female adults make more than 50K USD annually
# 15% of adults making more than 50K USD annually are Female

#Sex -- Male AND Race -- White AND 
sum(df$Sex==" Female" & df$Race==" White" & df$Income ==" >50K") #1028
sum(df$Sex==" Male" & df$Race==" White" & df$Income ==" >50K") #6089
# 13.11% of adults making more than 50K USD annually are White Females
# 77.66% of adults making more than 50K USD annually are White Males
# 85.6% of White adults making more than 50K USD annually are Males

sum(df$Sex==" Female" & df$Race==" Black" & df$Income ==" >50K") #90
sum(df$Sex==" Male" & df$Race==" Black" & df$Income ==" >50K") #297
# 1.15% of adults making more than 50K USD annually are Black Females
# 3.79% of adults making more than 50K USD annually are Black Males
# 76.75% of Black adults making more than 50K USD annually are Males

sum(df$Sex==" Female" & df$Race==" Asian-Pac-Islander" & df$Income ==" >50K") #43
sum(df$Sex==" Male" & df$Race==" Asian-Pac-Islander" & df$Income ==" >50K") #233
# 0.5% of adults making more than 50K USD annually are Asian/Pacific Islander Females
# 2.97% of adults making more than 50K USD annually are Asian/Pacific Islander Males
# 84.42% of Asian adults making more than 50K USD annually are Male

sum(df$Sex==" Female" & df$Race==" Amer-Indian-Eskimo" & df$Income ==" >50K") #12
sum(df$Sex==" Male" & df$Race==" Amer-Indian-Eskimo" & df$Income ==" >50K") #24
# 0.15% of adults making more than 50K USD annually are Female American-Indian/Eskimo
# 0.30% of adults making more than 50K USD annually are Male American-Indian/Eskimo 
# 92.31% of American-Indian/Eskimo adults making more than 50K USD annually are Male


# Workclass -- Private
sum(df$Income==" >50K" & df$Work_Class==" Private") #4963
# 63.29% of adults making more than 50K USD annually are in the private workclass  

# Workclass -- State-gov
sum(df$Income==" >50K" & df$Work_Class==" State-gov") #353
# 4.5% of adults making more than 50K USD annually work for the state government

# Workclass -- Self-emp-not-inc
sum(df$Income==" >50K" & df$Work_Class==" Self-emp-not-inc") #724
# 9.23% of adults making more than 50K USD annually are self-employed (not incorporated)

# Workclass -- Self-emp-inc
sum(df$Income==" >50K" & df$Work_Class==" Self-emp-inc") #622
# 8% of adults making more than 50K USD annually are self-employed (incorporated)

# Workclass -- Federal
sum(df$Income==" >50K" & df$Work_Class==" Federal-gov") #371
# 4.73% of adults making more than 50K USD annually work for the federal government

# Workclass -- ?
sum(df$Income==" >50K" & df$Work_Class==" ?") #191
# 2.44% of adults making more than 50K USD annually work in unknown workclasses

#QUICK RECAP USING XTABS()
# two-way contingency tables using Income and Workclass
xtabs( ~df$Income + df$Work_Class, data = df)
# more self-employed-inc adults make greater than 50K USD, than those that do not 

# two-way contigency table using Income and Sex
xtabs( ~df$Income + df$Sex, data = df)
# more Males make greater than 50K USD than Females

xtabs( ~df$Income + df$Highest_Education, data = df)
# adults with higher levels of education correspond with more making greater than 50K USD annually



################Clean and Separate Data#################



# Separate the response variable from the explanatory variables
# Factor as numeric
df_clean <- df
df_clean_numeric <- df

#converting variables to numerics
for (i in 1:15) {
  if(class(df_clean_numeric[,i])=="factor"){
    df_clean_numeric[,i] <- as.numeric(df_clean_numeric[,i])
  }
}

#encoding the target feature as factor of 0 or 1
df_clean_numeric$Income <- df_clean_numeric$Income - 1

split = sample.split(df_clean$Income, SplitRatio = 0.75)
train_set <- subset(df_clean, split == TRUE)
test_set <- subset(df_clean, split == FALSE)

split = sample.split(df_clean_numeric$Income, SplitRatio = 0.75)
train_numeric <- subset(df_clean_numeric, split == TRUE)
test_numeric <- subset(df_clean_numeric, split == FALSE)

y <- as.integer(train_numeric$Income)



#############################Model Building###################
#outlier detection
sapply(train_numeric[,], function(x) quantile(x, c(.01,.05,.25,.5,.75,.90,.95, .99, 1),na.rm=TRUE) )
    #no significant effect from outliers 

#missing value detection
sapply(train_set, function(x) sum(is.na(x)) )
    #no NA values

# correlation and VIF
correlation_table <- cor(train_numeric[,1:14])
correlation_table2 <- cor(train_numeric[,1:15])
correlation_table <- (correlation_table*100)
correlation_tableDF <- as.data.frame(correlation_table)
correlation_tableDFLogical <- correlation_tableDF > 5 | correlation_tableDF < -5
  #correlations greater than 5/100 or -5/100
  #Age: martial status, relationship, sex, cap gain, cap loss, hours per week
  #Workclass: martial status, relationship, sex, race, hours per week, occupation, education num
  #highest education: native country, hours per week, education num
  #education number: native country, hours per week, education num, cap gain, cap loss, occupation, work class, relationship, martial status
  #martial status: sex, age, race, hours per week, education num, relationship, workclass
  #occupation: sex, workclass, hours per week, education num, relationship
  #relationship: Age, Work_Class, Education_Num, Martial_Status, Occupation, Relationship, Race, Sex, Cap_Gain, Cap_Loss, Hours_Per_Week
  #race: relationship, workclass, sex, martial status
  #sex: age, workclass, hours per week, race, martial status, relationship, occupation
  #cap gain: hours per week, relationship, education num, age
  #cap loss: hours per week, relationship, education num, age
  #hours per week: Age, Work_Class, Education_Num, Martial_Status, Occupation, Relationship, highest education, Sex, Cap_Gain, Cap_Loss, Hours_Per_Week
  #native country: race, highest education

  #most strongly correlated with income: sex, education num, age, hours per week, cap gain, cap loss

vifDF <- as.data.frame(vif(train_numeric[,1:14]))
vifDF 
###Highest variance-inflation factors
#	Relationship: 1.720860
# Sex:          1.552166
#Education_Num: 1.250295

test_set$Income <- (test_set$Income==" >50K")
test_set$Income <- as.integer(test_set$Income)

regressor1 <- rpart(formula = Income ~ Age + Work_Class + Highest_Education +
                      Education_Num + Martial_Status + Occupation + Relationship +
                      Race + Sex + Cap_Gain + Cap_Loss + Hours_Per_Week + Native_Country,
                   data = train_set,
                   control = rpart.control(minsplit = 10))

y_pred <- predict(regressor1, test_set)
y_pred <- round(y_pred)

predictions <- as.data.frame(y_pred)
predictions$` <=50K`<- NULL

confusionMatrix(test_set$Income, predictions$` >50K`)

#or you can manually do it
sum(predictions$` >50K`== test_set$Income)          #6858 correct out of 8140 84.25% accurate
sum(predictions$` >50K`== 1 & test_set$Income == 1) #987 correct positives
sum(predictions$` >50K`== 1 & test_set$Income == 0) #309/8140 false positives 3.8%
                                                    #987/(987+309) precision of 76.15%
sum(predictions$` >50K`== 0 & test_set$Income == 1) #973/8149 false negatives 11.94%
                                                    #987/(987+973) recall of 50.36%


#prediction (horizontal) by reference (vertical)
#    0     1
# 0 6858  309
# 1  973  987


#########attempt at improving the model with feature selection
regressor1 <- rpart(formula = Income ~ Age + Work_Class +
                      Education_Num + Relationship +
                      Race + Sex + Cap_Gain + Cap_Loss + Hours_Per_Week,
                    data = train_set,
                    control = rpart.control(minsplit = 10))

y_pred <- predict(regressor1, test_set)
y_pred <- round(y_pred)

predictions <- as.data.frame(y_pred)
predictions$` <=50K`<- NULL

confusionMatrix(test_set$Income, predictions$` >50K`)

#or you can manually do it
sum(predictions$` >50K`== test_set$Income)          #6895/8140 correct out of 8140 84.70% accurate

sum(predictions$` >50K`== 1 & test_set$Income == 1) #1052 correct positives

sum(predictions$` >50K`== 1 & test_set$Income == 0) #337/8140 false positives 3.8%
                                                    #1054/(1054+337) precision of 75.73%
sum(predictions$` >50K`== 0 & test_set$Income == 1) #908/8149 false negatives 11.1%
                                                    #1052/(1052+908) recall of 53.67%

#prediction (horizontal) by reference (vertical)
#    0     1
# 0 6895  337
# 1  908  1052

# Slight decrease in precision, slight increase in recall, and slight increase in accuracy; this model is roughly the same in performance as the first model