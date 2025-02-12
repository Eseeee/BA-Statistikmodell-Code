library(caret)
library(nnet)
library(dplyr)


# Load data
fdata <- read.csv("data/smote_data_2")
summary(fdata)
fdata <- fdata %>%
  mutate_if(is.character, as.factor)

# Define evaluation function
evaluate_model <- function(actual, predicted) {
  rmse <- sqrt(mean((actual - predicted)^2))
  mae <- mean(abs(actual - predicted))
  r2 <- cor(actual, predicted)^2
  return(list(RMSE = rmse, MAE = mae, R2 = r2))
}
# Split data into training and testing sets
index <- createDataPartition(fdata$SCHADENAUFWAND_KUM_H, p = 0.8, list = FALSE)
train_set <- fdata[index, ]
test_set <- fdata[-index, ]
actuals <- test_set$SCHADENAUFWAND_KUM_H

# Initialize results file
output_file <- "smotecomparison.csv"
if (!file.exists(output_file)) {
  write.csv(data.frame(Model = character(), RMSE = numeric(), MAE = numeric(), R2 = numeric(), Runtime = numeric(), stringsAsFactors = FALSE), 
            file = output_file, row.names = FALSE)
}

# GLM Model
start_time <- proc.time()
glm_model <- glm(SCHADENAUFWAND_KUM_H ~ ., family = gaussian, data = train_set)
glm_predict <- predict(glm_model, newdata = test_set, type = "response")
glm_metrics <- evaluate_model(actuals, glm_predict)
glm_time <- proc.time() - start_time

glm_results <- data.frame(
  Model = "GLM",
  RMSE = glm_metrics$RMSE,
  MAE = glm_metrics$MAE,
  R2 = glm_metrics$R2,
  Runtime = glm_time["elapsed"]
)
write.table(glm_results, file = output_file, sep = ",", row.names = FALSE, col.names = FALSE, append = TRUE)
print(paste("GLM completed in", round(glm_time["elapsed"], 2), "seconds"))



# Neural Network Model
start_time <- proc.time()
nn_model <- nnet(SCHADENAUFWAND_KUM_H ~ ., data = train_set, size = 5, linout = TRUE, maxit = 500, trace = FALSE)
nn_predict <- predict(nn_model, test_set)
nn_metrics <- evaluate_model(actuals, nn_predict)
nn_time <- proc.time() - start_time

nn_results <- data.frame(
  Model = "NeuralNetwork",
  RMSE = nn_metrics$RMSE,
  MAE = nn_metrics$MAE,
  R2 = nn_metrics$R2,
  Runtime = nn_time["elapsed"]
)
write.table(nn_results, file = output_file, sep = ",", row.names = FALSE, col.names = FALSE, append = TRUE)
print(paste("NeuralNetwork completed in", round(nn_time["elapsed"], 2), "seconds"))

print("Metrics saved to smotecomparison.csv")

