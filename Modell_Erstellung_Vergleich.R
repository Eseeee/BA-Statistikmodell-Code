# Load necessary libraries
library(caret)
library(rpart)
library(nnet)
library(gamlss)
library(tabnet)
library(randomForest)
library(dplyr)
library(torch)

if (!torch::torch_is_installed()) {
  install_torch()
}

# Load data
fdata <- read.csv("data/ready_data")
fdata <- fdata %>% select(-X)
fdata <- fdata %>%
  mutate_if(is.character, as.factor)

# Define evaluation function (ChatGPT (2024): “i have a model and several others, i want them to be executed 15 times and to compare them with the evaluate model function, which gives us the RSME, MAE and the R²” ChatGPT, <13> <11>, OpenAI, URL: chat.openai.com)
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

print("Data done")

# Initialize results file
output_file <- "model_metrics_noX_no_seed.csv"
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

# Random Forest Model
start_time <- proc.time()
rf_model <- randomForest(SCHADENAUFWAND_KUM_H ~ ., data = train_set, ntree = 100, mtry = 3)
rf_predict <- predict(rf_model, newdata = test_set)
rf_metrics <- evaluate_model(actuals, rf_predict)
rf_time <- proc.time() - start_time

rf_results <- data.frame(
  Model = "RandomForest",
  RMSE = rf_metrics$RMSE,
  MAE = rf_metrics$MAE,
  R2 = rf_metrics$R2,
  Runtime = rf_time["elapsed"]
)
write.table(rf_results, file = output_file, sep = ",", row.names = FALSE, col.names = FALSE, append = TRUE)
print(paste("RandomForest completed in", round(rf_time["elapsed"], 2), "seconds"))

# Decision Tree
start_time <- proc.time()
tree_model <- rpart(SCHADENAUFWAND_KUM_H ~ ., data = train_set, method = "anova",
                    control = rpart.control(minsplit = 50, cp = 0.01, maxdepth = 5))
tree_predict <- predict(tree_model, newdata = test_set)
decisiontree_metrics <- evaluate_model(actuals, tree_predict)
tree_time <- proc.time() - start_time

tree_results <- data.frame(
  Model = "DecisionTree",
  RMSE = decisiontree_metrics$RMSE,
  MAE = decisiontree_metrics$MAE,
  R2 = decisiontree_metrics$R2,
  Runtime = tree_time["elapsed"]
)
write.table(tree_results, file = output_file, sep = ",", row.names = FALSE, col.names = FALSE, append = TRUE)
print(paste("DecisionTree completed in", round(tree_time["elapsed"], 2), "seconds"))

# TabNet Model
start_time <- proc.time()
tab_model <- tabnet_fit(
  SCHADENAUFWAND_KUM_H ~ .,       
  data = train_set, 
  epochs = 10,       
  batch_size = 32,   
  virtual_batch_size = 8 
)
tab_predict <- unlist(predict(tab_model, test_set))
tab_metrics <- evaluate_model(actuals, tab_predict)
tab_time <- proc.time() - start_time

tab_results <- data.frame(
  Model = "TabNet",
  RMSE = tab_metrics$RMSE,
  MAE = tab_metrics$MAE,
  R2 = tab_metrics$R2,
  Runtime = tab_time["elapsed"]
)
write.table(tab_results, file = output_file, sep = ",", row.names = FALSE, col.names = FALSE, append = TRUE)
print(paste("TabNet completed in", round(tab_time["elapsed"], 2), "seconds"))

# GAMLSS Model
start_time <- proc.time()
GAMLSS_model <- gamlss(SCHADENAUFWAND_KUM_H ~ FZGALTER + REGION + MARKE_NEU + SF_KLASSE + KWsec + Alter, 
                       data = train_set, family = ZAGA)
GAMLSS_predict <- predict(GAMLSS_model, newdata = test_set, what = "mu", type = "response")
GAMLSS_metrics <- evaluate_model(actuals, GAMLSS_predict)
GAMLSS_time <- proc.time() - start_time

GAMLSS_results <- data.frame(
  Model = "GAMLSS",
  RMSE = GAMLSS_metrics$RMSE,
  MAE = GAMLSS_metrics$MAE,
  R2 = GAMLSS_metrics$R2,
  Runtime = GAMLSS_time["elapsed"]
)
write.table(GAMLSS_results, file = output_file, sep = ",", row.names = FALSE, col.names = FALSE, append = TRUE)
print(paste("GAMLSS completed in", round(GAMLSS_time["elapsed"], 2), "seconds"))

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

print("Metrics saved to model_metrics_noX_no_seed.csv")
