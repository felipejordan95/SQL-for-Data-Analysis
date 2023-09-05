-- 1. Consolidating data into one table
-- Creating a new table to allow data from different files
CREATE TABLE Divvy_Trips_2019_all ( 
	   [trip_id] int
      ,[start_time] datetime2
      ,[end_time] datetime2
      ,[ride_length] nvarchar(50)
      ,[day_of_week] tinyint 
      ,[bikeid] smallint
      ,[tripduration] float
      ,[from_station_id] smallint
      ,[from_station_name] nvarchar(50)
      ,[to_station_id] smallint
      ,[to_station_name] nvarchar(50)
      ,[usertype] nvarchar(50)
      ,[gender] nvarchar(50)
      ,[birthyear] smallint
);
------------------Adding ride_length & day of week column to table Q2, Q3, Q4-------------------------

-- Adding columns
ALTER TABLE Divvy_Trips_2019_Q4
ADD ride_length nvarchar(50),
	day_of_week tinyint;

-- Calculating new columns
UPDATE Divvy_Trips_2019_Q4
SET ride_length =
    RIGHT('0' + CAST(DATEDIFF(SECOND, start_time, end_time) / 3600 AS VARCHAR), 2) + ':' +
    RIGHT('0' + CAST((DATEDIFF(SECOND, start_time, end_time) % 3600) / 60 AS VARCHAR), 2) + ':' +
    RIGHT('0' + CAST(DATEDIFF(SECOND, start_time, end_time) % 60 AS VARCHAR), 2);


--day_of_week
UPDATE [Projects].[dbo].[Divvy_Trips_2019_all]
SET [day_of_week] = DATEPART(WEEKDAY, [start_time])
      

select top 1000 * 
From Divvy_Trips_2019_all

--------------------------------Adding data to merged table----------------------------------

-- Insert Data from this table Q1
insert into Divvy_Trips_2019_all
select * from Divvy_Trips_2019_Q1

-- Insert Data from this table Q2
insert into Divvy_Trips_2019_all
	(
		trip_id, 
		start_time, 
		end_time,
		ride_length, 
		day_of_week, 
		bikeid, 
		tripduration, 
		from_station_id,
		from_station_name,
		to_station_id,
		to_station_name,
		usertype,
		gender,
		birthyear
	)
select
	trip_id, 
	start_time, 
	end_time,
	ride_length, 
	day_of_week, 
	bikeid, 
	tripduration, 
	from_station_id,
	from_station_name,
	to_station_id,
	to_station_name,
	usertype,
	gender,
	birthday_year	
from Divvy_Trips_2019_Q2;

-- Insert Data from this table Q3
insert into Divvy_Trips_2019_all
	(
		trip_id, 
		start_time, 
		end_time,
		ride_length, 
		day_of_week, 
		bikeid, 
		tripduration, 
		from_station_id,
		from_station_name,
		to_station_id,
		to_station_name,
		usertype,
		gender,
		birthyear
	)
select
	trip_id, 
	start_time, 
	end_time,
	ride_length, 
	day_of_week, 
	bikeid, 
	tripduration, 
	from_station_id,
	from_station_name,
	to_station_id,
	to_station_name,
	usertype,
	gender,
	birthyear	
from Divvy_Trips_2019_Q3;

-- Insert Data from this table Q4
insert into Divvy_Trips_2019_all
	(
		trip_id, 
		start_time, 
		end_time,
		ride_length, 
		day_of_week, 
		bikeid, 
		tripduration, 
		from_station_id,
		from_station_name,
		to_station_id,
		to_station_name,
		usertype,
		gender,
		birthyear
	)
select
	trip_id, 
	start_time, 
	end_time,
	ride_length, 
	day_of_week, 
	bikeid, 
	tripduration, 
	from_station_id,
	from_station_name,
	to_station_id,
	to_station_name,
	usertype,
	gender,
	birthyear	
from Divvy_Trips_2019_Q4;

-- 2.Renaming columns names

EXEC sp_rename 'Divvy_Trips_2019_all.bikeid', 'bike_id', 'COLUMN';
EXEC sp_rename 'Divvy_Trips_2019_all.tripduration', 'trip_duration', 'COLUMN';
EXEC sp_rename 'Divvy_Trips_2019_all.usertype', 'user_type', 'COLUMN';
EXEC sp_rename 'Divvy_Trips_2019_all.birthyear', 'birth_year', 'COLUMN';

select top 100 * from  Divvy_Trips_2019_all

-- 3. Null Values

 -- Total records: 3,818,004
Select user_type
	,gender
	,birth_year
from Divvy_Trips_2019_all
where user_type is null
	or gender is null
	or birth_year is null
 -- Records with null values: 559,208
-- Filling NULL VALUES
 UPDATE [Projects].[dbo].[Divvy_Trips_2019_all]
SET [gender] = 'Unknown', [birth_year] = 0
WHERE [gender] IS NULL OR [birth_year] IS NULL

-- 4. Detecting Outliers

;with Zscore_table as
	(
		SELECT *, 
				ABS(([trip_duration] - AVG([trip_duration]) OVER ()) / STDEV([trip_duration]) OVER ()) as Zscore
		FROM [Projects].[dbo].[Divvy_Trips_2019_all]
	)
select * 
from Zscore_table
where Zscore >3
order by Zscore DESC

-- Deleting outliers
-- Identify and remove outliers in trip_duration column using Z-score
DECLARE @ZScoreThreshold FLOAT = 3.0;

WITH OutlierStats AS (
    SELECT
        [trip_id],
        [trip_duration],
        AVG([trip_duration]) OVER () AS avg_duration,
        STDEV([trip_duration]) OVER () AS stdev_duration
    FROM [Projects].[dbo].[Divvy_Trips_2019_all]
)
DELETE FROM OutlierStats
WHERE ABS(([trip_duration] - avg_duration) / stdev_duration) > @ZScoreThreshold;

 -- Total records: 3,816,317
select count(*) from Divvy_Trips_2019_all
