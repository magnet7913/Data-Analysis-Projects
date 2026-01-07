### Sai Gon Real Estate 2025 overview

As a prospective homebuyer, I initiated this project to gain a clearer understanding of the real estate market in Ho Chi Minh City (Saigon).

The dataset utilized in this analysis was sourced from the repository available at: https://github.com/qmanhbeo/VN-real-estate-scraper.

Check out the viz of this project on my [tableau profile](https://public.tableau.com/app/profile/bluetail.zacky/viz/SaigonRealEstate2025/Overview)

This project is intended solely for research and personal informational purposes. If you find it useful, kindly consider leaving a comment. Thank you :)

```python
import pandas as pd
pd.set_option('display.float_format', '{:.0f}'.format)
```


```python
df = pd.read_csv('data_public.csv',index_col='Listing ID')
```


```python
df.info()
```

    <class 'pandas.core.frame.DataFrame'>
    Index: 51304 entries, 1546393.0 to 1213837.0
    Data columns (total 27 columns):
     #   Column               Non-Null Count  Dtype  
    ---  ------               --------------  -----  
     0   Title                51304 non-null  object 
     1   Price                51304 non-null  float64
     2   Area                 51200 non-null  float64
     3   Location             51304 non-null  object 
     4   Last Updated         51304 non-null  object 
     5   Property Type        51304 non-null  object 
     6   Width                34298 non-null  float64
     7   Length               25267 non-null  float64
     8   Bedrooms             16642 non-null  float64
     9   Bathrooms            10764 non-null  float64
     10  Floors               8680 non-null   float64
     11  Position             29432 non-null  object 
     12  Direction            10674 non-null  object 
     13  Alley Width          12253 non-null  float64
     14  Road Type            14164 non-null  object 
     15  Description          45093 non-null  object 
     16  Latitude             21448 non-null  float64
     17  Longitude            21448 non-null  float64
     18  VIP Account          51304 non-null  bool   
     19  Avatar               51304 non-null  int64  
     20  Agent Role           51304 non-null  object 
     21  Agent Name           50375 non-null  object 
     22  Agent Listing Count  51304 non-null  float64
     23  Province             51304 non-null  object 
     24  Property Type Slug   51304 non-null  object 
     25  Scraped At           51304 non-null  object 
     26  Last Updated Date    51304 non-null  object 
    dtypes: bool(1), float64(11), int64(1), object(14)
    memory usage: 10.6+ MB
    


```python
df.head()
```




