Problem Statement:
+ The company has developed a new web page in order to try and increase the number of users who "convert," meaning the number of users who decide to pay for the company's product.
+ Your goal is to work through this notebook to help the company understand if they should implement this new page, keep the old page, or perhaps run the experiment longer to make their decision.
+ The new landing page is marked as "new_page", while the existing page is marked as "old_page"

About the Dataset:
+ user_id: unique users number
+ timestamp: time
+ group: treatment and control group
+ landing_page: old_page and new_page
+ converted: Sign up status after viewing the page (0-1)

Hypothesis:
+ H0: There is no statistically significant difference between the old page and the new page in conversion rate.
+ H1: There is a statistically significant difference between the old page and the new page in conversion rate.

The hypothesis will be concluded based on the p_value obtained from the test:
+ If the p_value is less than 0.05, then reject H0 and accept H1.


```python
import pandas as pd
import numpy as np
from scipy import stats
import matplotlib.pyplot as plt
```


```python
# Dataset overview
df = pd.read_csv('ab_data.csv')
df.head()
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>user_id</th>
      <th>timestamp</th>
      <th>group</th>
      <th>landing_page</th>
      <th>converted</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>851104</td>
      <td>11:48.6</td>
      <td>control</td>
      <td>old_page</td>
      <td>0</td>
    </tr>
    <tr>
      <th>1</th>
      <td>804228</td>
      <td>01:45.2</td>
      <td>control</td>
      <td>old_page</td>
      <td>0</td>
    </tr>
    <tr>
      <th>2</th>
      <td>661590</td>
      <td>55:06.2</td>
      <td>treatment</td>
      <td>new_page</td>
      <td>0</td>
    </tr>
    <tr>
      <th>3</th>
      <td>853541</td>
      <td>28:03.1</td>
      <td>treatment</td>
      <td>new_page</td>
      <td>0</td>
    </tr>
    <tr>
      <th>4</th>
      <td>864975</td>
      <td>52:26.2</td>
      <td>control</td>
      <td>old_page</td>
      <td>1</td>
    </tr>
  </tbody>
</table>
</div>




```python
df.info()
```

    <class 'pandas.core.frame.DataFrame'>
    RangeIndex: 294480 entries, 0 to 294479
    Data columns (total 5 columns):
     #   Column        Non-Null Count   Dtype 
    ---  ------        --------------   ----- 
     0   user_id       294480 non-null  int64 
     1   timestamp     294480 non-null  object
     2   group         294480 non-null  object
     3   landing_page  294480 non-null  object
     4   converted     294480 non-null  int64 
    dtypes: int64(2), object(3)
    memory usage: 11.2+ MB
    


```python
df.isnull().sum()
```




    user_id         0
    timestamp       0
    group           0
    landing_page    0
    converted       0
    dtype: int64



+ No Null value in the dataset


```python
df.describe()
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>user_id</th>
      <th>converted</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>count</th>
      <td>294480.000000</td>
      <td>294480.000000</td>
    </tr>
    <tr>
      <th>mean</th>
      <td>787973.538896</td>
      <td>0.119658</td>
    </tr>
    <tr>
      <th>std</th>
      <td>91210.917091</td>
      <td>0.324562</td>
    </tr>
    <tr>
      <th>min</th>
      <td>630000.000000</td>
      <td>0.000000</td>
    </tr>
    <tr>
      <th>25%</th>
      <td>709031.750000</td>
      <td>0.000000</td>
    </tr>
    <tr>
      <th>50%</th>
      <td>787932.500000</td>
      <td>0.000000</td>
    </tr>
    <tr>
      <th>75%</th>
      <td>866911.250000</td>
      <td>0.000000</td>
    </tr>
    <tr>
      <th>max</th>
      <td>945999.000000</td>
      <td>1.000000</td>
    </tr>
  </tbody>
</table>
</div>




```python
df['landing_page'].value_counts()
```




    landing_page
    new_page    147241
    old_page    147239
    Name: count, dtype: int64



+ This is a roughly 50.01/49.99 split. This porpotion is acceptable 


```python
df.groupby('landing_page')['converted'].mean()
```




    landing_page
    new_page    0.118839
    old_page    0.120478
    Name: converted, dtype: float64



+ From the raw number, look like there is no significant difference in conversion rate between the new_page and old_page. Lets perform AB Testing to verify this.

+ Conversion has only 2 variable, therefore I will perform a Chi Square Test for this case: 


```python
crosstable = pd.crosstab(df['landing_page'],df['converted'])
crosstable
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th>converted</th>
      <th>0</th>
      <th>1</th>
    </tr>
    <tr>
      <th>landing_page</th>
      <th></th>
      <th></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>new_page</th>
      <td>129743</td>
      <td>17498</td>
    </tr>
    <tr>
      <th>old_page</th>
      <td>129500</td>
      <td>17739</td>
    </tr>
  </tbody>
</table>
</div>




```python
chi2, p_chi, dof, expected = stats.chi2_contingency(crosstable)
print(f"Chi-square p-value: {p_chi:.10f}")
print(f"Chi statistic: {chi2:.2f}")
```

    Chi-square p-value: 0.1725629856
    Chi statistic: 1.86
    

P-Value 0.17 is higher than 0.05.
+ Then we cannot reject the Null Hypothesis, there is no statistically significant difference between the new page and the old page in conversion rate
+ I could suggest the company to provide more data such as sales value to further determine if the new page is more profitable.
