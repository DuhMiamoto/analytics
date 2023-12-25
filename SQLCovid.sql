--select * 
--from PortfolioProject..CovidDeaths
--order by 3,4

--select * 
--from PortfolioProject..CovidVaccinations
--order by 3,4

-- Select data that we are going to be using 

--Select Location, date, total_cases, new_cases, total_deaths, population
--from PortfolioProject..CovidDeaths
--order by 1,2

 --Looking at total Cases vs Total Deaths
 -- Shows likehood of dying if you contract covid in your country
SELECT
    Location,
    date,
    total_cases,
    total_deaths,
    CASE
        WHEN TRY_CONVERT(int, total_cases) = 0 THEN 0 -- Evita a divisão por zero
        ELSE (TRY_CONVERT(float, total_deaths) / TRY_CONVERT(float, total_cases))*100 -- Realiza a divisão convertendo para tipos numéricos
    END AS pct_deaths
FROM
    PortfolioProject..CovidDeaths
WHERE
	total_cases IS NOT NULL AND total_deaths IS NOT NULL and Location like '%Brazil%'
ORDER BY
    1, 2;

-- Looking at total Cases vs Population
-- Shows what percentage of population got covid
SELECT
    Location,
    date,
    total_cases,
    population,
    CASE
        WHEN TRY_CONVERT(int, total_cases) = 0 THEN 0 -- Evita a divisão por zero
        ELSE (TRY_CONVERT(float, total_cases) / TRY_CONVERT(float, population))*100 -- Realiza a divisão convertendo para tipos numéricos
    END AS pct_population
FROM
    PortfolioProject..CovidDeaths
WHERE
	total_cases IS NOT NULL AND total_deaths IS NOT NULL and Location like '%Brazil%'
ORDER BY
    1, 2;

-- Looking at contries with Highest infection rate compared to population

Select 
	Location, 
	population,
	Max(total_cases) as HighestInfection, 
	Max((total_cases/population))*100 as pct_pop_inf
From PortfolioProject .. CovidDeaths
Group by Location, population
order by pct_pop_inf desc 

-- Showing Countries with highest death count per population

select 
	Location, 
	Max(cast(total_deaths as int)) as Total_death_count 
From PortfolioProject .. CovidDeaths 
where continent is not null
Group by Location
Order by Total_death_count desc

-- Let's break things down by continent

select 
	continent, 
	Max(cast(total_deaths as int)) as Total_death_count 
From PortfolioProject .. CovidDeaths 
where continent is not null
Group by continent
Order by Total_death_count desc

-- Showing continents with the highest death count per population

select 
	continent, 
	Max(cast(total_deaths as int)) as Total_death_count 
From PortfolioProject .. CovidDeaths 
where continent is not null
Group by continent
Order by Total_death_count desc


-- Global Numbers

Select
	--date,
	SUM(new_cases) as Total_Cases, 
	SUM(cast(new_deaths as int)) as Total_Deaths,
	SUM(cast(new_deaths as int)) / SUM(new_cases) * 100 as DeathPct 
from PortfolioProject .. CovidDeaths
where continent is not null and new_cases != 0
--Group by date
order by 1,2

-- Looking at total population vs vaccinations
Select 
	dea.continent, 
	dea.Location, 
	dea.date,
	dea.population, 
	vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations as FLOAT)) OVER (PARTITION BY dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated,
	--(RollingPeapleVaccinated/population)*100
from PortfolioProject .. CovidDeaths dea
join PortfolioProject .. CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
and dea.date > '2020-12-08 00:00:00:000' 
order by 2, 3 

-- USE CTE 
with PopvsVac(continent, Location, date, Population, New_vaccinations, RollingPeopleVaccinated)
as 
(
Select 
	dea.continent, 
	dea.Location, 
	dea.date,
	dea.population, 
	vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations as FLOAT)) OVER (PARTITION BY dea.Location Order by dea.location, dea.date) as RollingPeapleVaccinated
	--(RollingPeapleVaccinated/population)*100
from PortfolioProject .. CovidDeaths dea
join PortfolioProject .. CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
and dea.date > '2020-12-08 00:00:00:000' 
--order by 2, 3 
)

Select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

-- Temp table 

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric,
new_vaccinations numeric, 
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
Select 
	dea.continent, 
	dea.Location, 
	dea.date,
	dea.population, 
	vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations as FLOAT)) OVER (PARTITION BY dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject .. CovidDeaths dea
join PortfolioProject .. CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
where dea.date > '2020-12-08 00:00:00:000' 
--order by 2, 3 

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


-- creating view to store for later visualizations

create View PercentPopulationVaccinated as 
Select 
	dea.continent, 
	dea.Location, 
	dea.date,
	dea.population, 
	vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations as FLOAT)) OVER (PARTITION BY dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject .. CovidDeaths dea
join PortfolioProject .. CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
where dea.date > '2020-12-08 00:00:00:000' 
--order by 2, 3 

Select * 
from PercentPopulationVaccinated