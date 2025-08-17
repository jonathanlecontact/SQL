--Covid 19 Data Exploration
-- Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--Select data that we are going to be starting with
SELECT location, date, total_cases, new_Cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--Total Cases vs Total Deaths
--Shows likelihood of dying if you contract Covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
AND continent IS NOT NULL
ORDER BY 1,2

--Total Cases vs Population
--Shows what percentage of population infected with Covid
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

--Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

--Countries with Highest Death Count per Population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
AND continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount desc

--BREAKING THINGS DOWN BY CONTINENT
--Showing continents with the highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
AND continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS
SELECT date, SUM(CAST(new_cases  AS FLOAT)) AS total_cases, SUM(CAST(new_deaths AS FLOAT)) AS total_deaths, 100.0 * SUM(CAST(new_deaths AS FLOAT))
        / NULLIF(SUM(CAST(new_cases AS FLOAT)), 0) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
AND location LIKE '%states%'
GROUP BY date
ORDER BY 1,2

--Total Population vs Vaccinations
--Shows Percentage of Population that has received at least one Covid Vaccine
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

--Using CTE to perform Calculation on Partition By in previous query
WITH PopvsVac AS (SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date ROWS UNBOUNDED PRECEDING) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL)
SELECT *, 100.0 * CAST(RollingPeopleVaccinated AS float)/ NULLIF(CAST(population AS float), 0.0) AS PctPopVaccinated
FROM PopvsVac;

--Using Temp Table to perform Calculation on Partition By in previous query
DROP TABLE IF EXISTS #PercentPopulationVaccinated;
CREATE TABLE #PercentPopulationVaccinated
(
  Continent                nvarchar(255),
  Location                 nvarchar(255),
  [Date]                   datetime,
  Population               bigint NULL,
  New_vaccinations         bigint NULL,
  RollingPeopleVaccinated  bigint NULL
);

INSERT INTO #PercentPopulationVaccinated
(
  Continent, Location, [Date],
  Population, New_vaccinations, RollingPeopleVaccinated
)
SELECT
  dea.continent,
  dea.location,
  dea.date,
  -- clean population (handles varchar, commas, blanks)
  TRY_CONVERT(bigint,
      NULLIF(REPLACE(CONVERT(nvarchar(50), dea.population), ',', ''), '')
  ) AS Population,
  -- clean new_vaccinations
  TRY_CONVERT(bigint,
      NULLIF(REPLACE(CONVERT(nvarchar(50), vac.new_vaccinations), ',', ''), '')
  ) AS New_vaccinations,
  -- running total per location (BIGINT so it won't overflow)
  SUM(
      TRY_CONVERT(bigint,
          NULLIF(REPLACE(CONVERT(nvarchar(50), vac.new_vaccinations), ',', ''), '')
      )
  ) OVER (
      PARTITION BY dea.location
      ORDER BY dea.date
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths       AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
  ON dea.location = vac.location
 AND dea.date     = vac.date
WHERE dea.continent IS NOT NULL;  -- optional filter

-- Final select with percentage (float math + divide-by-zero safe)
SELECT
  *,
  100.0 * CAST(RollingPeopleVaccinated AS float)
        / NULLIF(CAST(Population AS float), 0.0) AS PercentPopulationVaccinated
FROM #PercentPopulationVaccinated
ORDER BY Location, [Date];

--Creating View to store data for later visualizations

/* CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL; */