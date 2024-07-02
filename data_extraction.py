import pandas as pd
import tabula
import requests
import boto3
from database_utils import DatabaseConnector
from data_cleaning import DataCleaning
# This class will work as a utility class, in it you will be creating methods that help extract data from different data sources.
# The methods contained will be fit to extract data from a particular data source, these sources will include CSV files, an API and an S3 bucket.


header = {"x-api-key": "yFBQbwXe9J3sd6zWVAMrK6lcxxr0q1lr2PT6DDMX"}
retrieve_store_endpoint = "https://aqj7u5id95.execute-api.eu-west-1.amazonaws.com/prod/store_details/"
retrieve_number_stores_endpoint = "https://aqj7u5id95.execute-api.eu-west-1.amazonaws.com/prod/number_stores"

class DataExtractor():
                                                
    def read_rds_table(self, dbConnectorInstance, tableName):

        engine = dbConnectorInstance.init_db_engine()
        with engine.connect() as connection:
            return pd.read_sql_table(table_name=tableName, con=connection)
            
    def retrieve_pdf_data(self, link):

        data = tabula.read_pdf(link, pages="all")
        data = pd.concat(data)
    
        return data
    
    def list_number_of_stores(self, endpoint, key):

        response = requests.get(endpoint, headers=key)
        res_json = response.json()

        return res_json["number_stores"]

    def retrieve_stores_data(self, num_stores, endpoint, key):
        
        stores_data = []
        count = 0

        while count < num_stores:
            response = requests.get(f"{endpoint}{count}", headers=key)
            res_json = response.json()
            stores_data.append(res_json)
            count = count + 1

        stores_df = pd.DataFrame(stores_data)
      
        return stores_df

    def extract_from_s3(self, link):

        #s3fs used by panda to handle s3 files
        df = pd.read_csv(link)

        return df




test_class = DatabaseConnector()
test_extractor = DataExtractor()
data_cleaning = DataCleaning()

