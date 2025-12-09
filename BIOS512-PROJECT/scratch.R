library(glmnet)
library(tidyverse);
library(FactoMineR);
library(Rtsne);
set.seed(242)
phish <- read_csv('~/project1/source_data/PhiUSIIL_Phishing_URL_Dataset.csv') %>% select(-FILENAME,-Title,-TLD,-URL, -Domain) %>%
  rename('SpecialCharRatioInURL' = 'SpacialCharRatioInURL')

scale <- function(a){
  (a - min(a))/(max(a)-min(a))
}

binary_columns <- c('IsDomainIP', 'HasObfuscation', 'IsHTTPS', 'HasTitle', 'HasFavicon',
                    'IsResponsive', 'HasDescription', 'HasExternalFormSubmit', 'HasSocialNet',
                    'HasSubmitButton', 'HasHiddenFields', 'HasPasswordField', 'Bank', 'Pay', 'Crypto',
                    'HasCopyrightInfo', 'Robots')

train <- runif(nrow(phish)) < 0.5
test <- !train;

train_df <- phish[train, ]
test_df <- phish[test, ]

train_df[binary_columns] <- lapply(train_df[binary_columns], factor)
test_df[binary_columns]  <- lapply(test_df[binary_columns], factor)

y_train <- as.numeric(as.character(train_df$label))
y_test  <- as.numeric(as.character(test_df$label))

x_train_raw <- train_df %>% select(-label)
x_test_raw  <- test_df  %>% select(-label)

common_cols <- intersect(names(x_train_raw), names(x_test_raw))

for (col in common_cols) {
  if (is.factor(x_train_raw[[col]])) {
    x_test_raw[[col]] <- factor(
      x_test_raw[[col]],
      levels = levels(x_train_raw[[col]])
    )
  }
}

x_test_raw <- x_test_raw[, names(x_train_raw)]

famd_model <- FAMD(x_train_raw, ncp = 20, graph = FALSE)


ncp_actual <- ncol(famd_model$ind$coord)

x_train <- as.matrix(famd_model$ind$coord[, 1:ncp_actual])

x_test <- as.matrix(predict(famd_model, x_test_raw)$coord)

cv_model <- cv.glmnet(x_train, y_train, family="binomial", alpha=0.5, nfolds = 5)

plot(cv_model)

fit <- cv_model$glmnet.fit

best_fit <- glmnet(x_train,y_train,lambda=cv_model$lambda.min)
best_fit$beta

summary(cv_model)

probs_test <- as.vector(predict(cv_model, newx = x_test, s = "lambda.min", type = "response"))
test_df <- test_df %>% mutate(phishing_prediction = probs_test)

ggplot(test_df, aes(y_test, phishing_prediction)) + geom_point() + geom_segment(aes(x=0,y=0,xend=1,yend=1))
residuals <- y_test - test_df$phishing_prediction
ggplot(test_df, aes(x = residuals, fill = factor(y_test))) + geom_density(alpha=0.4) + labs(fill = "Actual Class")
p <- test_df$phishing_prediction

deviance_resid <- ifelse(y_test == 1,
                         sqrt(-2 * log(p)),
                         -sqrt(-2 * log(1 - p))) # different way to look at residuals for model

ggplot(test_df, aes(x = deviance_resid)) +
  geom_density()

coef(cv_model, s = 'lambda.min')
train_pred <- predict(cv_model, newx=x_train, s='lambda.min', type = 'response')
test_pred <- predict(cv_model, newx=x_test, s='lambda.min', type='response')
train_pred_class <- ifelse(train_pred > 0.5, 1, 0)
test_pred_class <- ifelse(test_pred > 0.5, 1, 0)
train_acc <- mean(train_pred_class == y_train)
test_acc <- mean(test_pred_class == y_test)

roc_curve_data <- function(model, x_data, y_actual, thresholds = seq(0, 1, length.out = 101)) {
  probs <- predict(model, newx = x_data, s = "lambda.min", type = "response")[,1]

  tpr <- numeric(length(thresholds)) 
  fpr <- numeric(length(thresholds)) 

  for(i in seq_along(thresholds)) {
    predicted_class <- ifelse(probs >= thresholds[i], 1, 0)

    tp <- sum(predicted_class == 1 & y_actual == 1)
    fp <- sum(predicted_class == 1 & y_actual == 0)
    tn <- sum(predicted_class == 0 & y_actual == 0)
    fn <- sum(predicted_class == 0 & y_actual == 1)

    tpr[i] <- ifelse((tp + fn) > 0, tp / (tp + fn), 0)  
    fpr[i] <- ifelse((fp + tn) > 0, fp / (fp + tn), 0)  
  }

  tibble(
    threshold = thresholds,
    fpr = fpr,  
    tpr = tpr   
  )
}

roc_data <- roc_curve_data(cv_model, x_test, y_test)

p1 <- ggplot(roc_data, aes(x = fpr, y = tpr)) +
  geom_line(color = "blue", size = 1) +
  geom_abline(intercept = 0, slope = 1, color = "red") +
  labs(
    title = "ROC Curve for Cross-Validated Model",
    x = "False Positive Rate",
    y = "True Positive Rate"
  ) +
  theme_minimal() +
  xlim(0, 1) +
  ylim(0, 1)

print(p1)
roc_sorted <- roc_data %>% arrange(fpr)

auc_value <- sum(diff(roc_sorted$fpr) *
                   (head(roc_sorted$tpr, -1) + tail(roc_sorted$tpr, -1)) / 2)

cat("AUC (approximate):", abs(auc_value), "\n")
cat("Training Accuracy:", train_acc, "\n")
cat("Testing Accuracy:", test_acc, "\n")

var_dim <- famd_model$eig %>% as.data.frame() %>% rownames_to_column("Component") %>% 
  rename(
    Eigenvalue = eigenvalue,
    Variance = `percentage of variance`,
    Cumulative = `cumulative percentage of variance`
  )

var_dim$Component <- as.numeric(gsub("comp ", "", var_dim$Component))

ggplot(var_dim, aes(Component, Variance)) + geom_line(linewidth = 1) + geom_point(size = 2) + labs(title = 'FAMD Variance Scree Plot')


famd_coords <- famd_model$ind$coord[, 1:ncp_actual]
dup_idx <- duplicated(famd_coords)
famd_coords_unique <- famd_coords[!dup_idx, ]
y_train_unique <- y_train[!dup_idx]
sample_idx <- sample(1:nrow(famd_coords_unique), min(10000, nrow(famd_coords_unique)))
famd_sample <- famd_coords_unique[sample_idx, ]
y_sample <- y_train_unique[sample_idx]
tsne_famd <- Rtsne(famd_sample, dims = 2, perplexity = 30, verbose = FALSE, check_duplicates=FALSE, max_iter=300)
tsne_df <- as.data.frame(tsne_famd$Y) %>% mutate(class = y_sample)
colnames(tsne_df) <- c('Dimension_1', 'Dimension_2','class')
ggplot(tsne_df, aes(x=Dimension_1, y=Dimension_2, color = factor(class))) + geom_point(alpha = 0.7)
