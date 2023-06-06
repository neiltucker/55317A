# Convert CSV file to JSON 

import json, csv, numpy as np, pandas as pd

df = pd.read_csv("teachers.csv")
result = df.to_json(orient="records")
parsed = json.loads(result)
json.dumps(parsed, indent=4)
json_object = json.dumps(parsed, indent=4)
with open("teachers.json", "w") as outfile:
    outfile.write(json_object)


