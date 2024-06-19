import pandas as pd
import numpy as np
from sklearn.cluster import KMeans
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.cluster import KMeans

column_names = ['UserID', 'MovieID', 'Rating', 'Timestamp']
ratings = pd.read_csv('ml-1m/ratings.dat', sep='::', header=None, names=column_names, engine='python')
num_users = ratings['UserID'].max()
num_movies = ratings['MovieID'].max()
ratings_array = np.zeros((num_users, num_movies))
ratings_array[ratings['UserID'] - 1, ratings['MovieID'] - 1] = ratings['Rating']

pipe = make_pipeline(StandardScaler(), KMeans(n_clusters=3, n_init=10, random_state=69))
pipe.fit(ratings_array)
cluster_labels = pipe['kmeans'].labels_
unique, counts = np.unique(cluster_labels, return_counts=True)
print("각 군집의 크기:", dict(zip(unique, counts)))


clusters = {i: pd.DataFrame(ratings_array[cluster_labels == i]) for i in np.unique(cluster_labels)}
au = lambda df: df.sum(axis=0)
avg = lambda df: df.apply(lambda x: x.replace(0, pd.NA)).mean(axis=0).apply(lambda x: x if pd.notna(x) else 0)
sc = lambda df: (df > 0).sum(axis=0)
av = lambda df: (df >= 4).sum(axis=0)
bc = lambda df: (df.apply(lambda x: x.replace(0, pd.NA)).rank(axis=1) - 1).sum(axis=0).apply(lambda x: x if pd.notna(x) else 0)
cr = lambda df: np.sign(df.apply(lambda col: np.sign(df.rsub(col, axis=0)).sum(axis=0))).sum(axis=0)
results = {}
for cluster_id, df in clusters.items():
    results[cluster_id] = {
        'AU': au(df),
        'Avg': avg(df),
        'SC': sc(df),
        'AV': av(df),
        'BC': bc(df),
        'CR': cr(df)
    }
results_df = {cluster_id: pd.DataFrame(metrics) for cluster_id, metrics in results.items()}
for cluster_id, result in results_df.items():
    result.head()

results_top10 = {}
for cluster_id, metrics in results_df.items():
    top10_metrics = {}
    for metric, values in metrics.items():
        top10_indices = values.sort_values(ascending=False).index[:10] + 1
        top10_metrics[metric] = top10_indices
    results_top10[cluster_id] = pd.DataFrame(top10_metrics)


for cluster_id, result in results_top10.items():
    print(f"\nCluster {cluster_id} top 10 results:\n")
    print(result)
