select location, date, total_cases, new_cases, total_deaths, population
from [Portfolio Project]..CovidDeaths
order by 1,2

--looking at Total deaths as a Percentage of  total_cases

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths
order by 1,2

--looking at Total deaths as a Percentage of  total_cases in Kenya
--shows the likelihood of death if you contract covid in Kenya

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths
where location = 'Kenya'
order by 1,2

Create view DeathPercentage as
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths
where location = 'Kenya'



--You can also use the code "where location like '%Kenya%' "  to narrow down to percentage of deaths in Kenya

--looking at total cases as a percentage of total popoulation in kenya

select location, date, total_cases, population, (total_cases/population)*100 as Population_Infection_Percentage
from [Portfolio Project]..CovidDeaths
where location = 'Kenya'
order by 1,2

--Countries with the highest infection rate compared to population

select location,population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as 
Population_Infection_Percentage
from [Portfolio Project]..CovidDeaths
--where location = 'Kenya'
Group by location, population
Order by Population_Infection_Percentage desc



--Countries with the highest death Counts

select location, max(total_deaths) as
TotalDeathCount
from [Portfolio Project]..CovidDeaths
--where location = 'Kenya'
where continent is not null
Group by location
Order by TotalDeathCount desc

-- Now, lets look at the data based on continent
--Continents with the highest death counts

select location, max(total_deaths) as
TotalDeathCount
from [Portfolio Project]..CovidDeaths
--where location = 'Kenya'
where continent is null
Group by location
Order by TotalDeathCount desc

--Now lets breakdown global numbers

select date, sum(new_cases) as Totalcases   -- total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths
--where location = 'Kenya'
Where continent is not null
group by date
order by 1,2

--Total cases per day

select date, sum(new_cases) as TotalNewCases,sum(cast(new_deaths AS INT)) as TotalNewdeaths, sum(cast(new_deaths AS INT))/sum(new_cases)*100
as DeathsPercentage  
from [Portfolio Project]..CovidDeaths
--where location = 'Kenya'
Where continent is not null
group by date
order by 1,2

--total cases overall

select sum(new_cases) as TotalNewCases,sum(cast(new_deaths AS INT)) as TotalNewdeaths, sum(cast(new_deaths AS INT))/sum(new_cases)*100
as DeathsPercentage  
from [Portfolio Project]..CovidDeaths
--where location = 'Kenya'
Where continent is not null
order by 1,2



--Join both covidDeaths and vaccinations tables

Select*
From [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..Vaccinations vac
on dea.location= vac.location and dea.date= vac.date

--Now lets look at total Vaccinations vs Total Population

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..Vaccinations vac
on dea.location= vac.location and dea.date= vac.date
where dea.continent is not null
order by 1,2,3


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum (cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as People_Vaccinated
From [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..Vaccinations vac
on dea.location= vac.location and dea.date= vac.date
where dea.continent is not null
order by 1,2,3

--use cte


with popvsvac (continent, location, date, population,new_vaccinations, People_Vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum (cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as People_Vaccinated
From [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..Vaccinations vac
on dea.location= vac.location and dea.date= vac.date
where dea.continent is not null
)
select*, (People_Vaccinated/population)*100 as PercentagePopulationVaccinated
from popvsvac



--Creating View to store data for visualization


Create view PercentagePopulationvaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum (cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as People_Vaccinated
From [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..Vaccinations vac
on dea.location= vac.location and dea.date= vac.date
where dea.continent is not null
