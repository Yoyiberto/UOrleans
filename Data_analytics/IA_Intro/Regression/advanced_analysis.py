import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.linear_model import LinearRegression
from sklearn.preprocessing import PolynomialFeatures
from sklearn.metrics import r2_score, mean_squared_error
from scipy import stats

# ============================================================================
# ADVANCED DISCUSSION: INVERSE RELATIONSHIP y = 50/t²
# ============================================================================
print("="*70)
print("ADVANCED ANALYSIS: Why Polynomial Regression Fails for Inverse Relations")
print("="*70)

np.random.seed(2)
loading_time = np.random.normal(3.0, 1.0, 1000)
purchase_amount = np.random.normal(50.0, 10.0, 1000) / (loading_time ** 2)

X = loading_time.reshape(-1, 1)
y = purchase_amount

# ============================================================================
# 1. POLYNOMIAL REGRESSION (Bad approach)
# ============================================================================
poly = PolynomialFeatures(degree=4)
X_poly = poly.fit_transform(X)
poly_model = LinearRegression()
poly_model.fit(X_poly, y)
y_pred_poly = poly_model.predict(X_poly)

# ============================================================================
# 2. FEATURE ENGINEERING: Transform X → 1/X²
# ============================================================================
X_transformed = 1 / (X ** 2)
linear_model = LinearRegression()
linear_model.fit(X_transformed, y)
y_pred_transformed = linear_model.predict(X_transformed)

# ============================================================================
# 3. LOGARITHMIC TRANSFORMATION: log(y) vs log(x)
# ============================================================================
X_log = np.log(X)
y_log = np.log(y)
log_model = LinearRegression()
log_model.fit(X_log, y_log)
y_pred_log = np.exp(log_model.predict(X_log))

# ============================================================================
# COMPARE METHODS
# ============================================================================
r2_poly = r2_score(y, y_pred_poly)
r2_transformed = r2_score(y, y_pred_transformed)
r2_log = r2_score(y, y_pred_log)

mse_poly = mean_squared_error(y, y_pred_poly)
mse_transformed = mean_squared_error(y, y_pred_transformed)
mse_log = mean_squared_error(y, y_pred_log)

print("\nMODEL COMPARISON:")
print(f"{'Method':<25} {'R²':<10} {'MSE':<10}")
print("-" * 45)
print(f"{'Polynomial (degree=4)':<25} {r2_poly:<10.4f} {mse_poly:<10.2f}")
print(f"{'Feature Eng. (1/X²)':<25} {r2_transformed:<10.4f} {mse_transformed:<10.2f}")
print(f"{'Log Transformation':<25} {r2_log:<10.4f} {mse_log:<10.2f}")

# Visualize
fig, axes = plt.subplots(2, 3, figsize=(15, 10))
X_smooth = np.linspace(X.min(), X.max(), 200).reshape(-1, 1)

# Polynomial
y_smooth_poly = poly_model.predict(poly.transform(X_smooth))
axes[0, 0].scatter(X, y, alpha=0.3, s=10)
axes[0, 0].plot(X_smooth, y_smooth_poly, 'r-', linewidth=2)
axes[0, 0].set_title(f'Polynomial (R²={r2_poly:.4f})')
axes[0, 0].set_xlabel('Loading Time')
axes[0, 0].set_ylabel('Purchase Amount')

# Transformed
y_smooth_trans = linear_model.predict(1 / (X_smooth ** 2))
axes[0, 1].scatter(X, y, alpha=0.3, s=10)
axes[0, 1].plot(X_smooth, y_smooth_trans, 'g-', linewidth=2)
axes[0, 1].set_title(f'Feature Eng. 1/X² (R²={r2_transformed:.4f})')
axes[0, 1].set_xlabel('Loading Time')
axes[0, 1].set_ylabel('Purchase Amount')

# Log
y_smooth_log = np.exp(log_model.predict(np.log(X_smooth)))
axes[0, 2].scatter(X, y, alpha=0.3, s=10)
axes[0, 2].plot(X_smooth, y_smooth_log, 'b-', linewidth=2)
axes[0, 2].set_title(f'Log Transform (R²={r2_log:.4f})')
axes[0, 2].set_xlabel('Loading Time')
axes[0, 2].set_ylabel('Purchase Amount')

