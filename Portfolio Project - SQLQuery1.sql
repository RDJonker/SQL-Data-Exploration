--Select * 
--From [Portfolio Project]..CovidDeaths$
--Order by 3,4

--Select * 
--From [Portfolio Project]..CovidVaccinations$
--Order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..CovidDeaths$
order by 1,2



-- Looking at total case vs total deaths
-- Shows the likelihood of dying if you contract covid in the USA
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths$
where location like '%states%'
order by 1,2


--Looking at the total cases vs population
-- Shows what percentage of population got covid
Select location, date, population, total_cases, (total_cases/population)*100 as ContractedPercentage
From [Portfolio Project]..CovidDeaths$
where location like '%states%'
order by 1,2


--Looking at countries with highest infection rate compared to population
Select location,  population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population))*100 as Percent_Population_Infected
From [Portfolio Project]..CovidDeaths$
Group by location,  population
order by Percent_Population_Infected desc

--Looking at countries with highest death count per population
Select location, MAX(cast(total_deaths as int)) as Total_Death_Count
From [Portfolio Project]..CovidDeaths$
where continent is not null
Group by location
order by Total_Death_Count desc


--Showing the continents with highest death count
Select continent, MAX(cast(total_deaths as int)) as Total_Death_Count
From [Portfolio Project]..CovidDeaths$
where continent is not null
Group by continent
order by Total_Death_Count desc


--Global Numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100
From [Portfolio Project]..CovidDeaths$
where continent is not null
group by date
order by 1,2


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100
From [Portfolio Project]..CovidDeaths$
where continent is not null
order by 1,2


--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated, --(Rolling_People_Vaccinated/population)*100
From [Portfolio Project]..CovidDeaths$ dea
join [Portfolio Project]..CovidVaccinations$ vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use CTE

with POP_vs_Vac (Continent, Location, Date, Population, new_vaccinations, Rolling_People_Vaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
From [Portfolio Project]..CovidDeaths$ dea
join [Portfolio Project]..CovidVaccinations$ vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select *, (Rolling_People_Vaccinated/Population)*100 
From POP_vs_Vac



--Temp Table
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rolling_People_Vaccinated numeric
)

insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
From [Portfolio Project]..CovidDeaths$ dea
join [Portfolio Project]..CovidVaccinations$ vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (Rolling_People_Vaccinated/Population)*100 
From #PercentPopulationVaccinated


--Creating views to store data for later visualizations

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
From [Portfolio Project]..CovidDeaths$ dea
join [Portfolio Project]..CovidVaccinations$ vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select * 
From PercentPopulationVaccinated