from sklearn.cluster import AgglomerativeClustering
from sklearn.datasets import load_digits
from sklearn.decomposition import PCA
import matplotlib.pyplot as plt

# Load high-dimensional dataset (64 features)
X, y = load_digits(return_X_y=True)

# Reduce to 2D using PCA
pca = PCA(n_components=2)
X_reduced = pca.fit_transform(X)

# Hierarchical clustering
hc = AgglomerativeClustering(n_clusters=10, linkage='ward')
labels = hc.fit_predict(X_reduced)

# Visualize
plt.figure(figsize=(10, 5))

plt.subplot(1, 2, 1)
plt.scatter(X_reduced[:, 0], X_reduced[:, 1], c=labels, cmap='tab10', s=5)
plt.title('Hierarchical Clustering')
plt.xlabel('PC1')
plt.ylabel('PC2')

plt.subplot(1, 2, 2)
plt.scatter(X_reduced[:, 0], X_reduced[:, 1], c=y, cmap='tab10', s=5)
plt.title('True Labels')
plt.xlabel('PC1')
plt.ylabel('PC2')

plt.tight_layout()
plt.show()
