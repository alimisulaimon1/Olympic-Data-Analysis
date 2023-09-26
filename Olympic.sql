USE Portfolio
GO

SELECT *
  FROM [Portfolio].[dbo].[athlete_events]
SELECT*     
  FROM [Portfolio].[dbo].[noc_regions]

--(1) Total games that have been played in olympic
--CREATE VIEW TotalGamePlayedinOlympic as
SELECT COUNT (DISTINCT Games ) AS total_olympic_game
  FROM [Portfolio].[dbo].[athlete_events]

  --(2) Total olympic hosted
SELECT COUNT (DISTINCT Year ) AS total_olympic_game
  FROM [Portfolio].[dbo].[athlete_events]
--(3) All olympic game held (year, season and city)
--CREATE VIEW AllOlympicHeld AS
SELECT  DISTINCT Year, Season, City
  FROM [Portfolio].[dbo].[athlete_events]
  ORDER BY Year;
--(4) Total number of countries who partipated in each olympic
--CREATE VIEW TotalCountriesinOlympic AS
SELECT  Games, COUNT(DISTINCT NOC) AS total_countries
   FROM [Portfolio].[dbo].[athlete_events]
   GROUP BY Games;

 --(5) highest and lowest country participation
-- CREATE VIEW HighestLowest AS
WITH all_count AS(
    SELECT  Games, region
    FROM [Portfolio].[dbo].[athlete_events]
	JOIN [Portfolio].dbo.noc_regions ON [Portfolio].dbo.noc_regions.NOC = [Portfolio].dbo.athlete_events.NOC
    GROUP BY Games, region),
	mmm AS(
select games,
			 count(1) as total_countries,
			 rank() over(order by count(1) desc) as first_rank,
			 rank() over(order by count(1) asc) as last_rank
	from all_count
group by games
	)
select 
	max(case when first_rank=1 then total_countries end ) as highest_countries,
	max(case when last_rank=1 then total_countries end) as lowest_countries
from mmm ;  

--(6) nation has participated in all of the olympic games- 
--CREATE VIEW CountriesPartipatedinAllOlympic AS
WITH game_tot AS (
      SELECT COUNT(DISTINCT Games) AS total_game
	   FROM [Portfolio].[dbo].[athlete_events]),
	   countries AS(
	   SELECT  Games, region AS country
       FROM [Portfolio].[dbo].[athlete_events]
	   JOIN [Portfolio].dbo.noc_regions ON [Portfolio].dbo.noc_regions.NOC = [Portfolio].dbo.athlete_events.NOC
       GROUP BY Games, region),
	   country_participated AS (
	   SELECT country, COUNT(1) AS total_participated_game
	   FROM countries
	   GROUP BY country)
SELECT *
FROM country_participated
JOIN game_tot ON game_tot.total_game = country_participated.total_participated_game
ORDER BY 1

--(7) total sport played in summer olympic
--CREATE VIEW TotalSportPlayedinSummerOlympic AS
SELECT Sport, count(distinct Games) AS no_of_games
FROM [Portfolio].[dbo].[athlete_events]
WHERE Season = 'Summer'
GROUP BY Sport;
--(8) sport which was played in all summer olympics
--CREATE VIEW SportPlayedinAllSummerOlympic AS
WITH total_sport AS(
SELECT distinct Games, Sport
FROM [Portfolio].[dbo].[athlete_events]
WHERE Season = 'Summer'),
game_tot AS (
      SELECT COUNT(DISTINCT Games) AS total_game
	   FROM [Portfolio].[dbo].[athlete_events]
	   WHERE Season = 'Summer'),
count_sport  AS(
       SELECT Sport, COUNT(1) as g_totla
	   FROM total_sport
	   GROUP BY sport)
SELECT *
FROM count_sport
JOIN game_tot ON game_tot.total_game = count_sport.g_totla;


--(9) Sports were just played only once in the olympics.
--CREATE VIEW SportPlayedonceinOlympic AS
SELECT Sport, count(distinct Games) AS no_of_games
FROM [Portfolio].[dbo].[athlete_events]
GROUP BY Sport
HAVING COUNT(DISTINCT Games) = 1;

--(10) total no of sports played in each olympic games.
--CREATE VIEW TotalSportPlayedineachOlympic AS
SELECT Games, count(distinct Sport) AS no_of_games
FROM [Portfolio].[dbo].[athlete_events]
GROUP BY Games
ORDER BY no_of_games DESC;

--(11) total no of sports played in each olympic games.
SELECT Games, COUNT( DISTINCT Sport) as played_time
 FROM [Portfolio].[dbo].[athlete_events]
 GROUP BY Games
 ORDER BY played_time DESC;

--(12) oldest athletes to win a gold medal
--CREATE VIEW OldestAthletesToWinGold AS
 WITH details AS
     (SELECT Name, Sex, cast(case when Age ='NA' then '0' else Age end as int) as age, Team, Games, City,Sport,Event,Medal
      FROM [Portfolio].[dbo].[athlete_events]),
	  Age_rank AS(
	  SELECT *, RANK() OVER(ORDER BY Age DESC) AS rnk
	  FROM details
	  WHERE Medal = 'Gold')
SELECT * FROM Age_rank
WHERE rnk = 1;
--(11) number of male to female
--CREATE VIEW MaleToFemale AS
  SELECT Sex, COUNT(Sex) as total_male 
  FROM [Portfolio].[dbo].[athlete_events]
  GROUP BY Sex;
