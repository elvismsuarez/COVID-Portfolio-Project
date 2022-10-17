--select * 
--from PortfolioProject..CovidDeaths
--order by 3,4

--select * 
--from PortfolioProject..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using

--select Location, date, total_cases, new_cases, total_deaths, population
--from PortfolioProject..CovidDeaths
--order by 1,2

-- Looking Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contact covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where continent is not null and location like '%Dominican%'
order by 1,2

-- Looking at the Total Cases vs the Population
--Shows what percentage of population got covid
select location, date, population, total_cases,(total_cases/population)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
where location like '%Dominican%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
select location, population, MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
--where location like '%Dominican%'
order by PercentPopulationInfected desc

--Showing the Countries with the Highest Death Count per Population
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
--where location like '%Dominican%'
order by TotalDeathCount desc

-- LETS BREAK THINGS DOWN BY CONTINENT


--Showing the Countries with the Highest Death Count per Population
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
--where location like '%Dominican%'
order by TotalDeathCount desc

-- GLOBAL NUMBERS

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--where location like '%Dominican%'
order by 1, 2


 --Looking at Total Population vs vaccinations
SET ANSI_WARNINGS OFF
GO
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated

from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

