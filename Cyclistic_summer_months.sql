SELECT
  TRIPS.usertype, -- Types of users
  ZIPSTART.zip_code AS zip_code_start, -- Zip code of start station
  ZIPSTARTNAME.borough AS borough_start, -- Borough of start station
  ZIPSTARTNAME.neighborhood AS neighborhood_start, -- Neighborhood of start station
  ZIPEND.zip_code AS zip_code_end, -- Zip code of end station
  ZIPENDNAME.borough borough_end,-- Borough of end station
  ZIPENDNAME.neighborhood AS neighborhood_end, -- Neighborhood of end station
  
  -- Since this is a fictional dashboard, we add 5 years to make it look recent
  
  DATE_ADD(DATE(TRIPS.starttime), INTERVAL 5 YEAR) AS start_day, -- extracted the date from 'starttime' and added 5 years to make closer to today
  DATE_ADD(DATE(TRIPS.stoptime), INTERVAL 5 YEAR) AS stop_day, -- extracted the date from 'starttime' and added 5 years to make closer to today

  WEATHER.temp AS day_mean_temperature, -- Mean temperature
  WEATHER.wdsp AS day_mean_wind_speed, -- Mean wind speed
  WEATHER.prcp AS day_total_precipitation, -- Total precipitation

  -- Grouped trips into 10 minute intervals to reduces the number of rows
  ROUND(CAST(TRIPS.tripduration / 60 AS INT64), -1) AS trip_minutes, -- divided by tripduration by 60 to translate seconds to minutes; cased to integer data type; rounded the numbers to -1 decimal point i.e. grouped by 10 minute intervals

  COUNT(TRIPS.bikeid) AS trip_count
FROM
  `bigquery-public-data.new_york_citibike.citibike_trips` AS TRIPS

INNER JOIN
  `bigquery-public-data.geo_us_boundaries.zip_codes` ZIPSTART
  ON ST_WITHIN(
    ST_GEOGPOINT(TRIPS.start_station_longitude, TRIPS.start_station_latitude),
    ZIPSTART.zip_code_geom)
-- ST_GEOPOINT creates GEOGRAPHY value based on longitude and latitude; ST_WITHIN makes sure that geographies within are intersecting

INNER JOIN
  `bigquery-public-data.geo_us_boundaries.zip_codes` ZIPEND
  ON ST_WITHIN(
    ST_GEOGPOINT(TRIPS.end_station_longitude, TRIPS.end_station_latitude),
    ZIPEND.zip_code_geom)
-- ST_GEOPOINT creates GEOGRAPHY value based on longitude and latitude; ST_WITHIN makes sure that geographies within are intersecting

INNER JOIN
  `bigquery-public-data.noaa_gsod.gsod20*` AS WEATHER
  ON PARSE_DATE("%Y%m%d", CONCAT(WEATHER.year, WEATHER.mo, WEATHER.da)) = DATE(TRIPS.starttime)
-- Concatenated year, month and date into one attribute, then using PARSE_DATE, changed the date format to %Y%m%d

INNER JOIN
  `omega-iterator-385410.cyclistic_nyc.nyc_zip_codes` AS ZIPSTARTNAME
  ON ZIPSTART.zip_code = CAST(ZIPSTARTNAME.zip AS STRING)
-- used CAST function to translate zip to the same format as zip_code

INNER JOIN
  `omega-iterator-385410.cyclistic_nyc.nyc_zip_codes` AS ZIPENDNAME
  ON ZIPEND.zip_code = CAST(ZIPENDNAME.zip AS STRING)
-- used CAST function to translate zip to the same format as zip_code

WHERE

-- Take the weather from one weather station
  WEATHER.wban = '94728' -- NEW YORK CENTRAL PARK
 -- Use data for three summer months
AND DATE(TRIPS.starttime) BETWEEN DATE('2015-07-01') AND DATE('2015-09-30')
GROUP BY
  1,
  2,
  3,
  4,
  5,
  6,
  7,
  8,
  9,
  10,
  11,
  12,
  13