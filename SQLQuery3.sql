--SELECT * 
--FROM PortfoliaProject..CovidDeaths

--SELECT * 
--FROM PortfoliaProject..CovidVaccinations

--SELECT DATA that i am going to use
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfoliaProject..CovidDeaths
order by 1,2

--looking at total cases vs total deaths
--shows likelihood to die from covid
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS PercentageDeath
FROM PortfoliaProject..CovidDeaths
order by 1,2

--percentage of people got affected
SELECT location, date, population, total_cases, (total_cases/population)*100 AS Percentageaffect
FROM PortfoliaProject..CovidDeaths
ORDER BY 1,2

--countries with highest infection rate
SELECT location, population, MAX(total_cases)AS highestert, MAX((total_cases/population))*100 AS Percentageaffect
FROM PortfoliaProject..CovidDeaths
GROUP BY location,population
ORDER BY Percentageaffect desc

--coumtries with highest death count
SELECT location, MAX(cast(total_deaths AS int)) AS HighestDeath
FROM PortfoliaProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY Highestdeath desc

--break things by continent
SELECT location, MAX(cast(total_deaths as int))*100 AS HighestDeaths
From PortfoliaProject..CovidDeaths
WHERE continent is NULL
GROUP BY location
ORDER BY HighestDeaths desc

--showing continent with highest death count
SELECT MAX(cast(total_deaths as int))*100 AS HighestDeaths, continent
From PortfoliaProject..CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY HighestDeaths desc

--Global Numbers
SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercent
FROM PortfoliaProject..CovidDeaths
WHERE continent is not NULL
GROUP BY date
ORDER BY 1,2

--Total 
SELECT  SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercent
FROM PortfoliaProject..CovidDeaths
WHERE continent is not NULL
--GROUP BY date
ORDER BY 1,2

--total population vs vaccination
SELECT cvd.continent,cvd.location,cvd.date,cvd.population,cvc.total_vaccinations
FROM PortfoliaProject..CovidDeaths AS cvd
JOIN PortfoliaProject..CovidVaccinations AS cvc
    ON cvd.location=cvc.location
	and cvd.date=cvc.date
	WHERE cvd.continent is not null
ORDER BY 1,2,3

--total popultaion vs new vaccination
SELECT cvd.continent,cvd.location,cvd.date,cvd.population,cvc.new_vaccinations,SUM(cast(cvc.new_vaccinations as int)) OVER (Partition by cvd.location ORDER BY cvd.location,cvd.date)
FROM PortfoliaProject..CovidDeaths AS cvd
JOIN PortfoliaProject..CovidVaccinations AS cvc
    ON cvd.location=cvc.location
	and cvd.date=cvc.date
	WHERE cvd.continent is not null
ORDER BY 1,2,3

--cte and temptable
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rollingpeoplevaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT cvd.continent,cvd.location,cvd.date,cvd.population,cvc.new_vaccinations,SUM(cast(new_vaccinations as int)) OVER (Partition BY cvd.location ORDER BY cvd.location,cvd.date) AS Rollingpeoplevaccinated
FROM PortfoliaProject..CovidDeaths cvd
 JOIN PortfoliaProject..CovidVaccinations cvc
 ON cvd.location=cvc.location
 and cvd.date=cvc.date
WHERE cvd.continent is not null

SELECT *,(Rollingpeoplevaccinated/population)*100 AS vaccinated
FROM #PercentPopulationVaccinated

--creating view for tableau
CREATE VIEW PercentPopulationVaccinated AS
SELECT cvd.continent,cvd.location,cvd.date,cvd.population,cvc.new_vaccinations,SUM(cast(new_vaccinations as int)) OVER (Partition BY cvd.location ORDER BY cvd.location,cvd.date) AS Rollingpeoplevaccinated
FROM PortfoliaProject..CovidDeaths cvd
 JOIN PortfoliaProject..CovidVaccinations cvc
 ON cvd.location=cvc.location
 and cvd.date=cvc.date
WHERE cvd.continent is not null
