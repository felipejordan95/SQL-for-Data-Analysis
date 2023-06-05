-- Select the data we are going to be using

SELECT 
	location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeadths
ORDER BY 1


-- Looking at Total Cases vs Total Deaths
--Shows likehood of dying if you contract covid in your country

SELECT 	location, date, total_cases, total_deaths, round((CAST(total_deaths AS REAL) / CAST(total_cases AS REAL)) * 100,2) AS DeathPercentage
FROM CovidDeadths
WHERE location ='Ecuador' AND continent NOT NULL
ORDER BY 1


-- Looking at Total Cases vs Population
--Show what % of population got covid

SELECT 	location, date, population, total_cases, (round((CAST(total_cases AS REAL) / CAST(population AS REAL)) * 100,2) AS PercentajePopulationInfected
FROM CovidDeadths
--WHERE location ='Ecuador'
WHERE continent is NOT NULL
Order by 1


-- Looking the countries with the highest Infection Rate compared to population

SELECT 	location, population, max(total_cases) as HighestInfectionCount, MAX(round((CAST(total_cases AS REAL) / CAST(population AS REAL)) * 100, 2)) AS PercentajePopulationInfected
FROM CovidDeadths
--WHERE location ='Ecuador'
WHERE continent is NOT NULL
GROUP By location
Order by PercentajePopulationInfected DESC


-- Showing countries wiuth the Highets Death Count per Population

SELECT 	location, population, max(total_deaths) as TotalDeathCount, MAX(round((CAST(total_deaths AS REAL) / CAST(population AS REAL)) * 100, 2)) AS PercentajeDeaths
FROM CovidDeadths
--WHERE location ='Ecuador'
WHERE continent is NOT NULL
GROUP By location
Order by TotalDeathCount DESC


--LET'S BREAK INTO DOWN BYT CONTINENT

SELECT 	location, max(total_deaths) as TotalDeathCount, MAX(round((CAST(total_deaths AS REAL) / CAST(population AS REAL)) * 100, 2)) AS PercentajeDeaths
FROM CovidDeadths
--WHERE location ='Ecuador'
WHERE continent is NULL
GROUP By location
Order by TotalDeathCount DESC

--SHOWING CONTINENTS WITH THE HIGGHEST DEATH COUNT PER POPULATION

SELECT 	continent, max(total_deaths) as TotalDeathCount
FROM CovidDeadths
--WHERE location ='Ecuador'
WHERE continent is NOT NULL 
GROUP By continent
Order by TotalDeathCount DESC


-- GLOBAL NUMBERS
SELECT
  sum(new_cases) as total_cases,
  sum(CAST(new_deaths AS INT)) as total_deaths,
  sum(CAST(new_deaths AS INT)) * 100.0 / sum(new_cases) as DeathPercentage
FROM
  CovidDeadths
WHERE
  continent IS NOT NULL
ORDER BY date


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT continent, location, date, population, new_vaccinations,
    (RollingPeopleVaccinated/population)*100 AS PercentageVaccinated
FROM (
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
        sum(CAST(vac.new_vaccinations as REAL)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
    FROM CovidDeadths dea
    JOIN CovidVaccinations vac 
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
) subquery
ORDER BY location, date
	

-- USE CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT continent, location, date, population, new_vaccinations,
    (RollingPeopleVaccinated/population)*100 AS PercentageVaccinated
FROM (
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
        sum(CAST(vac.new_vaccinations as REAL)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
    FROM CovidDeadths dea
    JOIN CovidVaccinations vac 
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
) subquery
ORDER BY location, date
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--TEMP TABLE

DROP TABLE if exists PercentajePopulationVaccianted
CREATE TABLE PercentajePopulationVaccianted
(
continent TEXT,
location TEXT,
date datetime,
Population NUMERIC,
new_vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
);

INSERT INTO PercentajePopulationVaccianted
SELECT continent, location, date, population, new_vaccinations,
    (RollingPeopleVaccinated/population)*100 AS PercentageVaccinated
FROM (
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
        sum(CAST(vac.new_vaccinations as REAL)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
    FROM CovidDeadths dea
    JOIN CovidVaccinations vac 
        ON dea.location = vac.location
        AND dea.date = vac.date
    --WHERE dea.continent IS NOT NULL
); 

Select *, (RollingPeopleVaccinated/Population)*100
From PercentajePopulationVaccianted


--Creating view to store data fro later visualizations
DROP TABLE IF EXISTS PercentajePopulationVaccianted;
CREATE TABLE PercentajePopulationVaccianted AS
SELECT continent, location, date, population, new_vaccinations,
    (RollingPeopleVaccinated/population)*100 AS PercentageVaccinated
FROM (
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
        sum(CAST(vac.new_vaccinations AS REAL)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
    FROM CovidDeadths dea
    JOIN CovidVaccinations vac 
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
);

SELECT * FROM PercentajePopulationVaccianted