import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
from sklearn.preprocessing import PolynomialFeatures
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import OneHotEncoder
from sklearn.metrics import r2_score, mean_squared_error
from scipy import stats

# ============================================================================
# PART 1: MULTIPLE LINEAR REGRESSION - 50_Startups.csv
# ============================================================================
print("="*60)
print("MULTIPLE LINEAR REGRESSION - 50_Startups")
print("="*60)

df = pd.read_csv(r'DATA\50_Startups.csv')
print(df.head())
print(df.info())

# Visualize
sns.pairplot(df, hue='State')
plt.savefig('startups_pairplot.png')
plt.close()

# Prepare data
X = df.iloc[:, :-1].values
y = df.iloc[:, -1].values

# Handle categorical (State column is at index 3)
ct = ColumnTransformer([("State", OneHotEncoder(), [3])], remainder='passthrough')
X = ct.fit_transform(X)

# Split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Train
reg = LinearRegression()
reg.fit(X_train, y_train)

# Predict
y_pred_train = reg.predict(X_train)
y_pred_test = reg.predict(X_test)

# Metrics
r2_train = reg.score(X_train, y_train)
r2_test = reg.score(X_test, y_test)
n = len(X_test)
p = X_test.shape[1]
adj_r2_test = 1 - (1 - r2_test) * ((n - 1) / (n - p - 1))

print(f"\nR² Train: {r2_train:.4f}")
print(f"R² Test: {r2_test:.4f}")
print(f"Adjusted R² Test: {adj_r2_test:.4f}")
print(f"MSE Test: {mean_squared_error(y_test, y_pred_test):.2f}")

# Prediction example
example = [[1, 0, 0, 130000, 140000, 300000]]
print(f"Prediction for {example}: {reg.predict(example)[0]:.2f}")

# Residuals analysis
residuals_test = y_test - y_pred_test
plt.figure(figsize=(12, 4))
plt.subplot(1, 3, 1)
plt.scatter(y_pred_test, residuals_test)
plt.axhline(0, color='r', linestyle='--')
plt.xlabel('Predicted')
plt.ylabel('Residuals')
plt.title('Residual Plot')
plt.subplot(1, 3, 2)
stats.probplot(residuals_test, dist="norm", plot=plt)
plt.title('Q-Q Plot')
plt.subplot(1, 3, 3)
plt.hist(residuals_test, bins=15, edgecolor='black')
plt.xlabel('Residuals')
plt.title('Residual Distribution')
plt.tight_layout()
plt.savefig('startups_residuals.png')
plt.close()

# ============================================================================
# PART 2: POLYNOMIAL REGRESSION - Position_Salaries.csv
# ============================================================================
print("\n" + "="*60)
print("POLYNOMIAL REGRESSION - Position_Salaries")
print("="*60)

df = pd.read_csv(r'DATA\Position_Salaries.csv')
print(df.head())

# Visualize
plt.figure(figsize=(8, 5))
plt.scatter(df['Level'], df['Salary'])
plt.xlabel('Level')
plt.ylabel('Salary')
plt.title('Position vs Salary')
plt.savefig('salaries_scatter.png')
plt.close()

X = df['Level'].values.reshape(-1, 1)
y = df['Salary'].values

# Linear regression first
lin_reg = LinearRegression()
lin_reg.fit(X, y)
y_pred_lin = lin_reg.predict(X)
r2_lin = r2_score(y, y_pred_lin)
print(f"\nLinear Regression R²: {r2_lin:.4f}")

# Polynomial regression (degrees 2-6)
plt.figure(figsize=(15, 10))
results = []

for i, degree in enumerate(range(2, 7), 1):
    poly = PolynomialFeatures(degree=degree)
    X_poly = poly.fit_transform(X)
    
    poly_reg = LinearRegression()
    poly_reg.fit(X_poly, y)
    y_pred_poly = poly_reg.predict(X_poly)
    
    r2 = r2_score(y, y_pred_poly)
    n = len(X)
    p = X_poly.shape[1] - 1
    adj_r2 = 1 - (1 - r2) * ((n - 1) / (n - p - 1))
    mse = mean_squared_error(y, y_pred_poly)
    
    results.append({'Degree': degree, 'R²': r2, 'Adj_R²': adj_r2, 'MSE': mse})
    
    # Plot
    plt.subplot(2, 3, i)
    plt.scatter(X, y, color='red', label='Data')
    X_smooth = np.linspace(X.min(), X.max(), 100).reshape(-1, 1)
    y_smooth = poly_reg.predict(poly.transform(X_smooth))
    plt.plot(X_smooth, y_smooth, color='blue', label=f'Degree {degree}')
    plt.title(f'Degree {degree}: R²={r2:.4f}, Adj_R²={adj_r2:.4f}')
    plt.xlabel('Level')
    plt.ylabel('Salary')
    plt.legend()

