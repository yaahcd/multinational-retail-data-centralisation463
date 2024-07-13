import pandas as pd
import tabula
import requests

class DataExtractor():
    '''
    Works as an utility class by extracting data from different data sources including CSV files, APIs and AWS S3 bucket.

    Attributes:
    ----------
    header: dict
        A dictionary containing an API key.
    retrieve_store_endpoint: str
        A string containing an endpoint for retrieving stores details.
    retrieve_number_stores_endpoint: str
        A string containing an endpoint for retrieving the number of stores. 

    Methods:
    -------
    read_rds_table(dbConnectorInstance, tableName)
        Reads AWS RDS table.
    retrieve_pdf_data(link)
        Retrieves data from a PDF file.
    list_number_of_stores()
        Lists the number of stores to retrieve data from.
    retrieve_stores_data()
        Retrieves data from an endpoint.
    extract_from_s3(link)
        Extracts data from AWS S3 bucket.
    '''                  
    def __init__(self):
        self.header = {"x-api-key": "yFBQbwXe9J3sd6zWVAMrK6lcxxr0q1lr2PT6DDMX"}
        self.retrieve_store_endpoint = "https://aqj7u5id95.execute-api.eu-west-1.amazonaws.com/prod/store_details/"
        self.retrieve_number_stores_endpoint = "https://aqj7u5id95.execute-api.eu-west-1.amazonaws.com/prod/number_stores"
   
    def read_rds_table(self, dbConnectorInstance, tableName):
        '''
        Connects to AWS RDS and retrieves data from specified table.

        Parameters:
        ----------
        dbConnectorInstance: class
            A class instance that is used to connect to the database.
        tableName: str
            The table name to retrieve data from.
        
        Returns:
        -------  
        DataFrame
            A pandas dataFrame.
        '''
        engine = dbConnectorInstance.init_db_engine()
        with engine.connect() as connection:
            return pd.read_sql_table(table_name=tableName, con=connection)
            
    def retrieve_pdf_data(self, link):
        '''
        Retrieves data from a pdf file.

        Parameters:
        ----------
        link: str
           An URL address to retrieve data from.

        Returns:
        -------  
        data: DataFrame
            A pandas dataFrame.
        '''
        data = tabula.read_pdf(link, pages="all")
        data = pd.concat(data)
    
        return data
    
    def list_number_of_stores(self):
        '''
        Lists number of stores to retrieve data from.

        Returns:
        -------  
        int
            An integer with the number of stores to extract data from.
        '''
        response = requests.get(self.retrieve_number_stores_endpoint, headers=self.header)
        res_json = response.json()

        return res_json["number_stores"]

    def retrieve_stores_data(self):
        '''
        Retrieves data from API endpoint and turns it into a pandas DataFrame.

        Returns:
        -------  
        stores_df: DataFrame
            A pandas dataFrame.
        '''
        num_stores = self.list_number_of_stores()
        stores_data = []
        count = 0

        while count < num_stores:
            response = requests.get(f"{self.retrieve_store_endpoint}{count}", headers=self.header)
            res_json = response.json()
            stores_data.append(res_json)
            count = count + 1

        stores_df = pd.DataFrame(stores_data)
      
        return stores_df

    def extract_from_s3(self, link):
        '''
        Extracts data from AWS S3 bucket.

        Parameters:
        ----------
        link: str
           An URL address to retrieve data from.
        
        Returns:
        -------  
        df: DataFrame
            A pandas dataFrame.
        '''
        if 's3://' in link:
            #s3fs used by pandas to handle s3 files
            df = pd.read_csv(link)
        elif 'https://' in link:
            df = pd.read_json(link)

        return df


