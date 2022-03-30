Select *
From PortfolioProject1..COVIDDeaths
Where continent is NULL
order by 3,4

Select *
From PortfolioProject1..COVIDVaccinations
Where continent is NOT NULL
order by 3,4


/*Select location, date, total_cases,new_cases,total_deaths,population
From PortfolioProject1..COVIDDeaths
order by 1,2*/

--INFORMATION BY COUNTRY
----Daily Total Cases v Total Deaths
Select location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 AS FatalityRate
From PortfolioProject1..COVIDDeaths
Where continent is not null
order by 1,2

----Daily Total Cases v Population (In the USA)
Select location, date, population, total_cases, (total_cases/population)*100 AS InfectionRates
From PortfolioProject1..COVIDDeaths 
Where location = 'United States' and continent is NOT NULL
order by 1,2

-- Maximum Infection Rate
Select location, population, MAX(total_cases) AS MaxCases, MAX((total_cases/population))*100 AS MaxInfectionRate
From PortfolioProject1..COVIDDeaths
Where continent is NOT NULL
Group by population, location
order by 4 DESC

-- Maximum Death Rate
Select location, population, MAX(cast(total_deaths as int)) AS MaxDeaths, MAX((total_deaths/population))*100 AS MaxDeathrate
From PortfolioProject1..COVIDDeaths
Where continent is NOT NULL
Group by population, location
order by 4 DESC

--Average Death Rate
Select location, population, AVG(cast(total_deaths as int)) AS AvgDeaths, AVG((total_deaths/population))*100 AS AvgDeathrate
From PortfolioProject1..COVIDDeaths
Where continent is NOT NULL
Group by population, location
order by 4 DESC


--INFORMATION BY CONTINENT
--Daily Total Cases v Total Deaths
Select location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 AS FatalityRate
From PortfolioProject1..COVIDDeaths
Where continent is null AND location NOT LIKE '%income'
order by 1,2

--Daily Total Cases v Population
Select location, date, population, total_cases, (total_cases/population)*100 AS InfectionRates
From PortfolioProject1..COVIDDeaths
Where continent is NULL AND location NOT LIKE '%income'
order by 1,2

-- Maximum Infection Rate
Select location, population, MAX(cast(total_cases as int)) AS MaxCases, MAX((total_cases/population))*100 AS MaxInfectionRate
From PortfolioProject1..COVIDDeaths
Where continent is NULL AND location NOT LIKE '%income'
Group by location, population
order by MaxInfectionRate DESC

-- Maximum Deaths and Death Rate
Select location, MAX(cast(total_deaths as float)) AS MaxDeaths, MAX((total_deaths/population)*100) AS MaxDeathRate
From PortfolioProject1..COVIDDeaths
Where continent is NULL AND location NOT LIKE '%income' AND location not like 'International'
Group by location
order by MaxDeathRate DESC

--GLOBAL INFORMATION
--Daily Fatality Deaths
Select date, SUM(new_cases) TotalCases, SUM(cast(new_deaths as int)) TotalDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 AS FatalityRate
From PortfolioProject1..COVIDDeaths
Where continent is not null
Group by date
order by 1,2

--Overall Fatality Rate
Select SUM(new_cases) TotalCases, SUM(cast(new_deaths as int)) TotalDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 AS FatalityRate
From PortfolioProject1..COVIDDeaths
Where continent is not null


--Total Vaccinations
Select CVDD.continent, CVDD.location, CVDD.date, population, CVDV.new_vaccinations, 
SUM(cast(CVDV.new_vaccinations as bigint)) OVER (Partition by CVDD.location order by CVDV.location,CVDV.date) AS TotalVaccinated
From PortfolioProject1..COVIDDeaths as CVDD
Join COVIDVaccinations as CVDV
	On CVDD.location = CVDV.location 
	AND CVDD.date = CVDV.date
Where CVDD.continent is not null
Order by 2,3

