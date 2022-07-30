--SELECT location, date, total_cases, new_cases, total_deaths, population
--FROM PortfolioProject..CovidDeaths$
--order by 1, 2

--SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--FROM PortfolioProject..CovidDeaths$
--WHERE location like '%states%'
--order by 1, 2

--looking at total cases vs population 
--Shows what % of population got Covid

--SELECT location, date, total_cases, total_deaths, population, (total_cases/population)*100 as PopulationThatGotCovid
--FROM PortfolioProject..CovidDeaths$
--WHERE location like '%states%'
--order by 1, 2


-- Looking at countries with the highest infection rate compered to its population

--SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PopulationThatGotCovid
--FROM PortfolioProject..CovidDeaths$
----WHERE location like '%states%'
--GROUP BY location, population
--order by PopulationThatGotCovid DESC

--Countries with the highest death count per population

--SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
--FROM PortfolioProject..CovidDeaths$
--WHERE continent IS NOT NULL
--GROUP BY location
--order by TotalDeathCount DESC

-- Checking things when it comes to continents 

--Continents with the highest deaths count
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
order by TotalDeathCount DESC

--Global numbers

SELECT date, 
SUM(new_cases) as Total_nr_of_cases,
SUM(cast(new_deaths as int)) as Total_nr_of_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
group by date
order by 1, 2

-- Looking at total population vs population

select dea.continent,
dea.location,
dea.population,
vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ as dea
join PortfolioProject..CovidVaccinations$ as vac
on dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL
order by 2, 3

--Use CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select 
dea.continent,
dea.location,
dea.population,
dea.date,
vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ as dea
join PortfolioProject..CovidVaccinations$ as vac
on dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--order by 2, 3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric, 
new_vac numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
select 
dea.continent,
dea.location,
dea.population,
dea.date,
vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ as dea
join PortfolioProject..CovidVaccinations$ as vac
on dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL


--Creating view to store data for later visualization 

CREATE VIEW Countries_with_the_highest_death_count_per_population as

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location