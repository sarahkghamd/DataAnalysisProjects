select * from CovidProject..CovidVaccinations;


select * from CovidProject..CovidDeaths order by location, date;


-- Extract the data
Select location, date, total_cases, new_cases, total_deaths, population
From CovidProject..CovidDeaths
Order by 1,2

-- Looking at total cases vs. total deaths
-- Shows likelihood of dying if you contract covid in Saudi Arabia
Select location, date, total_cases, total_deaths, (CAST(total_deaths as float)/CAST(total_cases as float))*100  AS DeathPercentage
From CovidProject..CovidDeaths
where location = 'Saudi Arabia'
Order by 1,2

-- Looking at Total Cases vs. Population
-- showing what percentage of population got Covid
Select location, date, total_cases, population, (CAST(total_cases as float)/CAST(population as float))*100  AS PercentPopulationInfected
From CovidProject..CovidDeaths
Order by 1,2


-- Looking at countries with highest total cases
Select location, max(CAST(total_cases as int)) AS HighestInfectionCount
From CovidProject..CovidDeaths
Where continent is not null
Group by location
Order by HighestInfectionCount DESC

-- Looking at countries with highest infection rate compared to population
Select location, population, max(CAST(total_cases as int)) AS HighestInfectionCount, max(CAST(total_cases as float)/CAST(population as float))*100 AS PercentPopulationInfected
From CovidProject..CovidDeaths
Where continent is not null
Group by location,  population
Order by PercentPopulationInfected DESC

-- Looking at countries with highest number of deaths compered to population
Select location, population, max(CAST(total_deaths as int)) AS HighestDeathsCount, max(CAST(total_deaths as float)/CAST(population as float))*100 AS PercentPopulationDied
From CovidProject..CovidDeaths
Where continent is not null
Group by location, population
Order by PercentPopulationDied DESC

-- Looking at death counts per continent
select continent, max(cast(total_deaths as int)) as total_deaths 
from CovidProject..CovidDeaths 
where continent is not null
group by continent 
order by total_deaths desc

-- query the continents with the highest death count per population
select continent, max(total_deaths) TotalDeaths, max(population) Population, MAX(cast(total_deaths as float)/cast (population as float))*100 AS DeathPercentage
from CovidProject..CovidDeaths
where continent is not null
group by continent
order by DeathPercentage DESC

-- Global Numbers
SELECT date, sum(cast(new_cases as int)) AS TotalNewCases, sum(cast(new_deaths as int)) TotalNewDeaths
FROM CovidProject..CovidDeaths
where continent is not null
GROUP BY date
ORDER BY 1,2

-- Looking at Total Population vs Vaccinations
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations,
SUM(CONVERT(float,V.new_vaccinations)) OVER (PARTITION BY D.location order by D.location, D.date) AS PeopleVaccinated
FROM CovidProject..CovidDeaths D JOIN CovidProject..CovidVaccinations V 
ON D.location = V.location 
AND D.date = V.date
WHERE D.continent is not null
ORDER BY 2,3

-- use CTE to reuse PeopleVaccinated column in another column
With PopvsVac (Continent, location, date, population, new_vaccinations,PeopleVaccinated)
as 
(
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations,
SUM(CONVERT(float,V.new_vaccinations)) OVER (PARTITION BY D.location order by D.location, D.date) AS PeopleVaccinated
FROM CovidProject..CovidDeaths D JOIN CovidProject..CovidVaccinations V 
ON D.location = V.location 
AND D.date = V.date
WHERE D.continent is not null
--ORDER BY 2,3
)
Select *, (PeopleVaccinated/cast(population as int))*100 from PopvsVac 

-- creating view to store data for later visualizations
alter view PercentVaccinated as 
select D.continent, D.location , D.date , D.population , V.new_vaccinations,
SUM(Convert(int, V.new_vaccinations)) OVER (Partition by D.Location Order by D.location, D.date) as RollingPeopleVaccinated
from CovidProject..CovidDeaths D
Join CovidProject..CovidVaccinations V
on D.location = V.location 
and D.date = V.date
where D.continent is not null


select * from PercentVaccinated
