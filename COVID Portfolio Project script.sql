SELECT *
FROM PortfolioProject..CovidDeaths$
Where continent is not null
Order by 3,4


--SELECT *
--FROM PortfolioProject..CovidVaccinations$
--Order by 3,4


SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
Order By 1,2

--Looking at Total Cases vs. Total Deaths
--Shows liklihood of dying if you contact covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
Where location like '%states%'
Order By 1,2


--Looking at Total Cases vs. Population
--Shows what percentage of population got Covid
SELECT Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
Where location like '%states%'
Order By 1,2


--Looking at countries with highest Infection Rate compared to Population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
--Where location like '%states%'
Group by Location, Population
Order By PercentPopulationInfected desc

--Showing Countries with the highest death count per population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by Location
Order By TotalDeathCount desc

--Break things down by continent
--Showing continents with highest death count

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by continent
Order By TotalDeathCount desc



--Global Numbers

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
--Where location like '%states%'
Where continent is not null
--Group by date
Order By 1,2

--Looking at Total Population vs. Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3



--USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac



--Temp Table

DROP Table if exists #PercentPopilationVaccinated
Create Table #PercentPopilationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopilationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopilationVaccinated


--Cretating view to store data for later visualizations

Create View PercentPopilationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3




Select * 
From PercentPopilationVaccinated