-- Using CTE
With PopvVac (Continent, Location, date, population, new_vaccinations, TotalVaccinated) 
as 
(
Select CVDD.continent, CVDD.location, CVDD.date, population, CVDV.new_vaccinations, 
SUM(cast(CVDV.new_vaccinations as bigint)) OVER (Partition by CVDD.location order by CVDV.location,CVDV.date) AS TotalVaccinated
From PortfolioProject1..COVIDDeaths as CVDD
Join COVIDVaccinations as CVDV
	On CVDD.location = CVDV.location 
	AND CVDD.date = CVDV.date
Where CVDD.continent is not null
)
Select *,(TotalVaccinated/population)*100 AS VaccinationRate
From PopvVac


--Max Vaccination Rate
Select CVDD.continent, CVDD.location, CVDD.date, population, CVDV.new_vaccinations, 
SUM(cast(CVDV.new_vaccinations as bigint)) OVER (Partition by CVDD.location order by CVDV.location,CVDV.date) AS TotalVaccinated
From PortfolioProject1..COVIDDeaths as CVDD
Join COVIDVaccinations as CVDV
	On CVDD.location = CVDV.location 
	AND CVDD.date = CVDV.date
Where CVDD.continent is not null
Order by 2,3

With VacRate (Continent, Location, date, population, new_vaccinations, TotalVaccinated) 
as 
(
Select CVDD.continent, CVDD.location, CVDD.date, population, CVDV.new_vaccinations, 
SUM(cast(CVDV.new_vaccinations as bigint)) OVER (Partition by CVDD.location order by CVDV.location,CVDV.date) AS TotalVaccinated
From PortfolioProject1..COVIDDeaths as CVDD
Join COVIDVaccinations as CVDV
	On CVDD.location = CVDV.location 
	AND CVDD.date = CVDV.date
Where CVDD.continent is not null
)
Select Location, Max(TotalVaccinated/population)*100 AS MaxVaccinationRate
From VacRate
Group by location, population
Order by MaxVaccinationRate


--TEMP TABLE (instead of CTE)
--Total Population v Vaccinations
/*Create Table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
TotalVaccinated numeric)

Insert into #PercentPopulationVaccinated
Select CVDD.continent, CVDD.location, CVDD.date, population, CVDV.new_vaccinations, 
SUM(cast(CVDV.new_vaccinations as bigint)) OVER (Partition by CVDD.location order by CVDV.location,CVDV.date) AS TotalVaccinated
From PortfolioProject1..COVIDDeaths as CVDD
Join COVIDVaccinations as CVDV
	On CVDD.location = CVDV.location 
	AND CVDD.date = CVDV.date
Where CVDD.continent is not null

Select *,(TotalVaccinated/population)*100 AS VaccinationRate
From #PercentPopulationVaccinated 

--Max Vaccination Rate (Cleared Temp Table afterwards)
Select Location, Max(TotalVaccinated/population)*100 AS MaxVaccinationRate
From #PercentPopulationVaccinated
Group by location, population
Order by MaxVaccinationRate

DROP Table if exists #PercentPopulationVaccinated
*/

--DATA VISUALIZATION--

--Daily Aggregate Vaccinated by Country
Create View GlobalVaccinated as
Select CVDD.continent, CVDD.location, CVDD.date, population, CVDV.new_vaccinations, 
SUM(cast(CVDV.new_vaccinations as bigint)) OVER (Partition by CVDD.location order by CVDV.location,CVDV.date) AS TotalVaccinated
From PortfolioProject1..COVIDDeaths as CVDD
Join COVIDVaccinations as CVDV
	On CVDD.location = CVDV.location 
	AND CVDD.date = CVDV.date
Where CVDD.continent is not null

Select *
From GlobalVaccinated

--Daily Vaccination Rate by Country
Create View GlobalVaccRate as
With PopvVac (Continent, Location, date, population, new_vaccinations, TotalVaccinated) 
as 
(
Select CVDD.continent, CVDD.location, CVDD.date, population, CVDV.new_vaccinations, 
SUM(cast(CVDV.new_vaccinations as bigint)) OVER (Partition by CVDD.location order by CVDV.location,CVDV.date) AS TotalVaccinated
From PortfolioProject1..COVIDDeaths as CVDD
Join COVIDVaccinations as CVDV
	On CVDD.location = CVDV.location 
	AND CVDD.date = CVDV.date
Where CVDD.continent is not null
)
Select *,(TotalVaccinated/population)*100 AS VaccinationRate
From PopvVac

