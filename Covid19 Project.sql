SELECT*
from covid_death
order by 1,2


-- Death percentage is the proportion of death in that country for those that contracted covid
-- Also the likelihood ratio that a person will die if contracted with covid
SELECT 
    location, date, total_cases, total_deaths,population, 
    ROUND((CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)) * 100, 2) as death_perc
FROM 
    covid_death
WHERE 
    location LIKE '%STATE%' 
ORDER BY 
    1, 2;


-- proportion of covid cases in US population
SELECT 
    location, date, total_cases,population, 
    ROUND((CAST(total_cases AS FLOAT) / CAST(population AS FLOAT)) * 100, 2) as covid_perc
FROM 
    covid_death
WHERE 
    location LIKE '%STATE%' 
ORDER BY 
    1, 2;


-- countries with highest infection rate
SELECT 
    location, MAX(total_cases) as max_cases,population, 
    MAX(ROUND((CAST(total_cases AS FLOAT) / CAST(population AS FLOAT)) * 100, 2)) as max_covid_perc
FROM 
    covid_death
GROUP BY location, population
ORDER BY max_covid_perc desc 


-- countries with highest death count by country
SELECT 
    location, MAX(cast(total_deaths as int)) as max_death 
from covid_death
WHERE continent is not null
GROUP BY location
ORDER BY max_death desc


-- countries with highest death count by continent
SELECT 
    continent, MAX(cast(total_deaths as int)) as max_death 
from covid_death
WHERE continent is not null
GROUP BY continent
ORDER BY max_death desc


-- Total number of deaths with covid 19 cases
SELECT  
    SUM(new_cases) as total_cases, 
    SUM(new_deaths) as total_deaths, 
    ROUND((SUM(new_deaths) / (SUM(new_cases)) * 100), 2) as perc_death
FROM covid_death
WHERE continent IS NOT NULL 
 

 -- Total population vs vaccination
 SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
 FROM covid_death d
 JOIN covid_vaccination v
 ON d.location = v.location	
 AND d.date = v.date
 WHERE d.continent is not null	
 order by 2,3


 SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
 SUM(cast(v.new_vaccinations as bigint)) OVER (Partition by d.location order by d.location, d.date) as total_vaccination
 FROM covid_death d
 JOIN covid_vaccination v
 ON d.location = v.location	
 AND d.date = v.date
 WHERE d.continent is not null	
 order by 2,3


 --CTE Common Table Expression 
 WITH vaccinationCTE AS 
 (
 SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
 SUM(cast(v.new_vaccinations as bigint)) OVER (Partition by d.location order by d.location, d.date) as total_vaccination
 FROM covid_death d
 JOIN covid_vaccination v
 ON d.location = v.location	
 AND d.date = v.date
 WHERE d.continent is not null
 )
 SELECT continent,location,date, ROUND((total_vaccination/population)*100, 2) as total_vacination_perc
 FROM vaccinationCTE


 -- TEMP TABLE
 DROP TABLE IF EXISTS #total_perc_vaccinated
 CREATE TABLE #total_perc_vaccinated
 (
 continent nvarchar(255),
 location nvarchar(255),
 Date datetime,
 population numeric,
 new_vaccinations numeric,
 total_vaccination numeric
 )

 INSERT INTO #total_perc_vaccinated

 SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
 SUM(cast(v.new_vaccinations as bigint)) OVER (Partition by d.location order by d.location, d.date) as total_vaccination
 FROM covid_death d
 JOIN covid_vaccination v
 ON d.location = v.location	
 AND d.date = v.date
 WHERE d.continent is not null

 SELECT *, ROUND((total_vaccination/population)*100, 2) as total_vacination_perc
 FROM #total_perc_vaccinated


 -- Create view to store data permanently and also to use for visualisation
CREATE VIEW perc_vaccinated as 
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
 SUM(cast(v.new_vaccinations as bigint)) OVER (Partition by d.location order by d.location, d.date) as total_vaccination
 FROM covid_death d
 JOIN covid_vaccination v
 ON d.location = v.location	
 AND d.date = v.date
 WHERE d.continent is not null

 -- create view is permanent, unlike temp and CTE
 SELECT *
 FROM perc_vaccinated










