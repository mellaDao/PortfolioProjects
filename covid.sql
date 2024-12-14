SELECT *
FROM PortfolioProject..CovidDeaths
where continent is not null
ORDER BY 3,4;

/*
SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4;
*/

-- Select data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2;

-- Looking at Total Cases vs Total Deaths in Canada
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS deaths_percentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'Canada'
ORDER BY 1,2;

-- Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT location, date, total_cases, population, (total_cases/population)*100 AS percent_population_infected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Looking at Countries with highest infection rate compared to population
SELECT location, MAX(total_cases) as highest_infection_count, population, MAX((total_cases/population))*100 AS percent_population_infected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY percent_population_infected DESC;

-- Looking at Countries with highest death count compared to population
SELECT location, MAX(cast(total_deaths as int)) as highest_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY highest_death_count DESC;

-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Looking at Countries with highest death count compared to population (Incorrect)
SELECT continent, MAX(cast(total_deaths as int)) as highest_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY highest_death_count DESC;

-- Looking at Countries with highest death count compared to population (Correct)
SELECT location, MAX(cast(total_deaths as int)) as highest_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY highest_death_count DESC;

-- GLOBAL NUMBERS BY DATE
SELECT date, SUM(new_cases) as sum_cases, SUM(cast(new_deaths as int)) as sum_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100  AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

--GLOBAL NUMBERS
SELECT SUM(new_cases) as sum_cases, SUM(cast(new_deaths as int)) as sum_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100  AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Looking at total population vs vaccinations (USE CTE option 1)
WITH PopvsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS (
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(cast(v.new_vaccinations as int)) OVER (Partition by d.location ORDER BY d.location, d.date) AS rolling_people_vaccinated
--,rolling_people_vaccinated/d.population * 100 
FROM PortfolioProject..CovidDeaths d 
JOIN PortfolioProject..CovidVaccinations v 
ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
--ORDER BY 1,2,3
)
SELECT *, rolling_people_vaccinated/population * 100 AS percent_rolling_vacccinated FROM PopvsVac;

-- Looking at total population vs vaccinations (USE temp table option 2)
-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated 
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingPoepleVaccinated numeric
)

-- Insert values into temp table
INSERT INTO #PercentPopulationVaccinated
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(cast(v.new_vaccinations as int)) OVER (Partition by d.location ORDER BY d.location, d.date) AS rolling_people_vaccinated
--,rolling_people_vaccinated/d.population * 100 
FROM PortfolioProject..CovidDeaths d 
JOIN PortfolioProject..CovidVaccinations v 
ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY 1,2,3

SELECT *, RollingPoepleVaccinated/population * 100 AS percent_rolling_vacccinated FROM #PercentPopulationVaccinated;

-- Creating View to store data for later visualization for PercentPopulationVaccinated
CREATE VIEW PercentPopulationVaccinated AS
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(cast(v.new_vaccinations as int)) OVER (Partition by d.location ORDER BY d.location, d.date) AS rolling_people_vaccinated
--,rolling_people_vaccinated/d.population * 100 
FROM PortfolioProject..CovidDeaths d 
JOIN PortfolioProject..CovidVaccinations v 
ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
--ORDER BY 1,2,3

Select * FROM PercentPopulationVaccinated;

-- CREATE VIEW to store data for later visualization for PercentPopulationVaccinated
CREATE VIEW PercentPopulationVaccinated AS
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(cast(v.new_vaccinations as int)) OVER (Partition by d.location ORDER BY d.location, d.date) AS rolling_people_vaccinated
--,rolling_people_vaccinated/d.population * 100 
FROM PortfolioProject..CovidDeaths d 
JOIN PortfolioProject..CovidVaccinations v 
ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
--ORDER BY 1,2,3

Select * FROM PercentPopulationVaccinated;

-- CREATE VIEW to show likelihood of dying if you contract covid in your country
CREATE VIEW PercentDeathLikelihood AS
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS deaths_percentage
FROM PortfolioProject..CovidDeaths;

Select * FROM PercentDeathLikelihood;

-- CREATE VIEW to show what percentage of population got Covid
CREATE VIEW PercentCovid AS
SELECT location, date, total_cases, population, (total_cases/population)*100 AS percent_population_infected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL;

-- CREATE VIEW to show Countries with highest infection rate compared to population
CREATE VIEW PercentPopulationInfected AS
SELECT location, MAX(total_cases) as highest_infection_count, population, MAX((total_cases/population))*100 AS percent_population_infected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population;

-- CREATE VIEW to show Countries with highest death count compared to population
CREATE VIEW DeathCount AS
SELECT location, MAX(cast(total_deaths as int)) as highest_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location;

