--(12) Top 5 athletes and there sport who have won the most gold medals 
--CREATE VIEW Top5AthleteswithmostGold AS
 WITH details AS (
 SELECT name, Sport, region, COUNT(Medal) as total_gold
  FROM [Portfolio].[dbo].[athlete_events]
  JOIN [Portfolio].dbo.noc_regions ON [Portfolio].dbo.noc_regions.NOC = [Portfolio].dbo.athlete_events.NOC
  WHERE Medal ='Gold'
  GROUP BY name, region, Sport),
 -- ORDER BY total_gold DESC),
  ranking as (
   SELECT *, DENSE_RANK() OVER(ORDER BY total_gold desc) as rnk
   FROM details)
SELECT name, Sport, region, total_gold
FROM ranking
WHERE rnk <=5;


--(13) Fetch the top 5 athletes who have won the most medals 
--CREATE VIEW Top5AThleteswithmostmedal AS
WITH details AS (
 SELECT name, Sport, region, COUNT(Medal) as total_medal
  FROM [Portfolio].[dbo].[athlete_events]
  JOIN [Portfolio].dbo.noc_regions ON [Portfolio].dbo.noc_regions.NOC = [Portfolio].dbo.athlete_events.NOC
  WHERE Medal <> 'NA'
  GROUP BY name, region, Sport),
 -- ORDER BY total_gold DESC),
  ranking as (
   SELECT *, DENSE_RANK() OVER(ORDER BY total_medal desc) as rnk
   FROM details)
SELECT name, Sport, region, total_medal
FROM ranking
WHERE rnk <=5;


--(14) total gold, silver and bronze medals won by each country.
--CREATE VIEW GoldSilverBronzeWonbyCountry AS
WITH medal AS (
SELECT NOC,
CASE
	 WHEN Medal = 'Gold' THEN '1' ELSE 0
END AS Gold,
CASE
	 WHEN Medal = 'Silver' THEN '1' ELSE 0
END AS Silver,
CASE 
     WHEN Medal = 'Bronze' THEN '1' ELSE 0
END AS Bronze
   FROM [Portfolio].[dbo].[athlete_events]
),

detals AS(
SELECT region, SUM(Gold) AS Gold, SUM(Silver) AS Silver, SUM(Bronze) AS Bronze
FROM Medal
JOIN  [Portfolio].dbo.noc_regions ON [Portfolio].dbo.noc_regions.NOC = medal.NOC
GROUP BY region
)
SELECT region, Gold, Silver, Bronze, (Gold + Silver + Bronze) AS Total
FROM detals
ORDER BY Gold DESC

--(15) total gold, silver and bronze medals won by each country corresponding to each olympic games
--CREATE VIEW GoldSilverBronzewonineachSport AS
WITH GAMESS AS (
SELECT region, Games, Medal, COUNT(*) AS Total_medal
FROM [Portfolio].[dbo].[athlete_events]
JOIN [Portfolio].dbo.noc_regions ON [Portfolio].dbo.noc_regions.NOC = [Portfolio].dbo.athlete_events.NOC
WHERE Medal in ('Gold', 'Silver', 'Bronze')
GROUP BY region, Games, Medal
--ORDER BY Games asc
)
SELECT region, Games,
SUM(CASE WHEN Medal = 'Gold' THEN Total_medal ELSE 0 END ) Gold,
SUM(CASE WHEN Medal = 'Silver' THEN Total_medal ELSE 0 END) Silver,
SUM(CASE WHEN Medal = 'Bronze' THEN Total_medal ELSE 0 END) Bronze
FROM GAMESS
GROUP BY region, Games
ORDER BY Games asc, region asc, Gold desc, Silver desc, Bronze desc;

--(16) Male to female in olympic
--CREATE VIEW MaleFemaleinOlympic AS
WITH Female AS (
SELECT Year, Season, COUNT(DISTINCT ID) as Female
FROM [Portfolio].[dbo].[athlete_events]
WHERE Sex = 'F'
GROUP BY Season, Year),
--ORDER BY Year),
Male AS (
SELECT Year as yer, Season as sea, COUNT(DISTINCT ID) AS Male
FROM [Portfolio].[dbo].[athlete_events]
WHERE Sex = 'M'
GROUP BY Season, Year),
--ORDER BY Year),
Filte AS (
SELECT yer, Sea,
CASE WHEN  Female is NULL THEN 0
ELSE Female
END AS Female,
Male
FROM Male
LEFT JOIN Female ON Male.yer = Female.Year AND Male.Sea = Female.Season)
SELECT Yer as Year, Sea AS Season, Male, Female
FROM Filte;
--ORDER BY Year;


--(17) Gender Over Medal
--CREATE VIEW GenderOverMedal AS
WITH detals AS(
SELECT ID, Name, 
CASE 
    WHEN  sex = 'F' THEN 'FEMALE'
    ELSE 'MALE'
END AS Gender,
CASE 
	WHEN Medal = 'Gold' THEN '1'
	ELSE 0
END AS Gold,
CASE 
	WHEN Medal = 'Silver' THEN '1'
	ELSE 0
END AS Silver,
CASE 
	WHEN Medal = 'Bronze' THEN '1'
	ELSE 0
END AS Bronze
FROM [Portfolio].[dbo].[athlete_events]),
Final AS(
SELECT gender AS Gender, sum(GOLD) AS GOLD,sum(silver) AS SILVER, sum(bronze) AS BRONZE
FROM detals
GROUP BY gender)

SELECT *
FROM Final