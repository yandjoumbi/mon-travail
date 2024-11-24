import pandas as pd

# Data structure to mimic the output of the SQL query
data = {
    "column_name": [
        "DEPARTURE_DELAY_In_Minutes", "ARRIVAL_DELAY_In_Minutes", "AIR_SYSTEM_DELAY",
        "SECURITY_DELAY", "AIRLINE_DELAY", "LATE_AIRCRAFT_DELAY", "WEATHER_DELAY"
    ],
    "Mean_column": [15.3, 12.8, 7.2, 1.1, 5.6, 8.7, 4.4],
    "Min_column": [0, 0, 0, 0, 0, 0, 0],
    "Max_column": [180, 150, 60, 15, 90, 120, 45],
    "Std_dev": [30.5, 25.6, 15.2, 2.8, 20.4, 18.6, 10.2]
}

# Convert to DataFrame
df = pd.DataFrame(data)

# Saving to a CSV file
csv_path = "C:/Users/ydjou/workspace/mon-travail/terraform/aws-glue-athena/airport_delays_summary.csv"
df.to_csv(csv_path, index=False)

csv_path
