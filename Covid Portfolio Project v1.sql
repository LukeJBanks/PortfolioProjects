SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1,2

-- Total Cases VS Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS MortalityPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like 'Canada'
and continent is not null
ORDER BY 1,2

--Total Cases VS Population
-- What percent of the population got Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS InfectionPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like 'Canada'
ORDER BY 1,2

-- Countries with highest infection rate compaired to population.

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS InfectionPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like 'Canada'
Group BY location, population
ORDER BY InfectionPercentage desc 

-- Countries with highest death count per Population

SELECT location, MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
Where continent is not NULL
Group BY location
ORDER BY TotalDeathCount desc 

-- Continents with highest death count per Population

SELECT location, MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
Where continent is NULL
Group BY location
ORDER BY TotalDeathCount desc

-- Global Numbers Per Day

SELECT date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths
,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as MortalityPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP By date
ORDER BY 1,2

-- Total Global Numbers

SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths
,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as MortalityPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
--GROUP By date
ORDER BY 1,2


-- Total Population VS Vaccination

--CTE Method

WITH PopvsVac (Continent, Location, Data, Population, New_Vaccinations, RollingVaccinations)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingVaccinations
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL --AND vac.new_vaccinations is not NULL
)
SELECT *, (RollingVaccinations/population)*100
FROM PopvsVac

--Temp Table Method

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingVaccinations numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingVaccinations
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL --AND vac.new_vaccinations is not NULL

SELECT *, (RollingVaccinations/population)*100
FROM #PercentPopulationVaccinated



--Creating Views to store data for later Visualizations

--View One: 

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingVaccinations
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL

SELECT *
FROM PercentPopulationVaccinated

--View Two:

CREATE VIEW CountriesHighestDeathPerPOP as
SELECT location, MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
Where continent is not NULL
Group BY location

--View Three:

CREATE VIEW HighestInfectionRateCompairedToPOP as
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS InfectionPercentage
FROM PortfolioProject.dbo.CovidDeaths
Group BY location, population