import pandas as pd
import json

csv_file = 'All National Parks Visitation 1904-2016.csv'

# Read the CSV file
df = pd.read_csv(csv_file)

# Normalize names by stripping "National Park" from 'Unit Name' if 'Parkname' is empty
df['Parkname'] = df['Parkname'].fillna(df['Unit Name'].str.replace(' National Park', ''))

# National parks of interest
parks_names = ["Yellowstone", "Yosemite", "Grand Canyon", "Zion", "Acadia", "Great Smoky Mountains", "Rocky Mountain", "Glacier"]

# Filter df for the parks of interest
df_filtered = df[df['Parkname'].isin(parks_names) & (df['YearRaw'].str.isnumeric())]

# Convert the YearRaw to datetime and extract the year
df_filtered['Year'] = pd.to_datetime(df_filtered['YearRaw'], format='%Y').dt.year

# Group by Year and structure the data into [year=[{park name, visitor count},{},{}], ...]
results = {}
for year, group in df_filtered.groupby('Year'):
    results[year] = [
        {
            "name": row['Parkname'],
            "visitors": row['Visitors'],
        }
        for index, row in group.iterrows()
    ]

# Convert to JSON
json_output = json.dumps(results, indent=4)

# Write to a JSON file
with open('national_parks_visitation2.json', 'w') as file:
    file.write(json_output)

print("JSON data has been written to 'national_parks_visitation2.json'")
print(json_output)
