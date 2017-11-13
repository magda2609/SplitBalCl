from pymongo import MongoClient
from imblearn.over_sampling import SMOTE

import code;

import sys

client = MongoClient()
db_name = sys.argv[1]
db_collection = sys.argv[2]
db = client[db_name]
collection = db[db_collection]

smote_type = sys.argv[3]

data_positive = collection.find({"Class" : "positive"})
data_negative = collection.find({"Class" : "negative"})

values_keys = open("datasets/" + db_name +".csv", "r").readlines()[0].split(",")[0:-1]

# values_keys = ["Gvh", "Alm", "Pox", "Mcg", "Vac", "Nuc", "Erl", "Mit"]
label_key = "Class"
all_keys = values_keys + [label_key]

all_data = collection.find()
all_data_values = [[j[i] for i in values_keys] for j in all_data]
all_data = collection.find()
all_data_labels = [j["Class"] for j in all_data]

X, y = SMOTE(ratio='minority', kind=smote_type).fit_sample(all_data_values, all_data_labels)

new_values = [dict(zip(all_keys, X[i].tolist() + [y[i]])) for i in range(len(X))]

db[db_collection + '_smote'].create
new_collection = db[db_collection + '_smote_' + smote_type]

if new_collection.count() > 0:
  new_collection.drop()

new_collection.insert_many(new_values)
