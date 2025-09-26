# moving average

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from scipy import stats

# Data
data = {
    'year': [1991, 1992, 1993, 1994, 1995],
    'spring': [102, 110, 111, 115, 122],
    'summer': [120, 126, 128, 135, 144],
    'fall': [90, 95, 97, 103, 110],
    'winter': [78, 83, 86, 91, 98]
}

df = pd.DataFrame(data)

# a) Create quarters DataFrame
quarters = []
for year in df['year']:
    for i, season in enumerate(['spring', 'summer', 'fall', 'winter']):
        quarters.append({
            'year': year,
            'quarter': i+1,
            'season': season,
            'accounts_receivable': df.loc[df['year'] == year, season].values[0]
        })
quarters = pd.DataFrame(quarters)

# b) Compute moving averages and percentages
quarters['4q_moving_average'] = quarters['accounts_receivable'].rolling(window=4, center=False).mean()
quarters['centered_4q_moving_average'] = (quarters['4q_moving_average'] + quarters['4q_moving_average'].shift(-1))/2
quarters['actual_to_4q_moving_avg_percent'] = (quarters['accounts_receivable']/quarters['centered_4q_moving_average'])*100

# c) Compute seasonal indices
def mean_without_max_min(series):
    if len(series) <= 2:
        return series.mean()
    return series.drop([series.idxmax(), series.idxmin()]).mean()

unadjusted_seasonal_indices = quarters.groupby('season')['actual_to_4q_moving_avg_percent'].agg(mean_without_max_min)
adjusted_index = 400/unadjusted_seasonal_indices.sum()
adjusted_seasonal_indices = unadjusted_seasonal_indices*adjusted_index
print("Adjusted Seasonal Indices:")
print(adjusted_seasonal_indices)
print("Sum of Adjusted Seasonal Indices:", sum(adjusted_seasonal_indices))

# Apply seasonal indices to compute deseasonalized data
seasonal_index_map = adjusted_seasonal_indices.to_dict()
quarters['deseasonalized_data'] = quarters['accounts_receivable'] * (
    100 / quarters['season'].map(seasonal_index_map)
)
# quarters['deseasonalized_data'] = quarters.apply(
#     lambda row: row['accounts_receivable']*(100/seasonal_index_map[row['season']]),
#     axis=1
# )

# Regression Analysis on Deseasonalized Data
deseasonalized_clean = quarters.dropna(subset=['deseasonalized_data']).copy()
t = np.arange(len(deseasonalized_clean))
y = deseasonalized_clean['deseasonalized_data'].values
n = len(t)

# Linear Regression
t_mean, y_mean = np.mean(t), np.mean(y)
b_lin = np.sum((t - t_mean)*(y - y_mean)) / np.sum((t - t_mean)**2)
a_lin = y_mean - b_lin*t_mean
y_pred_lin = a_lin + b_lin*t

# Quadratic Regression
Sx = np.sum(t)
Sx2 = np.sum(t**2)
Sx3 = np.sum(t**3)
Sx4 = np.sum(t**4)
Sy = np.sum(y)
Sxy = np.sum(t*y)
Sx2y = np.sum((t**2)*y)

A = np.array([
    [n, Sx, Sx2],
    [Sx, Sx2, Sx3],
    [Sx2, Sx3, Sx4]
])
B = np.array([Sy, Sxy, Sx2y])

a_quad, b_quad, c_quad = np.linalg.solve(A, B)
y_pred_quad = a_quad + b_quad*t + c_quad*(t**2)

# Exponential Regression
logy = np.log(y)
logy_mean = np.mean(logy)
b_exp = np.sum((t - t_mean)*(logy - logy_mean)) / np.sum((t - t_mean)**2)
a_exp = logy_mean - b_exp*t_mean
A_exp = np.exp(a_exp)
y_pred_exp = A_exp * np.exp(b_exp*t)

# R² function
def r_squared(y_true, y_pred):
    ss_res = np.sum((y_true - y_pred)**2)
    ss_tot = np.sum((y_true - np.mean(y_true))**2)
    return 1 - ss_res/ss_tot

# Paired t-test function
def paired_ttest(y_true, y_pred):
    d = y_true - y_pred
    mean_d = np.mean(d)
    std_d = np.std(d, ddof=1)
    n = len(d)
    t_stat = mean_d / (std_d / np.sqrt(n))
    p_value = 2 * (1 - stats.t.cdf(abs(t_stat), df=n-1))
    return t_stat, p_value

# Compute metrics for each model
models = {
    "Linear": y_pred_lin,
    "Quadratic": y_pred_quad,
    "Exponential": y_pred_exp
}

results = {}
for model, y_pred in models.items():
    t_stat, p_val = paired_ttest(y, y_pred)
    r2 = r_squared(y, y_pred)
    results[model] = {"t": t_stat, "p": p_val, "R2": r2}

# Print results
print("\nRegression Results:")
for model, vals in results.items():
    print(f"{model}: t={vals['t']:.4f}, p={vals['p']:.4f}, R2={vals['R2']:.4f}")

# Select best model based on R²
best_model = max(results, key=lambda m: results[m]["R2"])
print("\nBest model:", best_model)

# Plot deseasonalized data with best fit
best_pred = models[best_model]
plt.figure(figsize=(12,6))
plt.plot(t, y, 'o-', label='Deseasonalized Data')
plt.plot(t, best_pred, label=f'{best_model} Trend Fit', linewidth=2)
plt.title(f"Best Fit Trend: {best_model}")
plt.xlabel("Time Index (Quarters)")
plt.ylabel("Deseasonalized Accounts Receivable")
plt.legend()
plt.grid(True)
plt.show()

# Assuming best_model and best_pred from your previous code

# Compute relative cyclic residuals
deseasonalized_clean['trend_fit'] = best_pred
deseasonalized_clean['rel_cyclic_residual'] = (
    (deseasonalized_clean['deseasonalized_data'] - deseasonalized_clean['trend_fit'])
    / deseasonalized_clean['trend_fit']
) * 100

print(deseasonalized_clean[['deseasonalized_data', 'trend_fit', 'rel_cyclic_residual']])

# Plot cyclic residuals
plt.figure(figsize=(12,5))
plt.plot(deseasonalized_clean.index, deseasonalized_clean['rel_cyclic_residual'], marker='o')
plt.axhline(0, color='red', linestyle='--')
plt.title("Relative Cyclic Residuals (%)")
plt.xlabel("Time Index (Quarters)")
plt.ylabel("Relative Cyclic Residual (%)")
plt.grid(True)
plt.show()


# Display quarters DataFrame
display(quarters)
