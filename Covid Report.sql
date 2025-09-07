Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4 

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4 

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if your contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%state%'
order by 1,2
 
--Looking at Total Cases vs Population
--Shows what percentage of population got Covid
Select location, date, total_cases, Population, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%state%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
Select location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as 
PercentPopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%state%'
Group by Location, Population
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%state%'
Where continent is not null
Group by Location, Population
order by TotalDeathCount desc

-- Break things down by continent
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%state%'
Where continent is null
Group by Location
order by TotalDeathCount desc

-- Showing continent with the highest death count per population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%state%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)
*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%state%'
where continent is not null
Group By date
order by 1,2


-- Looking at Total Population vs. Vaccinations
-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date)
as RollingPeopleVaccinated --, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- TEMP TABLE

--DROP Table if exists #PercentPopulationVaccination
Create Table #PercentPopulationVaccination
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date)
as RollingPeopleVaccinated --, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccination

-- Creating View to Store data for later View
Create View PercentPopulationVaccinate as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date)
as RollingPeopleVaccinated --, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3



Select*
From PercentPopulationVaccinate