<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Title</th>
      <th>Price</th>
      <th>Area</th>
      <th>Location</th>
      <th>Last Updated</th>
      <th>Property Type</th>
      <th>Width</th>
      <th>Length</th>
      <th>Bedrooms</th>
      <th>Bathrooms</th>
      <th>...</th>
      <th>Longitude</th>
      <th>VIP Account</th>
      <th>Avatar</th>
      <th>Agent Role</th>
      <th>Agent Name</th>
      <th>Agent Listing Count</th>
      <th>Province</th>
      <th>Property Type Slug</th>
      <th>Scraped At</th>
      <th>Last Updated Date</th>
    </tr>
    <tr>
      <th>Listing ID</th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>1546393</th>
      <td>🏠 NHÀ 3 TẦNG – TRUNG TÂM PHƯỚC LONG B, THỦ ĐỨC</td>
      <td>7500</td>
      <td>95</td>
      <td>Phường Phước Long,TP. Hồ Chí Minh</td>
      <td>2 giờ trước</td>
      <td>Nhà riêng</td>
      <td>5</td>
      <td>17</td>
      <td>3</td>
      <td>3</td>
      <td>...</td>
      <td>NaN</td>
      <td>False</td>
      <td>1</td>
      <td>Môi giới</td>
      <td>Ngô Quang Tùng</td>
      <td>20</td>
      <td>tp-ho-chi-minh</td>
      <td>nha-mat-pho-mat-tien</td>
      <td>2025-09-30 18:24:18</td>
      <td>30/09/2025 16:24</td>
    </tr>
    <tr>
      <th>1528310</th>
      <td>🔥🔥 NHÀ ĐẸP HIỆP BÌNH PHƯỚC – HẺM XE HƠI – KHU ...</td>
      <td>4500</td>
      <td>66</td>
      <td>đường Hiệp Bình,Phường Hiệp Bình Chánh,Quận Th...</td>
      <td>2 giờ trước</td>
      <td>Nhà riêng</td>
      <td>4</td>
      <td>NaN</td>
      <td>2</td>
      <td>NaN</td>
      <td>...</td>
      <td>NaN</td>
      <td>False</td>
      <td>1</td>
      <td>Môi giới</td>
      <td>Ngô Quang Tùng</td>
      <td>20</td>
      <td>tp-ho-chi-minh</td>
      <td>nha-mat-pho-mat-tien</td>
      <td>2025-09-30 18:24:18</td>
      <td>30/09/2025 16:24</td>
    </tr>
    <tr>
      <th>1546519</th>
      <td>🌟 HXH - NHÀ 3 TẦNG ĐẸP – TRUNG TÂM PHƯỚC LONG ...</td>
      <td>7500</td>
      <td>92</td>
      <td>Phường Phước Long B,Quận 9,TP. Hồ Chí Minh</td>
      <td>2 giờ trước</td>
      <td>Nhà riêng</td>
      <td>5</td>
      <td>17</td>
      <td>3</td>
      <td>3</td>
      <td>...</td>
      <td>NaN</td>
      <td>False</td>
      <td>1</td>
      <td>Môi giới</td>
      <td>Ngô Quang Tùng</td>
      <td>20</td>
      <td>tp-ho-chi-minh</td>
      <td>nha-mat-pho-mat-tien</td>
      <td>2025-09-30 18:24:18</td>
      <td>30/09/2025 16:24</td>
    </tr>
    <tr>
      <th>1544240</th>
      <td>🏡 HÀNG HIẾM LINH CHIỂU – NHÀ 2 TẦNG – VỊ TRÍ V...</td>
      <td>4750</td>
      <td>45</td>
      <td>đường số 19,Phường Linh Chiểu,Quận Thủ Đức,TP....</td>
      <td>2 giờ trước</td>
      <td>Nhà riêng</td>
      <td>4</td>
      <td>12</td>
      <td>3</td>
      <td>NaN</td>
      <td>...</td>
      <td>NaN</td>
      <td>False</td>
      <td>1</td>
      <td>Môi giới</td>
      <td>Ngô Quang Tùng</td>
      <td>20</td>
      <td>tp-ho-chi-minh</td>
      <td>nha-mat-pho-mat-tien</td>
      <td>2025-09-30 18:24:18</td>
      <td>30/09/2025 16:24</td>
    </tr>
    <tr>
      <th>1528291</th>
      <td>🚗 NHÀ ĐẸP HẺM XE HƠI – VỊ TRÍ VIP LINH TÂY – G...</td>
      <td>4800</td>
      <td>82</td>
      <td>đường số 9,Phường Linh Tây,Quận Thủ Đức,TP. Hồ...</td>
      <td>2 giờ trước</td>
      <td>Nhà riêng</td>
      <td>8</td>
      <td>NaN</td>
      <td>2</td>
      <td>1</td>
      <td>...</td>
      <td>NaN</td>
      <td>False</td>
      <td>1</td>
      <td>Môi giới</td>
      <td>Ngô Quang Tùng</td>
      <td>20</td>
      <td>tp-ho-chi-minh</td>
      <td>nha-mat-pho-mat-tien</td>
      <td>2025-09-30 18:24:18</td>
      <td>30/09/2025 16:24</td>
    </tr>
  </tbody>
</table>
<p>5 rows × 27 columns</p>
</div>




```python
df['Property Type'].value_counts()
```




    Property Type
    Đất                29530
    Căn hộ chung cư    11012
    Nhà riêng           8184
    Kho, nhà xưởng      1800
    Nhà trọ              538
    Khách sạn            196
    Văn phòng             44
    Name: count, dtype: int64




```python
df[df['Latitude'].isna()]['Property Type'].value_counts()
```




    Property Type
    Đất                13520
    Căn hộ chung cư    10943
    Nhà riêng           3047
    Kho, nhà xưởng      1661
    Nhà trọ              459
    Khách sạn            188
    Văn phòng             38
    Name: count, dtype: int64




```python
# Since there are alot of missing data and unneeded data for this analysis in this dataset, lets only pick out the useful collumns
df= df[['Title','Price','Area','Location','Property Type','Width','Length','Bedrooms','Bathrooms','Floors']]
```


```python
# Lets pick out the Wards and the Districts into different columns
df['Ward'] = df['Location'].str.extract(r'(?:Phường|Xã)\s*([^,]+)')
df['Ward'] = df['Ward'].str.strip()
df['District'] = df['Location'].str.extract(r'(?:Quận|Huyện)\s*([^,]+)')
df['District'] = df['District'].str.strip()
df.head()
```




