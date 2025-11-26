### Code Challenge

1\. Data Integrity Checking & Cleanup

- Alphabetically list all of the country codes in the continent_map table that appear more than once. Display any values where country_code is null as country_code = "FOO" and make this row appear first in the list, even though it should alphabetically sort to the middle. Provide the results of this query as your answer.

```sql
SELECT
  country_code
FROM
  continent_map
GROUP BY
  country_code
HAVING
  COUNT(*) > 1
ORDER BY
  CASE
    WHEN country_code IS NULL THEN 0
    WHEN country_code = 'FOO' THEN 1
    ELSE 2
  END,
  country_code;
```

#### Result Set:

| country_code |
|--------------|
| ARM          |
| AZE          |
| CYP          |
| GEO          |
| KAZ          |
| RUS          |
| TUR          |
| UMI          |

***

- For all countries that have multiple rows in the continent_map table, delete all multiple records leaving only the 1 record per country. The record that you keep should be the first one when sorted by the continent_code alphabetically ascending. Provide the query/ies and explanation of step(s) that you follow to delete these records.

```sql
DELETE FROM continent_map
WHERE
  (country_code, continent_code) IN (
    SELECT
      country_code,
      continent_code
    FROM
      (
        SELECT
          country_code,
          continent_code,
          ROW_NUMBER() OVER (
            PARTITION BY
              country_code
            ORDER BY
              continent_code
          ) rn -- This would sort the continent_code alphabetically in case a country appears multiple times
        FROM
          continent_map
      ) t
    WHERE
      rn IN (2, 3) -- Only take the duplicated country_code with continent_code not on the first alphabetically
  );
```

2\. List the countries ranked 10-12 in each continent by the percent of year-over-year growth descending from 2011 to 2012.

The percent of growth should be calculated as: ((2012 gdp - 2011 gdp) / 2011 gdp)

The list should include the columns:

- rank
- continent_name
- country_code
- country_name
- growth_percent

```sql
WITH
  cte_2011 AS (
    SELECT
      cont.continent_name,
      c.country_code,
      gdp.year,
      ROUND(SUM(gdp.gdp_per_capita), 2) AS total_gdp
    FROM
      braintree.countries AS c
      LEFT JOIN braintree.per_capita AS gdp ON gdp.country_code = c.country_code
      LEFT JOIN braintree.continent_map AS map ON c.country_code = map.country_code
      LEFT JOIN braintree.continents AS cont ON cont.continent_code = map.continent_code
    WHERE
      YEAR IN (2011)
    GROUP BY
      1,
      2,
      3
  ),
  cte_2012 AS (
    SELECT
      cont.continent_name,
      c.country_code,
      gdp.year,
      ROUND(SUM(gdp.gdp_per_capita), 2) AS total_gdp
    FROM
      braintree.countries AS c
      LEFT JOIN braintree.per_capita AS gdp ON gdp.country_code = c.country_code
      LEFT JOIN braintree.continent_map AS map ON c.country_code = map.country_code
      LEFT JOIN braintree.continents AS cont ON cont.continent_code = map.continent_code
    WHERE
      YEAR IN (2012)
    GROUP BY
      1,
      2,
      3
  ),
  ranked AS (
    SELECT
      a.continent_name,
      a.country_code,
      a.total_gdp AS '2012gdp',
      b.total_gdp AS '2011gdp',
      ROUND(
        (a.total_gdp - b.total_gdp) / b.total_gdp * 100,
        2
      ) AS growth_percent,
      DENSE_RANK() OVER (
        PARTITION BY
          a.continent_name
        ORDER BY
          (a.total_gdp - b.total_gdp) / b.total_gdp * 100
      ) AS growth_rank
    FROM
      cte_2012 AS b
      JOIN cte_2011 AS a ON COALESCE(b.country_code, '') = COALESCE(a.country_code, '')
  )
SELECT
  *
FROM
  ranked
WHERE
  growth_rank <= 12
  AND growth_rank >= 10
  AND continent_name IS NOT NULL
ORDER BY
  continent_name,
  growth_rank;
```

#### Result Set:

