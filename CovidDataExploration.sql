-- We will explore COVID-19 Dataset in this project
-- At first we'll explore CovidDeaths Dataset

SELECT *
FROM CovidDeaths
ORDER BY 3,4

SELECT *
FROM CovidVaccinations
ORDER BY 3,4

-- Select the data that we are going to be using
SELECT location, date, new_cases, total_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases VS Total Deaths
-- Shows Likelihood of dying if you contract Covid in Pakistan
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location = 'Pakistan'
ORDER BY 1,2

-- Looking at Total Cases VS Population
-- Shows what percentage of population got Covid
SELECT location, date, total_cases, population, (total_cases/population)*100 AS DeathPercentage
FROM CovidDeaths
--WHERE location = 'Pakistan'
ORDER BY 1,2

-- Looking at Countries with Highest Infection rate compared to Population
SELECT location, population, MAX(total_cases) AS TotalCases, (MAX(total_cases)/population)*100 AS CasesPercentByPopulation
FROM CovidDeaths
GROUP BY location, population
ORDER BY 4 DESC

-- Showing Countries with Highest Death Count
-- Total Deaths needs to be convert from varchar to int
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
GROUP BY location
ORDER BY TotalDeathCount DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Showing Continents with the Highest Death Count per Population
SELECT continent,  MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global Numbers
-- Per Day
SELECT date, MAX(total_cases) AS TotalCases, MAX(CAST(total_deaths AS int)) AS TotalDeaths, (MAX(CAST(total_deaths AS int))/ MAX(total_cases))*100 AS DeathPercentage
FROM CovidDeaths
GROUP BY date
ORDER BY DeathPercentage desc
-- Total
SELECT MAX(total_cases) AS TotalCases, MAX(CAST(total_deaths AS int)) AS TotalDeaths, (MAX(CAST(total_deaths AS int))/ MAX(total_cases))*100 AS DeathPercentage
FROM CovidDeaths
--GROUP BY date
ORDER BY DeathPercentage desc


--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- 
-- Now we'll explore CovidVaccinations Dataset
SELECT *
FROM CovidVaccinations
ORDER BY 3,4

-- Join both datasets
SELECT *
FROM CovidDeaths dea
INNER JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
ORDER by 3,4



-- Looking at Total Population VS Vaccinations
-- Using CTE
WITH PopulationVaccinated (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent,  dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
INNER JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentPeopleVaccinated
FROM PopulationVaccinated



-- Using Temp Table
CREATE TABLE #PopulationVaccinated(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)

INSERT INTO #PopulationVaccinated
SELECT dea.continent,  dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
INNER JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM #PopulationVaccinated

SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentPeopleVaccinated
FROM #PopulationVaccinated



-- Creating View
CREATE VIEW PopulationVaccinated AS
SELECT dea.continent,  dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
INNER JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

