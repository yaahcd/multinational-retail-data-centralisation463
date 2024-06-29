from sqlalchemy import create_engine
import pandas as pd
import yaml


class DatabaseConnector(): 
#which you will use to connect with and upload data to the database.
 
    def read_db_creds(self):

        with open('db_creds.yaml', "r") as creds:
            cred_dic = yaml.safe_load(creds)
        
        return cred_dic
    
    def init_db_engine(self):

        creds = self.read_db_creds()
        engine = create_engine(f"postgresql+psycopg2://{creds["RDS_USER"]}:{creds["RDS_PASSWORD"]}@{creds["RDS_HOST"]}:{creds["RDS_PORT"]}/{creds["RDS_DATABASE"]}")

        return engine

    def list_db_tables(self):

        engine = self.init_db_engine()
       
        query = """
                SELECT table_name
                FROM information_schema.tables
                WHERE table_schema = 'public'
                """

        tables_df = pd.read_sql(query, engine)

        return tables_df
    
    def upload_to_db(self, data, tableName):
        creds = self.read_db_creds()
        engine = create_engine(f"{creds["LOCAL_DATABASE_TYPE"]}+{creds["LOCAL_DBAPI"]}://{creds["LOCAL_USER"]}:{creds["LOCAL_PASSWORD"]}@{creds["LOCAL_HOST"]}:{creds["LOCAL_PORT"]}/{creds["LOCAL_DATABASE"]}")
        engine.connect()
        data.to_sql(tableName, engine, if_exists="replace")

        

if __name__ == "__main__":       
    test_class = DatabaseConnector()
    print(test_class.list_db_tables())
  