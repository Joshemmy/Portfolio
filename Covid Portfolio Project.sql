Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4


--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

-- Select the Column Data that we are going to be viewing

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2 



-- Looking at the percentage of the Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in Nigeria


Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percent
From PortfolioProject..CovidDeaths
Where location like '%Nigeria%'
and continent is not null
Order by 1,2 


-- Looking at the percentage of the Total Cases vs Populations
--Shows what percentage of population contracted covid

Select location, date, total_cases, population, (total_cases/population)*100 as percent_infected_population
From PortfolioProject..CovidDeaths
Where continent is not null
--Where location like '%Nigeria%'
Order by 1,2 

-- Looking at countries with highest infection rate compared to population

Select location, population, MAX(total_cases) as highest_infection_count, population, Max((total_cases/population))*100 as percent_infected_population
From PortfolioProject..CovidDeaths
Where continent is not null
-- Where location like 'N%'
Group by location, population
Order by 5 DESC


-- Showing countries with the Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as total_death_count
From PortfolioProject..CovidDeaths
Where continent is not null
-- Where location like 'N%'
Group by location
Order by 2 DESC

-- Let's break things down by continent (showing the highest death count)

Select continent, MAX(cast(total_deaths as int)) as total_death_count
From PortfolioProject..CovidDeaths
Where continent is not null
-- Where location like 'N%'
Group by continent
Order by 2 DESC


-- Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
From PortfolioProject..CovidDeaths
-- Where location like '%Nigeria%'
Where continent is not null
--Group By date
Order by 1,2


-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as rolling_people_vaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


-- Use CTE

With PopvsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated) as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as rolling_people_vaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null)
Select *, (rolling_people_vaccinated/population)*100
From PopvsVac


-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as rolling_people_vaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
Select *, (rolling_people_vaccinated/population)*100
From #PercentPopulationVaccinated





-- Creating view to store data for later visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as rolling_people_vaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null


Select *
From PercentPopulationVaccinated