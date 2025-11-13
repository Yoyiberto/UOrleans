from sklearn.datasets import load_digits
from sklearn.decomposition import PCA
from sklearn.cluster import AgglomerativeClustering
from sklearn.metrics import adjusted_rand_score
import matplotlib.pyplot as plt
import numpy as np

# Load data
data = load_digits()
X, y_true = data.data, data.target

# Reduce to 2D with PCA
X_reduced = PCA(n_components=2).fit_transform(X)

# Hierarchical clustering
clusters = AgglomerativeClustering(n_clusters=10).fit_predict(X)

# Calculate error
ari = adjusted_rand_score(y_true, clusters)
print(f"Adjusted Rand Index: {ari:.3f}")

# Find misclassified examples (where cluster != true label)
from scipy.stats import mode
cluster_to_label = {i: mode(y_true[clusters == i], keepdims=False)[0] for i in range(10)}
predicted = np.array([cluster_to_label[c] for c in clusters])
misclassified = np.where(predicted != y_true)[0][:9]

# Visualize
fig, axes = plt.subplots(2, 5, figsize=(12, 5))
axes[0, 0].scatter(X_reduced[:, 0], X_reduced[:, 1], c=clusters, cmap='tab10', s=20)
axes[0, 0].set_title(f'Clusters (ARI={ari:.3f})')
for idx, ax in enumerate(axes.flat[1:], 1):
    if idx <= len(misclassified):
        i = misclassified[idx-1]
        ax.imshow(data.images[i], cmap='gray')
        ax.set_title(f'True:{y_true[i]} Pred:{predicted[i]}')
        ax.axis('off')
plt.tight_layout()
plt.show()
