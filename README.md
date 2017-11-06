# Segmenting Adults by Income Using 1994 Census Data
Author:   [Jaleel Walter Henry Savoy](mailto:jaleelwsavoy@outlook.com)

Date:     10/22/2017

Language: R

Source: UCI Machine Learning Repository (https://archive.ics.uci.edu/ml/datasets/adult)

Donor: 

- Ronny Kohavi and Barry Becker 
- Data Mining and Visualization 
- Silicon Graphics. 


Data Set Information:

Extraction was done by Barry Becker from the 1994 Census database. A set of reasonably clean records was extracted using the following conditions: ((AAGE>16) && (AGI>100) && (AFNLWGT>1)&& (HRSWK>0)) 

Prediction task is to determine whether a person makes over 50K a year and which people are more likely to make over 50K a year.

# Required Packages
* library(rpart)
* library(e1071)
* library(rpart.plot)
* library(caret)
* library(caTools)
* library(ggplot2)

# Problem Statement
I want to apply analytic methods and machine learning tools to the Adult 1994 Income Census dataset. The specific goal is to gain insights in the 1994 census data on adult income in America, while creating a model that can accurately (greater than 75%) and precisely (greater than 70%) classify adults into earners of greater than 50K. 

The ability to segment adults based on income using easily attainable features is useful and interesting; an accurate model to segment adults based on income could be used to: identify societal areas of improvement, develop marketing strategies, identify target markets, and more. 

# Approach
Since I was segmenting the adults into those that earn greater than 50K and those that did not, I decided to use recursive partitioning for classification. The recursive partitioning model was made using Income as the response variable; the explanatory variables were: Age, Sex, Hour Per Week, Education Number (years), Highest Education, Work Class, Race, Occupation, Martial Status, Relationship, Capital Gain, Capital Loss, and Native Country. All features of the dataset, except for Sampling Weight, were used for the model. The model had a recursive partitioning control minimum-split of 10.

# Results and Evaluation
The model was able to reach the goals of greater than 75% accuracy and greater than 70% precision on the first iteration; the model had an accuracy of 84.25% and precision of 75%. At 50.36%, the recall could be improved; there were nearly as many false negatives as there were false positives. The second iteration of the model only included significant explanatory that were strongly correlated to the response variable. 

The model's second iteration used:  Age, Work_Class, Education_Num, Relationship, Race, Sex, Capital Gain, Capital Loss, and Hours Per Week. The accuracy increased slightly to 84.70%, the precision slightly decreased to 75.73%, and recall increased to 53.67%. The model is sufficient, but there is clearly room for improvement.

# Limitations
*1) 
