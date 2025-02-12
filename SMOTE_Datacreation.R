# Load necessary libraries
library(UBL)
library(dplyr)

# Load and preprocess dataset
df <- read.csv("data/ready_data") # Adjust path as necessary
df <- df %>% select(-X) # Ensure 'X' column is removed if not needed
df <- df %>% mutate_if(is.character, as.factor)


# Define relevance function (Ensure alignment with target variable range)
myrel <- matrix(
  c(0, 0.1, 0,
    1, 0.5, 0,
    2, 1, 0), 
  ncol = 3, byrow = TRUE) 



# Check the structure of the dataset
str(df)
summary(df)

# Apply SMOTE for regression
synthetic_data <- SmoteRegress(
  SCHADENAUFWAND_KUM_H ~ ., 
  df, 
  dist = "HEOM",
  rel = myrel, 
  thr.rel = 0.5, 
  C.perc = list(0.8, 7)  # Matching the simplified relevance levels
)
write.csv(synthetic_data, "smote_data_2", row.names = FALSE)

