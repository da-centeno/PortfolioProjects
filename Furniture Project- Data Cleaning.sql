SELECT *
  FROM PortfolioProject..FurniturePricePrediction

--Organizing Table
ALTER TABLE FurniturePricePrediction
Add FurnitureName nvarchar(255);

ALTER TABLE FurniturePricePrediction
Add Website nvarchar(255);

--Adding a column for Furniture Name and adding name to those without one
Update FurniturePricePrediction
SET FurnitureName = furniture

Select 
SUBSTRING(Website,CHARINDEX('ar',Website)+3,CHARINDEX('.html',Website)-30) as Furniture
From FurniturePricePrediction

Update FurniturePricePrediction
SET FurnitureName = SUBSTRING(Website,CHARINDEX('ar',Website)+3,CHARINDEX('.html',Website)-30)
WHERE FurnitureName is null

ALTER TABLE FurniturePricePrediction
DROP COLUMN furniture

--Changing Column name from url to be more clear
Update FurniturePricePrediction
SET Website = url

ALTER TABLE FurniturePricePrediction
DROP COLUMN url

--Setting Price to 0 when null
Update FurniturePricePrediction
SET price = CASE When price is null Then 0
			Else price
			END
From PortfolioProject..FurniturePricePrediction