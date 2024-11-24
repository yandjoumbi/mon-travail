from aws_glue import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark.sql import functions as F
from awsglue.dynamicframe import DynamicFrame

# Getting job arguments
args = getResolvedOptions(sys.argv, ['JOB_NAME'])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# Load the data from AWS Glue Catalog
datasource = glueContext.create_dynamic_frame.from_catalog(
    database="sports_database", table_name="athlete_data_input"
)

# Convert to Spark DataFrame for easier manipulation
df = datasource.toDF()

# Print schema to check available columns
df.printSchema()

# Initialize list to hold selected transformations
selected_columns = []

# Add transformations based on available columns
if 'ATHLETE_AGE' in df.columns:
    selected_columns.extend([
        F.avg("ATHLETE_AGE").alias("Mean_Athlete_Age"),
        F.min("ATHLETE_AGE").alias("Min_Athlete_Age"),
        F.max("ATHLETE_AGE").alias("Max_Athlete_Age"),
        F.stddev("ATHLETE_AGE").alias("StdDev_Athlete_Age")
    ])

if 'ATHLETE_LEAGUE' in df.columns:
    # Count athletes in each league
    league_counts = df.groupBy("ATHLETE_LEAGUE").count().alias("Athlete_Count_By_League")

# Apply transformations
transformed_df = df.select(*selected_columns)

# Include league counts if applicable
if 'ATHLETE_LEAGUE' in df.columns:
    transformed_df = transformed_df.join(league_counts, on="ATHLETE_LEAGUE", how="left")

# Convert back to Glue DynamicFrame if needed
transformed_dynamic_frame = DynamicFrame.fromDF(transformed_df, glueContext, "transformed_data")

# Save the transformed data back to an S3 bucket (output sink)
output_sink = glueContext.write_dynamic_frame.from_options(
    frame=transformed_dynamic_frame,
    connection_type="s3",
    connection_options={"path": "s3://all-purposes-yannick-bucket/athlete-data-output/"},
    format="json"  # Change to "csv" if required
)

# Commit the job
job.commit()



