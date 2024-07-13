from sqlalchemy import create_engine
import pandas as pd
import yaml

class DatabaseConnector(): 
    '''
    Connects with and upload data to the database.

    Parameters:
    ----------
    yaml_file: str
        String containing the name of the file with credentials to connect to the database.

    Methods:
    -------
    read_db_creds()
        Reads yaml file and returns a dictionary with credentials.
    init_db_engine()
        Initialises engine using credentials from yaml_file.
    list_db_engine()
        Lists table names from the database.
    upload_to_db(data, tableName) 
        Uploads cleaned data to local database.
    '''
    def __init__(self, yaml_file):
        self.yaml_file = yaml_file

    def read_db_creds(self):
        '''
        Reads credentials from yaml file and returns a dictionary with credentials.
        '''
        with open(self.yaml_file, "r") as creds:
            cred_dic = yaml.safe_load(creds)
        
        return cred_dic
    
    def init_db_engine(self):
        '''
        Creates engine using the credentials dictionary from read_db_creds method.

        Returns:
        -------
        engine: Engine
            An SQLAlchemy engine to connect to the database.
        '''
        creds = self.read_db_creds()
        engine = create_engine(f"postgresql+psycopg2://{creds["RDS_USER"]}:{creds["RDS_PASSWORD"]}@{creds["RDS_HOST"]}:{creds["RDS_PORT"]}/{creds["RDS_DATABASE"]}")
        print(type(engine))
        return engine

    def list_db_tables(self):
        '''
        Lists table name from remote database.

        Returns:
        -------
        tables_df: DataFrame
            A pandas DataFrame.
        '''
        engine = self.init_db_engine()
       
        query = """
                SELECT table_name
                FROM information_schema.tables
                WHERE table_schema = 'public'
                """

        tables_df = pd.read_sql(query, engine)
        
        return tables_df
    
    def upload_to_db(self, data, tableName):
        '''
        Uploads cleaned data to local database.

        Parameters:
        ----------
        data: DataFrame
            A DataFrame containing cleaned data extracted from a remote database.
        tableName: str
            A string containing the name of the table to upload the data to.
        '''
        creds = self.read_db_creds()
        engine = create_engine(f"{creds["LOCAL_DATABASE_TYPE"]}+{creds["LOCAL_DBAPI"]}://{creds["LOCAL_USER"]}:{creds["LOCAL_PASSWORD"]}@{creds["LOCAL_HOST"]}:{creds["LOCAL_PORT"]}/{creds["LOCAL_DATABASE"]}")
        engine.connect()
        data.to_sql(tableName, engine, if_exists="replace")
   
if __name__ == "__main__":       
    test_class = DatabaseConnector('db_creds.yaml')


  