| continent_name | country_code | 2012gdp  | 2011gdp  | growth_percent | growth_rank |
|----------------|--------------|----------|----------|----------------|-------------|
| Africa         | RWA          | 570.17   | 619.93   | -8.03          | 10          |
| Africa         | GIN          | 454.00   | 491.79   | -7.68          | 11          |
| Africa         | NGA          | 2518.63  | 2722.30  | -7.48          | 12          |
| Asia           | UZB          | 1544.83  | 1716.66  | -10.01         | 10          |
| Asia           | IRQ          | 6019.42  | 6625.22  | -9.14          | 11          |
| Asia           | PHL          | 2357.57  | 2587.02  | -8.87          | 12          |
| Europe         | MNE          | 7253.45  | 7041.22  | 3.01           | 10          |
| Europe         | SWE          | 56755.33 | 55039.57 | 3.12           | 11          |
| Europe         | ISL          | 44030.58 | 42339.46 | 3.99           | 12          |
| North America  | GTM          | 3242.69  | 3330.53  | -2.64          | 10          |
| North America  | HND          | 2261.65  | 2322.88  | -2.64          | 11          |
| North America  | ATG          | 12420.16 | 12733.49 | -2.46          | 12          |
| Oceania        | FJI          | 4324.69  | 4467.10  | -3.19          | 10          |
| Oceania        | TUV          | 3993.65  | 4044.19  | -1.25          | 11          |
| Oceania        | KIR          | 1735.55  | 1736.20  | -0.04          | 12          |
| South America  | ARG          | 10951.58 | 11573.06 | -5.37          | 10          |
| South America  | PRY          | 3956.73  | 3813.47  | 3.76           | 11          |
| South America  | BRA          | 12575.98 | 11339.52 | 10.90          | 12          |

***

3\. For the year 2012, create a 3 column, 1 row report showing the percent share of gdp_per_capita for the following regions:

(i) Asia, (ii) Europe, (iii) the Rest of the World. Your result should look something like

 Asia  | Europe | Rest of World 
------ | ------ | -------------
25.0%  | 25.0%  | 50.0%

```sql

```

#### Result Set:



***

4a\. What is the count of countries and sum of their related gdp_per_capita values for the year 2007 where the string 'an' (case insensitive) appears anywhere in the country name?

```sql
SELECT
  c.*,
  ROUND(gdp.gdp_per_capita, 2) AS '2007gdp'
FROM
  countries AS c
  LEFT JOIN per_capita AS gdp ON gdp.country_code = c.country_code
WHERE
  BINARY country_name LIKE '%an%'
  AND YEAR = 2007
ORDER BY
  1;
```

#### Result Set:

| country_code | country_name                                   | 2007gdp   |
|--------------|------------------------------------------------|-----------|
| AFG          | Afghanistan                                    | 373.59    |
| AGO          | Angola                                         | 3412.72   |
| ALB          | Albania                                        | 3380.89   |
| AND          | Andorra                                        | 39922.89  |
| ATG          | Antigua and Barbuda                            | 15353.91  |
| AZE          | Azerbaijan                                     | 3851.33   |
| BGD          | Bangladesh                                     | 467.14    |
| BIH          | Bosnia and Herzegovina                         | 3949.84   |
| BTN          | Bhutan                                         | 1760.60   |
| BWA          | Botswana                                       | 5711.73   |
| CAF          | Central African Republic                       | 413.48    |
| CAN          | Canada                                         | 43300.56  |
| CHE          | Switzerland                                    | 59663.77  |
| CHI          | Channel Islands                                | 73577.17  |
| CSS          | Caribbean small states                         | 8647.68   |
| DEU          | Germany                                        | 40402.99  |
| DOM          | Dominican Republic                             | 4297.52   |

***

4b\. Repeat question 4a, but this time make the query case sensitive.

```sql
SELECT
  c.*,
  ROUND(gdp.gdp_per_capita, 2) AS '2007gdp'
FROM
  countries AS c
  LEFT JOIN per_capita AS gdp ON gdp.country_code = c.country_code
WHERE
  BINARY country_name LIKE BINARY '%an%'
  AND YEAR = 2007
ORDER BY
  1;
```

#### Result Set:

| country_code | country_name                                   | 2007gdp   |
|--------------|------------------------------------------------|-----------|
| AFG          | Afghanistan                                    | 373.59    |
| ALB          | Albania                                        | 3380.89   |
| ATG          | Antigua and Barbuda                            | 15353.91  |
| AZE          | Azerbaijan                                     | 3851.33   |
| BGD          | Bangladesh                                     | 467.14    |
| BIH          | Bosnia and Herzegovina                         | 3949.84   |
| BTN          | Bhutan                                         | 1760.60   |
| BWA          | Botswana                                       | 5711.73   |
| CAF          | Central African Republic                       | 413.48    |
| CAN          | Canada                                         | 43300.56  |
| CHE          | Switzerland                                    | 59663.77  |
| CHI          | Channel Islands                                | 73577.17  |
| CSS          | Caribbean small states                         | 8647.68   |
| DEU          | Germany                                        | 40402.99  |
| DOM          | Dominican Republic                             | 4297.52   |
| EUU          | European Union                                 | 34097.25  |
| FIN          | Finland                                        | 46538.17  |
| FRA          | France                                         | 40341.92  |

