import pandas as pd
import numpy as np
from dateutil.parser import parse

class DataCleaning():

    def clean_user_data(self, data):
        #null values -- inplace modifies current df
        data.fillna(np.nan, inplace=True)
        #error with dates
        date_format = "%Y%m%d"
        data['date_of_birth'] = data['date_of_birth'].apply(parse)
        data['join_date'] = data['join_date'].apply(parse)
        data['date_of_birth'] = pd.to_datetime(data['date_of_birth'], format=date_format, infer_datetime_format=True, errors='coerce')
        data['join_date'] = pd.to_datetime(data['join_date'], format=date_format, infer_datetime_format=True, errors='coerce')
        #incorrect typed values
        data.str.lower()
        data = data.drop_duplicates(subset=['email_address'])
        data['phone_number'] = data['phone_number'].str.replace(".","")
        data['phone_number'] = data['phone_number'].str.replace(" ","")
        #rows filled with the wrong information
        ##
        return data