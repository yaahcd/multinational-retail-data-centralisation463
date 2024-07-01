from database_utils import DatabaseConnector
import pandas as pd
import tabula
from data_cleaning import DataCleaning
# This class will work as a utility class, in it you will be creating methods that help extract data from different data sources.
# The methods contained will be fit to extract data from a particular data source, these sources will include CSV files, an API and an S3 bucket.
class DataExtractor():
                                                
    def read_rds_table(self, dbConnectorInstance, tableName):

        engine = dbConnectorInstance.init_db_engine()
        with engine.connect() as connection:
            return pd.read_sql_table(table_name=tableName, con=connection)
            
    def retrieve_pdf_data(self, link):

        data = tabula.read_pdf(link, pages="all")
        data = pd.concat(data)
    
        return data


test_class = DatabaseConnector()
test_extractor = DataExtractor()
data_cleaning = DataCleaning()

result = data_cleaning.clean_card_data(test_extractor.retrieve_pdf_data("https://data-handling-public.s3.eu-west-1.amazonaws.com/card_details.pdf"))

test_class.upload_to_db(result, "dim_card_details")