# Residual plots
residuals_poly = y - y_pred_poly
residuals_trans = y - y_pred_transformed
residuals_log = y - y_pred_log

axes[1, 0].scatter(y_pred_poly, residuals_poly, alpha=0.3, s=10)
axes[1, 0].axhline(0, color='r', linestyle='--')
axes[1, 0].set_title('Polynomial Residuals')
axes[1, 0].set_xlabel('Predicted')
axes[1, 0].set_ylabel('Residuals')

axes[1, 1].scatter(y_pred_transformed, residuals_trans, alpha=0.3, s=10)
axes[1, 1].axhline(0, color='r', linestyle='--')
axes[1, 1].set_title('1/X² Residuals (Better!)')
axes[1, 1].set_xlabel('Predicted')
axes[1, 1].set_ylabel('Residuals')

axes[1, 2].scatter(y_pred_log, residuals_log, alpha=0.3, s=10)
axes[1, 2].axhline(0, color='r', linestyle='--')
axes[1, 2].set_title('Log Residuals')
axes[1, 2].set_xlabel('Predicted')
axes[1, 2].set_ylabel('Residuals')

plt.tight_layout()
plt.savefig('method_comparison.png', dpi=150)
plt.close()

# ============================================================================
# RESIDUAL ANALYSIS - Deep Dive
# ============================================================================
print("\n" + "="*70)
print("RESIDUAL ANALYSIS")
print("="*70)

