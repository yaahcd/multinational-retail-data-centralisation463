import pandas as pd 
import numpy as np 

class DataCleaning():

    def clean_user_data(self, data):
        #null values -- inplace modifies current df
        data.fillna(np.nan, inplace=True)
        data.replace('NULL', np.nan, inplace=True)
        #error with dates
        data['date_of_birth'] = pd.to_datetime(data['date_of_birth'],  errors='coerce')
        data['join_date'] = pd.to_datetime(data['join_date'],  errors='coerce')
        #incorrect typed values
        data['email_address'].str.lower()
        data = data.drop_duplicates(subset=['email_address'])
        data['phone_number'] = data['phone_number'].str.replace(".","")
        data['phone_number'] = data['phone_number'].str.replace(" ","")
     
        return data
    
    def clean_card_data(self, data):

        data.fillna(np.nan, inplace=True)
        data.replace('NULL', np.nan, inplace=True)
        data['date_payment_confirmed'] = pd.to_datetime(data['date_payment_confirmed'],  errors='coerce')

        return data
    
    def clean_store_data(self, data):

        data.fillna(np.nan, inplace=True)
        data.replace('NULL', np.nan, inplace=True)
        data.drop(columns='lat', inplace=True)
        data['opening_date'] = pd.to_datetime(data['opening_date'], errors='coerce')
        data['staff_numbers'] = pd.to_numeric(data['staff_numbers'], errors='coerce')
        data['address'] = data['address'].str.replace("\n"," ")
        data['continent'] = data['continent'].str.replace('eeEurope','Europe')
        data['continent'] = data['continent'].str.replace('eeAmerica','America')

        return data
    
    def convert_product_weights(self, value):

        if 'x' in value:
            parts = value.split("x")
            parts = [parts[0].strip(), parts[1].replace('g', "").strip()]
            value = int(parts[0]) * int(parts[1])
            return str(float(value) / 1000)
        if 'kg' in value:
            value = value.replace('kg','')
            return str(float(value))
        elif 'g' in value:
            value = value.replace('g','')
            return str(float(value) / 1000)
        elif 'ml' in value:
            value = value.replace('ml','')
            return str(float(value) / 1000)
        elif 'oz' in value:
            value = value.replace('oz','')
            return str(float(value) / 35.274)
        
        return value
    
    def clean_products_data(self, data):

        data['weight'] = data['weight'].str.replace(".", "")
        data['weight'].fillna("0", inplace=True)
        data.fillna(np.nan, inplace=True)
        data.replace('NULL', np.nan, inplace=True)
        data['date_added'] = pd.to_datetime(data['date_added'],errors='coerce')
        data['weight'] = data['weight'].apply(self.convert_product_weights)

        return data
    
    def clean_orders_data(self, data):

        data.drop(columns='first_name', inplace=True)
        data.drop(columns='last_name', inplace=True)
        data.drop(columns='1', inplace=True)
        data.drop(columns='level_0', inplace=True)

        return data
    
    def clean_date_events_data(self, data):

        data.fillna(np.nan, inplace=True)
        data.replace('NULL', np.nan, inplace=True)
        data['timestamp'] = pd.to_datetime(data['timestamp'], errors='coerce', format='%H:%M:%S')

        return data