--Max Vaccination Rate by Country
Create View GlobalMaxVacc as
With VacRate (Continent, Location, date, population, new_vaccinations, TotalVaccinated) 
as 
(
Select CVDD.continent, CVDD.location, CVDD.date, population, CVDV.new_vaccinations, 
SUM(cast(CVDV.new_vaccinations as bigint)) OVER (Partition by CVDD.location order by CVDV.location,CVDV.date) AS TotalVaccinated
From PortfolioProject1..COVIDDeaths as CVDD
Join COVIDVaccinations as CVDV
	On CVDD.location = CVDV.location 
	AND CVDD.date = CVDV.date
Where CVDD.continent is not null
)
Select Location, Max(TotalVaccinated/population)*100 AS MaxVaccinationRate
From VacRate
Group by location, population

Select *
From GlobalMaxVacc
Order by MaxVaccinationRate

-- Case Fatality Rate by Country
Create View CaseFatalityRate as
Select location, MAX(cast(total_cases  as bigint)) TotalCases,MAX(cast(total_deaths as bigint)) TotalDeaths,
	((MAX(cast(total_deaths as float)))/(MAX(cast(total_cases  as float))))*100 AS CaseFatalityRate
From PortfolioProject1..COVIDDeaths
Where continent is not null AND location NOT LIKE '%income'
Group by location

Select *
From CaseFatalityRate
Order by CaseFatalityRate

--Total Deaths by Continent
Create View TotalDeathsContinent as
Select location, MAX(cast(total_deaths as float)) AS TotalDeaths
From PortfolioProject1..COVIDDeaths
Where continent is NULL AND location NOT LIKE '%income' AND location not in ('International','World','European Union')
Group by location

Select *
From TotalDeathsContinent
order by TotalDeaths

--Average Death Rate by Country
Create View AverageDeathRate as
Select location, population, AVG(cast(total_deaths as int)) AS AvgDeaths, AVG((total_deaths/population))*100 AS AvgDeathrate
From PortfolioProject1..COVIDDeaths
Where continent is NOT NULL
Group by population, location

Select *
From AverageDeathRate
order by 4 DESC

--Total Fatality Rate
Create View TotalFatalityRate as 
Select SUM(new_cases) TotalCases, SUM(cast(new_deaths as int)) TotalDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 AS FatalityRate
From PortfolioProject1..COVIDDeaths
Where continent is not null


Select *
From TotalFatalityRate

--Population Infected Percentage
Create View PopInfectedPercent as
Select location, population, MAX(total_cases) AS MaxCases, MAX((total_cases/population))*100 AS MaxInfectionRate
From PortfolioProject1..COVIDDeaths
Where continent is NOT NULL
Group by population, location


--Population Infected Percentage by Day
Create View DailyPopInfected as
Select location, population,date, MAX(total_cases) AS MaxCases, MAX((total_cases/population))*100 AS MaxInfectionRate
From PortfolioProject1..COVIDDeaths
Where continent is NOT NULL
Group by population, location, date
order by MaxInfectionRate desc

--Total Vaccinated
Create View TotalVaccinated as
With VacRate (Continent, Location, date, population, new_vaccinations, TotalVaccinated) 
as 
(
Select CVDD.continent, CVDD.location, CVDD.date, population, CVDV.new_vaccinations, 
SUM(cast(CVDV.new_vaccinations as bigint)) OVER (Partition by CVDD.location order by CVDV.location,CVDV.date) AS TotalVaccinated
From PortfolioProject1..COVIDDeaths as CVDD
Join COVIDVaccinations as CVDV
	On CVDD.location = CVDV.location 
	AND CVDD.date = CVDV.date
Where CVDD.continent is not null
)
Select Location, Max(TotalVaccinated) AS TotalVaccinated
From VacRate
Group by location, population
--Order by 2