***

5\. Find the sum of gpd_per_capita by year and the count of countries for each year that have non-null gdp_per_capita where (i) the year is before 2012 and (ii) the country has a null gdp_per_capita in 2012. Your result should have the columns:

- year
- country_count
- total

```sql
SELECT
  gdp.year,
  COUNT(country_name) AS country_count,
  ROUND(SUM(gdp.gdp_per_capita), 2) AS total
FROM
  countries AS c
  LEFT JOIN per_capita AS gdp ON gdp.country_code = c.country_code
WHERE
  gdp.year < 2012
  AND gdp_per_capita IS NOT NULL
GROUP BY
  1
ORDER BY
  1,
  3 DESC;
```

#### Result Set:

| year | country_count | total        |
|------|---------------|--------------|
| 2004 | 230           | 2451335.96   |
| 2005 | 230           | 2652533.50   |
| 2006 | 229           | 2884162.79   |
| 2007 | 229           | 3297093.12   |
| 2008 | 226           | 3475081.40   |
| 2009 | 225           | 3044608.31   |
| 2010 | 220           | 2912949.51   |
| 2011 | 220           | 3234343.25   |

***

6\. All in a single query, execute all of the steps below and provide the results as your final answer:

a. create a single list of all per_capita records for year 2009 that includes columns:

- continent_name
- country_code
- country_name
- gdp_per_capita

b. order this list by:

- continent_name ascending
- characters 2 through 4 (inclusive) of the country_name descending

c. create a running total of gdp_per_capita by continent_name

d. return only the first record from the ordered list for which each continent's running total of gdp_per_capita meets or exceeds $70,000.00 with the following columns:

- continent_name
- country_code
- country_name
- gdp_per_capita
- running_total

```sql
SELECT
  continent_name,
  country_code,
  country_name,
  running_total_gdp
FROM
  (
    SELECT
      COALESCE(cont.continent_name, 'Unknown') AS continent_name,
      c.country_code,
      c.country_name,
      gdp.gdp_per_capita,
      SUM(gdp.gdp_per_capita) OVER (
        PARTITION BY
          COALESCE(cont.continent_name, 'Unknown')
      ) AS running_total_gdp,
      ROW_NUMBER() OVER (
        PARTITION BY
          COALESCE(cont.continent_name, 'Unknown')
        ORDER BY
          SUBSTRING(c.country_name, 2, 3) DESC
      ) AS row_num
    FROM
      countries AS c
      LEFT JOIN continent_map AS map ON c.country_code = map.country_code
      LEFT JOIN continents AS cont ON cont.continent_code = map.continent_code
      LEFT JOIN per_capita AS gdp ON gdp.country_code = c.country_code
    WHERE
      gdp.year = 2009
    ORDER BY
      1 ASC,
      SUBSTRING(c.country_name, 2, 3) DESC
  ) AS ranked
WHERE
  row_num = 1
  AND running_total_gdp > 70000;
```

#### Result Set:

| continent_name | country_code | country_name      | running_total_gdp   |
|----------------|--------------|-------------------|---------------------|
| Africa         | SWZ          | Swaziland         | 117970.13           |
| Asia           | AZE          | Azerbaijan        | 534788.07           |
| Europe         | CZE          | Czech Republic    | 1382875.77          |
| North America  | PRI          | Puerto Rico       | 405923.89           |
| Oceania        | TUV          | Tuvalu            | 103764.60           |
| South America  | GUY          | Guyana            | 74829.45            |
| Unknown        | EUU          | European Union    | 424456.40           |

***

7\. Find the country with the highest average gdp_per_capita for each continent for all years. Now compare your list to the following data set. Please describe any and all mistakes that you can find with the data set below. Include any code that you use to help detect these mistakes.

rank | continent_name | country_code | country_name | avg_gdp_per_capita 
---- | -------------- | ------------ | ------------ | -----------------
   1 | Africa         | SYC          | Seychelles   |         $11,348.66
   1 | Asia           | KWT          | Kuwait       |         $43,192.49
   1 | Europe         | MCO          | Monaco       |        $152,936.10
   1 | North America  | BMU          | Bermuda      |         $83,788.48
   1 | Oceania        | AUS          | Australia    |         $47,070.39
   1 | South America  | CHL          | Chile        |         $10,781.71

   ```sql

```

#### Result Set:



***