plt.tight_layout()
plt.savefig('polynomial_comparison.png')
plt.close()

print("\nPolynomial Regression Results:")
print(pd.DataFrame(results))

# ============================================================================
# PART 3: SIMULATED DATA - Inverse Relationship
# ============================================================================
print("\n" + "="*60)
print("POLYNOMIAL REGRESSION - Simulated Data")
print("="*60)

np.random.seed(2)
loading_time = np.random.normal(3.0, 1.0, 1000)
purchase_amount = np.random.normal(50.0, 10.0, 1000) / (loading_time * loading_time)

print(f"Loading Time - Mean: {loading_time.mean():.2f}, Std: {loading_time.std():.2f}")
print(f"Purchase Amount - Mean: {purchase_amount.mean():.2f}, Std: {purchase_amount.std():.2f}")

# Visualize distributions
plt.figure(figsize=(12, 4))
plt.subplot(1, 3, 1)
plt.hist(loading_time, bins=30, edgecolor='black')
plt.xlabel('Loading Time (s)')
plt.title('Loading Time Distribution')
plt.subplot(1, 3, 2)
plt.hist(purchase_amount, bins=30, edgecolor='black')
plt.xlabel('Purchase Amount (€)')
plt.title('Purchase Amount Distribution')
plt.subplot(1, 3, 3)
plt.scatter(loading_time, purchase_amount, alpha=0.5)
plt.xlabel('Loading Time (s)')
plt.ylabel('Purchase Amount (€)')
plt.title('Loading Time vs Purchase Amount')
plt.tight_layout()
plt.savefig('simulated_data.png')
plt.close()

# Polynomial regression on simulated data
X_sim = loading_time.reshape(-1, 1)
y_sim = purchase_amount

plt.figure(figsize=(15, 10))
sim_results = []

for i, degree in enumerate(range(1, 7), 1):
    poly = PolynomialFeatures(degree=degree)
    X_poly = poly.fit_transform(X_sim)
    
    poly_reg = LinearRegression()
    poly_reg.fit(X_poly, y_sim)
    y_pred_poly = poly_reg.predict(X_poly)
    
    r2 = r2_score(y_sim, y_pred_poly)
    n = len(X_sim)
    p = X_poly.shape[1] - 1
    adj_r2 = 1 - (1 - r2) * ((n - 1) / (n - p - 1))
    mse = mean_squared_error(y_sim, y_pred_poly)
    
    sim_results.append({'Degree': degree, 'R²': r2, 'Adj_R²': adj_r2, 'MSE': mse})
    
    plt.subplot(2, 3, i)
    plt.scatter(X_sim, y_sim, alpha=0.3, s=10, label='Data')
    X_smooth = np.linspace(X_sim.min(), X_sim.max(), 100).reshape(-1, 1)
    y_smooth = poly_reg.predict(poly.transform(X_smooth))
    plt.plot(X_smooth, y_smooth, color='red', linewidth=2, label=f'Degree {degree}')
    plt.title(f'Degree {degree}: R²={r2:.4f}')
    plt.xlabel('Loading Time')
    plt.ylabel('Purchase Amount')
    plt.legend()

plt.tight_layout()
plt.savefig('simulated_polynomial.png')
plt.close()

print("\nSimulated Data - Polynomial Regression Results:")
print(pd.DataFrame(sim_results))

# Best model residuals
best_degree = 2
poly = PolynomialFeatures(degree=best_degree)
X_poly = poly.fit_transform(X_sim)
poly_reg = LinearRegression()
poly_reg.fit(X_poly, y_sim)
y_pred = poly_reg.predict(X_poly)
residuals = y_sim - y_pred

plt.figure(figsize=(12, 4))
plt.subplot(1, 3, 1)
plt.scatter(y_pred, residuals, alpha=0.3)
plt.axhline(0, color='r', linestyle='--')
plt.xlabel('Predicted')
plt.ylabel('Residuals')
plt.title(f'Residual Plot (Degree {best_degree})')
plt.subplot(1, 3, 2)
stats.probplot(residuals, dist="norm", plot=plt)
plt.title('Q-Q Plot')
plt.subplot(1, 3, 3)
plt.hist(residuals, bins=30, edgecolor='black')
plt.xlabel('Residuals')
plt.title('Residual Distribution')
plt.tight_layout()
plt.savefig('simulated_residuals.png')
plt.close()

print("\n" + "="*60)
print("DISCUSSION")
print("="*60)
print("\nThe inverse relationship (y ∝ 1/x²) is challenging for polynomial regression.")
print("Better approaches:")
print("1. Transform the data: use 1/x² as predictor")
print("2. Non-linear regression models")
print("3. GAM (Generalized Additive Models)")
print("4. Neural networks for complex non-linear patterns")
print("\nAll visualizations saved as PNG files.")