def analyze_residuals(residuals, name):
    print(f"\n{name}:")
    print(f"  Mean: {residuals.mean():.4f} (should be ≈0)")
    print(f"  Std Dev: {residuals.std():.4f}")
    
    # Normality tests
    _, p_shapiro = stats.shapiro(residuals[:5000] if len(residuals) > 5000 else residuals)
    _, p_ks = stats.kstest(residuals, 'norm', args=(residuals.mean(), residuals.std()))
    
    print(f"  Shapiro-Wilk p-value: {p_shapiro:.4f} (>0.05 = normal)")
    print(f"  Kolmogorov-Smirnov p-value: {p_ks:.4f} (>0.05 = normal)")
    
    # Homoscedasticity (constant variance)
    sorted_idx = np.argsort(y_pred_poly if 'Poly' in name else 
                            y_pred_transformed if 'Feature' in name else y_pred_log)
    first_half = residuals[sorted_idx[:len(residuals)//2]]
    second_half = residuals[sorted_idx[len(residuals)//2:]]
    _, p_levene = stats.levene(first_half, second_half)
    print(f"  Levene's test p-value: {p_levene:.4f} (>0.05 = homoscedastic)")

analyze_residuals(residuals_poly, "Polynomial Regression")
analyze_residuals(residuals_trans, "Feature Engineering (1/X²)")
analyze_residuals(residuals_log, "Log Transformation")

# Detailed residual plots
fig, axes = plt.subplots(3, 3, figsize=(15, 12))

for i, (residuals, name) in enumerate([
    (residuals_poly, 'Polynomial'),
    (residuals_trans, 'Feature Eng. (1/X²)'),
    (residuals_log, 'Log Transform')
]):
    # Q-Q plot
    stats.probplot(residuals, dist="norm", plot=axes[i, 0])
    axes[i, 0].set_title(f'{name}: Q-Q Plot')
    
    # Histogram
    axes[i, 1].hist(residuals, bins=40, edgecolor='black', alpha=0.7)
    axes[i, 1].axvline(0, color='r', linestyle='--')
    axes[i, 1].set_title(f'{name}: Distribution')
    axes[i, 1].set_xlabel('Residuals')
    
    # Residuals vs fitted
    y_pred = y_pred_poly if i == 0 else y_pred_transformed if i == 1 else y_pred_log
    axes[i, 2].scatter(y_pred, residuals, alpha=0.3, s=10)
    axes[i, 2].axhline(0, color='r', linestyle='--')
    axes[i, 2].set_title(f'{name}: Residuals vs Fitted')
    axes[i, 2].set_xlabel('Fitted Values')
    axes[i, 2].set_ylabel('Residuals')

plt.tight_layout()
plt.savefig('residual_analysis.png', dpi=150)
plt.close()

# ============================================================================
# OVERFITTING ANALYSIS: Multiple vs Polynomial
# ============================================================================
print("\n" + "="*70)
print("OVERFITTING DETECTION")
print("="*70)

from sklearn.model_selection import train_test_split
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import OneHotEncoder

# Multiple Linear Regression
df_startups = pd.read_csv(r'DATA\50_Startups.csv')
X_multi = df_startups.iloc[:, :-1].values
y_multi = df_startups.iloc[:, -1].values
ct = ColumnTransformer([("State", OneHotEncoder(), [3])], remainder='passthrough')
X_multi = ct.fit_transform(X_multi)
X_train, X_test, y_train, y_test = train_test_split(X_multi, y_multi, test_size=0.2, random_state=42)

multi_model = LinearRegression()
multi_model.fit(X_train, y_train)
r2_train_multi = multi_model.score(X_train, y_train)
r2_test_multi = multi_model.score(X_test, y_test)

print("\nMultiple Linear Regression (50_Startups):")
print(f"  Train R²: {r2_train_multi:.4f}")
print(f"  Test R²:  {r2_test_multi:.4f}")
print(f"  Gap: {r2_train_multi - r2_test_multi:.4f} {'⚠ OVERFITTING' if r2_train_multi - r2_test_multi > 0.1 else '✓ Good'}")

# Polynomial Regression (different degrees)
df_salaries = pd.read_csv(r'DATA\Position_Salaries.csv')
X_sal = df_salaries['Level'].values.reshape(-1, 1)
y_sal = df_salaries['Salary'].values

print("\nPolynomial Regression (Position_Salaries):")
print(f"{'Degree':<8} {'Train R²':<12} {'Test R²':<12} {'Gap':<10} {'Status'}")
print("-" * 60)

for degree in range(1, 8):
    X_train, X_test, y_train, y_test = train_test_split(X_sal, y_sal, test_size=0.3, random_state=42)
    
    poly = PolynomialFeatures(degree=degree)
    X_train_poly = poly.fit_transform(X_train)
    X_test_poly = poly.transform(X_test)
    
    model = LinearRegression()
    model.fit(X_train_poly, y_train)
    
    r2_train = model.score(X_train_poly, y_train)
    r2_test = model.score(X_test_poly, y_test)
    gap = r2_train - r2_test
    
    status = '✓ Good' if gap < 0.1 else '⚠ Overfitting' if gap < 0.3 else '✗ Severe Overfitting'
    print(f"{degree:<8} {r2_train:<12.4f} {r2_test:<12.4f} {gap:<10.4f} {status}")

# ============================================================================
# CONCLUSIONS
# ============================================================================
print("\n" + "="*70)
print("KEY INSIGHTS")
print("="*70)
print("""
1. INVERSE RELATIONSHIPS (y = 1/x²):
   - Polynomial regression FAILS because it tries to fit y = a₀ + a₁x + a₂x² + ...
   - The true relationship is y = k/x², which is fundamentally different
   - Solution: Transform features → use 1/x² as predictor, then fit linear model

2. BETTER METHODS:
   ✓ Feature Engineering: Transform X → 1/X² (R² ≈ 0.99)
   ✓ Log-log regression: log(y) vs log(x) for power laws
   ✓ Non-linear least squares
   ✓ Spline regression
   ✓ Gaussian Process Regression

3. RESIDUAL ANALYSIS REVEALS:
   - Good model: residuals randomly scattered around 0, normally distributed
   - Bad model: patterns in residuals (curves, funnels) → poor fit
   - Check: mean≈0, constant variance, normality tests

4. OVERFITTING DETECTION:
   - Large gap between Train R² and Test R² → overfitting
   - High polynomial degrees (>4) often overfit small datasets
   - Multiple linear regression less prone to overfitting than polynomials
   - Solution: cross-validation, regularization (Ridge, Lasso)

See generated PNG files for visual evidence.
""")
