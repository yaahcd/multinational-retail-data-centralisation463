from database_utils import DatabaseConnector
import pandas as pd
# This class will work as a utility class, in it you will be creating methods that help extract data from different data sources.
# The methods contained will be fit to extract data from a particular data source, these sources will include CSV files, an API and an S3 bucket.
class DataExtractor():
    
    def read_rds_table(self, dbConnectorInstance, tableName):

        engine = dbConnectorInstance.init_db_engine()
        with engine.connect() as connection:
            return pd.read_sql_table(table_name=tableName, con=connection)
        


test_class = DatabaseConnector()
test_extractor = DataExtractor()
print(test_extractor.read_rds_table(test_class, "legacy_users"))
