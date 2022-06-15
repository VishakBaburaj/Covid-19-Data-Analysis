--Select covid death data

SELECT *
FROM Covid_Data..CovidDeaths
order by Location, date

--Select covid vaccination data

SELECT *
FROM Covid_Data..CovidVaccinations
order by Location, date

--Data Exploration

--Total cases vs total deaths in India

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
FROM Covid_Data..CovidDeaths
WHERE location like '%India%'
order by Location, date

--Total cases vs population in India

SELECT Location, date, population, total_cases, (total_cases/population)*100 as Population_Percentage_Infected
FROM Covid_Data..CovidDeaths
WHERE location like '%India%'
order by Location, date

--Countries with highest infection rate compared to population

SELECT Location, population, max(total_cases) as Highest_Infection_Rate, 
max((total_cases/population))*100 as Population_Percentage_Infected
FROM Covid_Data..CovidDeaths
Group by Location, population
order by Population_Percentage_Infected desc

--Countries with highest death count per population

SELECT Location, population, max(cast(total_deaths as int)) as Highest_Death_Count
FROM Covid_Data..CovidDeaths
WHERE continent is not null 
Group by Location, population
order by Highest_Death_Count desc

--Countries with highest death count 

SELECT location, max(cast(total_deaths as int)) as Highest_Death_Count
FROM Covid_Data..CovidDeaths
WHERE continent is not null 
Group by location
order by Highest_Death_Count desc

--Contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Covid_Data..CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc

--Global death percentage from covid

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Covid_Data..CovidDeaths
where continent is not null 
order by 1,2

-- Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as
 RollingPeopleVaccinated
From Covid_Data..CovidDeaths dea
Join Covid_Data..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


DROP Table if exists PercentPopulationVaccinated
Create Table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) 
as RollingPeopleVaccinated
From Covid_Data..CovidDeaths dea
Join Covid_Data..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null 
	order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as PercentageofRollingPeopleVaccinated
From PercentPopulationVaccinated

--------------------------------------------------------------------------------------------------
--Tableau Visualizations
--------------------------------------------------------------------------------------------------
--Global Death Rate
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Covid_Data..CovidDeaths
where continent is not null 
order by 1,2
--Contintents with the highest death count per population
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From Covid_Data..CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International', 'Upper middle income', 'High income',
'Lower middle income', 'Low income')
Group by location
order by TotalDeathCount desc
--Countries Infection Percentage
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 
as PercentPopulationInfected
From Covid_Data..CovidDeaths
Where location not in ('World', 'European Union', 'International', 'Upper middle income', 'High income',
'Lower middle income', 'Low income')
Group by Location, Population
order by PercentPopulationInfected desc
--Countries Infection rate by year
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 
as PercentPopulationInfected
From Covid_Data..CovidDeaths
Where location not in ('World', 'European Union', 'International', 'Upper middle income', 'High income',
'Lower middle income', 'Low income')
Group by Location, Population, date
order by PercentPopulationInfected desc
--Number of people in a country vaccinated
Select dea.continent, dea.location, dea.date, dea.population
, MAX(vac.total_vaccinations) as RollingPeopleVaccinated
From Covid_Data..CovidDeaths dea
Join Covid_Data..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
group by dea.continent, dea.location, dea.date, dea.population
order by 1,2,3
--Percentage of people in a country vaccinated 
DROP Table if exists PercentPopulationVaccinated
Create Table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) 
as RollingPeopleVaccinated
From Covid_Data..CovidDeaths dea
Join Covid_Data..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null 
	order by 2,3
Select *, (RollingPeopleVaccinated/Population)*100 as PercentageofRollingPeopleVaccinated
From PercentPopulationVaccinated
