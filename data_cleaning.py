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
        data['phone_number'].to_string()
        data['email_address'].to_string()
        data['email_address'].str.lower()
        data = data.drop_duplicates(subset=['email_address'])
        data['phone_number'] = data['phone_number'].str.replace(".","")
        data['phone_number'] = data['phone_number'].str.replace(" ","")
        #rows filled with the wrong information
        ##
        return data
    
    def clean_card_data(self, data):

        data.fillna(np.nan, inplace=True)
        data.replace('NULL', np.nan, inplace=True)
        data['card_number'] = data['card_number'].astype('string')
        data['card_provider'] = data['card_provider'].astype('string')
        data['expiry_date'] = data['expiry_date'].astype('string')
        data['date_payment_confirmed'] = pd.to_datetime(data['date_payment_confirmed'],  errors='coerce')

        return data
    
    def clean_store_data(self, data):

        data.fillna(np.nan, inplace=True)
        data.replace('NULL', np.nan, inplace=True)
        data = data.reset_index(drop=True)
        data['opening_date'] = pd.to_datetime( data['opening_date'], errors='coerce')
        data['staff_numbers'] = pd.to_numeric( data['staff_numbers'], errors='coerce')
        data['address'] = data['address'].astype('string')
        data['address'] = data['address'].str.replace("\n"," ")
        data['continent'] = data['continent'].astype('string')
        data['continent'] = data['continent'].str.replace('eeEurope','Europe')
        data['continent'] = data['continent'].str.replace('eeAmerica','America')

        return data