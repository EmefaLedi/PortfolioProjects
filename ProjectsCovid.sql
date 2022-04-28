--View the two tables in the database ordered by col 3,4
Select *
From PortfolioProjectCovid..CovidVaccinations
order by 3,4

Select *
From PortfolioProjectCovid..CovidDeaths
order by 3,4


--Select our starting data
Select Location, date, total_cases, new_cases, population
From PortfolioProjectCovid..CovidDeaths
Order by 1,2 


--Total cases and total deaths in countries
Select Location, date, SUM(total_cases) AS TotalCases, SUM(cast(total_deaths as int)) AS TotalDeaths
From PortfolioProjectCovid..CovidDeaths
Group by location,date
Order by date desc


--Shows percentage of dying when infected in Ghana by dates
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage 
From PortfolioProjectCovid..CovidDeaths
Where location LIKE '%Ghana%'
Order by 1,2


--Countries with the highest infection rate
Select location, population, MAX(total_cases) AS Infection_count, MAX((total_cases/population))*100 AS PercentPopulationInfected
From PortfolioProjectCovid..CovidDeaths
Group by location,population
Order by PercentPopulationInfected desc


--Countries with Highest death count 
Select location, MAX(cast(total_deaths as int)) AS TotalDeathCount
From PortfolioProjectCovid..CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount desc


--Continents with highest death count
Select continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
From PortfolioProjectCovid..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc



--Shows total vaccinations and new vaccinations of locations and its continent by dates
Select continent, location, date, total_vaccinations, new_vaccinations 
From PortfolioProjectCovid..CovidVaccinations
where continent is not null
Order by date desc



--Global cases and deaths
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProjectCovid..CovidDeaths
where continent is not null 



--Joining the two tables CovidDeaths and CovidVaccinations 
Select *
From PortfolioProjectCovid..CovidDeaths dea
Join PortfolioProjectCovid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3



--Joining the two tables to find the people vaccinated against the population 
Select dea.continent, dea.location, dea.date, dea.population, vac.people_vaccinated
, SUM(CONVERT(bigint,vac.people_vaccinated)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProjectCovid..CovidDeaths dea
Join PortfolioProjectCovid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3



--Using CTE on previous query to perform calculation on partition
With PopvsVac (Continent, location, date, population, people_vaccinated, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.people_vaccinated
, SUM(CONVERT(bigint,vac.people_vaccinated)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProjectCovid..CovidDeaths dea
Join PortfolioProjectCovid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--Create view to store data for visualization
Create view GlobalNumbers as
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProjectCovid..CovidDeaths
where continent is not null 

Create view ContinentDeathCount as
Select continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
From PortfolioProjectCovid..CovidDeaths
Where continent is not null
Group by continent

Create view CountriesDeathCount as
Select location, MAX(cast(total_deaths as int)) AS TotalDeathCount
From PortfolioProjectCovid..CovidDeaths
Where continent is not null
Group by location