<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Title</th>
      <th>Price</th>
      <th>Area</th>
      <th>Location</th>
      <th>Property Type</th>
      <th>Width</th>
      <th>Length</th>
      <th>Bedrooms</th>
      <th>Bathrooms</th>
      <th>Floors</th>
      <th>Ward</th>
      <th>District</th>
    </tr>
    <tr>
      <th>Listing ID</th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>1546393</th>
      <td>🏠 NHÀ 3 TẦNG – TRUNG TÂM PHƯỚC LONG B, THỦ ĐỨC</td>
      <td>7500</td>
      <td>95</td>
      <td>Phường Phước Long,TP. Hồ Chí Minh</td>
      <td>Nhà riêng</td>
      <td>5</td>
      <td>17</td>
      <td>3</td>
      <td>3</td>
      <td>3</td>
      <td>Phước Long</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>1528310</th>
      <td>🔥🔥 NHÀ ĐẸP HIỆP BÌNH PHƯỚC – HẺM XE HƠI – KHU ...</td>
      <td>4500</td>
      <td>66</td>
      <td>đường Hiệp Bình,Phường Hiệp Bình Chánh,Quận Th...</td>
      <td>Nhà riêng</td>
      <td>4</td>
      <td>NaN</td>
      <td>2</td>
      <td>NaN</td>
      <td>2</td>
      <td>Hiệp Bình Chánh</td>
      <td>Thủ Đức</td>
    </tr>
    <tr>
      <th>1546519</th>
      <td>🌟 HXH - NHÀ 3 TẦNG ĐẸP – TRUNG TÂM PHƯỚC LONG ...</td>
      <td>7500</td>
      <td>92</td>
      <td>Phường Phước Long B,Quận 9,TP. Hồ Chí Minh</td>
      <td>Nhà riêng</td>
      <td>5</td>
      <td>17</td>
      <td>3</td>
      <td>3</td>
      <td>3</td>
      <td>Phước Long B</td>
      <td>9</td>
    </tr>
    <tr>
      <th>1544240</th>
      <td>🏡 HÀNG HIẾM LINH CHIỂU – NHÀ 2 TẦNG – VỊ TRÍ V...</td>
      <td>4750</td>
      <td>45</td>
      <td>đường số 19,Phường Linh Chiểu,Quận Thủ Đức,TP....</td>
      <td>Nhà riêng</td>
      <td>4</td>
      <td>12</td>
      <td>3</td>
      <td>NaN</td>
      <td>2</td>
      <td>Linh Chiểu</td>
      <td>Thủ Đức</td>
    </tr>
    <tr>
      <th>1528291</th>
      <td>🚗 NHÀ ĐẸP HẺM XE HƠI – VỊ TRÍ VIP LINH TÂY – G...</td>
      <td>4800</td>
      <td>82</td>
      <td>đường số 9,Phường Linh Tây,Quận Thủ Đức,TP. Hồ...</td>
      <td>Nhà riêng</td>
      <td>8</td>
      <td>NaN</td>
      <td>2</td>
      <td>1</td>
      <td>1</td>
      <td>Linh Tây</td>
      <td>Thủ Đức</td>
    </tr>
  </tbody>
</table>
</div>



On Sep 2025, Saigon merged with multiple nearby province to form the new hcm city. The dataset had mixed of both the new addresses and the old addresses. I would have to transform the old addresses into new one.


```python
df['Area'].describe()
```




    count        51200
    mean         59952
    std        8904494
    min              1
    25%             79
    50%            125
    75%            378
    max     1578861170
    Name: Area, dtype: float64




```python
# The objective of this analysis is to find a living space, I would remove all entries with Area less than 20 and more than 1000. This is to avoid both mislabeled and cut off outliers
df = df[df['Area'].between(20,1000)]
```


```python
# Now to remove all duplicate offering, an agency could post the same property over and over again.
df = df.drop_duplicates(subset=['Title', 'Price', 'Area', 'Location','Property Type'])
```


```python
df['Title'].info()
```

    <class 'pandas.core.series.Series'>
    Index: 42002 entries, 1546393.0 to 1213837.0
    Series name: Title
    Non-Null Count  Dtype 
    --------------  ----- 
    42002 non-null  object
    dtypes: object(1)
    memory usage: 656.3+ KB
    


```python
# Looking good, i'll export the sheet and continue on Tableau for this project
df.to_excel('data_cleaned.xlsx')
```
