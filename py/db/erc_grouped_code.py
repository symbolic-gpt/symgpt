from typing import Dict
from sol.simil import zss_distance
from sol.ast import get_sol_ast
import logging
logger = logging.getLogger(__name__)
from collections import Counter


        
import numpy as np
from sklearn.cluster import KMeans

def group_tuples(data, n_clusters=3):
    # Extract the float values for clustering
    float_values = np.array([item[0] for item in data]).reshape(-1, 1)

    # Perform K-means clustering
    kmeans = KMeans(n_clusters=n_clusters, random_state=0).fit(float_values)
    labels = kmeans.labels_

    # Group data based on labels
    grouped_data = [[] for _ in range(n_clusters)]
    for label, item in zip(labels, data):
        grouped_data[label].append(item)

    return grouped_data


def init_erc_grouped_code_database(erc_ct:Dict) -> Dict:
    db = {}
    for rid, codes in erc_ct.items():
        db[rid] = get_grouped_exps(codes)
    return db

def get_grouped_exps(codes):
    code2ast = {}
    for code in codes:
        code2ast[code] = get_sol_ast(code)
    
    sus = list(code2ast.values())
    distances = [(zss_distance(sus[0], su), i) for i, su in enumerate(sus[1:])]
    dist = dict(Counter([dis for dis, _ in distances]))
    groups = group_tuples(distances, 3)
    
    rule_examples = []
    for gid, group in enumerate(groups):
        item = group[0]
        code_id = item[1]
        
        rule_examples.append({
            "sim": item[0],
            "code": codes[code_id]
        })
    return {
            "dist": dist,
            "examples": rule_examples
        }