SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

-- Select the data to use for the project
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--Looking at the total cases vs Total Deaths 
--To show the percentage of people that got Covid

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS PopulationInfectedPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%States%'
ORDER BY 1,2


--Loooking at countries with highest Infection rate compared to population
SELECT location, population, max(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS InfectedPopulationPercentage
FROM PortfolioProject..CovidDeaths
--where location like '%states%'
GROUP BY location, population
ORDER BY InfectedPopulationPercentage DESC

--SHOWING COUNTRIES WITH HIGHEST DEATHCOUNT PER LOCATION
SELECT location, MAX(CAST(total_deaths AS int)) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY HighestDeathCount DESC

--LET'S BREAK OUR TABLE DOWN BY CONTINENT

--SHOWING CONTINENT WITH HIGHEST DEATH COUNT PER POPULATION
SELECT continent, population, MAX(CAST(total_deaths AS int)) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent, population
ORDER BY HighestDeathCount DESC

--GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS TotalCases, SUM(CAST (new_deaths AS int)) AS TotalDeaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--SUM OF TOTAL CASES AND TOTAL DEATHS
SELECT SUM(new_cases) AS TotalCases, SUM(CAST (new_deaths AS int)) AS TotalDeaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


--Looking at total population vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS int)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations Vac
	ON Dea.location = Vac.location
	AND Dea.date = Vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--NOW WE USE CTE TO GET THE PERCENTAGE OF ROLLING PEOPLE VACCINATED IN EACH LOCATION
WITH PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS int)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations Vac
	ON Dea.location = Vac.location
	AND Dea.date = Vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS TotalPercentageOfVaccinatedPeople
FROM PopVsVac

--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS int)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations Vac
	ON Dea.location = Vac.location
	AND Dea.date = Vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100 AS TotalPercentageOfVaccinatedPeople
FROM #PercentPopulationVaccinated

--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION

CREATE VIEW PercentPopulatedVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS int)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations Vac
	ON Dea.location = Vac.location
	AND Dea.date = Vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulatedVaccinated