# Logistic Regression Tutorial - Summary

This document summarizes the Logistic Regression classification task completed following the tutorial instructions.

## Dataset
- **Source**: `Social_Network_Ads.csv`
- **Features**: Age and Estimated Salary
- **Target**: Purchased (0 or 1)

## Steps Completed

### 1. Data Preprocessing
- Imported required libraries (numpy, matplotlib, pandas, seaborn, sklearn)
- Loaded the dataset and selected Age and EstimatedSalary as features
- Split data into Training (75%) and Test (25%) sets
- Applied Feature Scaling using StandardScaler to normalize features

### 2. Model Training
- Trained a Logistic Regression classifier on the scaled training data

### 3. Model Evaluation
- Predicted results on the test set
- Generated Confusion Matrix:
  ```
  [[65  3]
   [ 8 24]]
  ```
- **Accuracy Score**: 0.89 (89%)

### 4. Visualizations Generated

#### Confusion Matrix Heatmap
Shows model performance with:
- 65 True Negatives (correctly predicted not purchased)
- 24 True Positives (correctly predicted purchased)
- 3 False Positives
- 8 False Negatives

#### Training Set Decision Boundary
Visualization showing:
- Red region: predicted as class 0 (not purchased)
- Green region: predicted as class 1 (purchased)
- Decision boundary separating the two classes
- Training data points colored by actual class

#### Test Set Decision Boundary
Similar visualization for test set showing model generalization to unseen data.

#### ROC Curve
- **AUC Score**: 0.8529
- Shows the trade-off between True Positive Rate and False Positive Rate
- The curve is well above the random classifier diagonal, indicating good model performance

## Results
The Logistic Regression model achieved 89% accuracy and an AUC score of 0.85 on the test set, demonstrating good performance in predicting customer purchase behavior based on age and estimated salary.
