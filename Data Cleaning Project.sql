--CLEANING DATA IN SQL
Select *
From PortfolioProject..NashvilleHousing

--Standardizing Date Format
Select SaleDate, CONVERT(Date,SaleDate) --This is what we want the SaleDate to look like
From PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

--Populate Property Address
Select NVH.ParcelID, NVH.PropertyAddress, NVH2.ParcelID, NVH2.PropertyAddress, ISNULL(NVH.PropertyAddress, NVH2.PropertyAddress)
From PortfolioProject..NashvilleHousing as NVH
Join PortfolioProject..NashvilleHousing as NVH2
	on NVH.ParcelID = NVH2.ParcelID 
	AND NVH.[UniqueID ] <> NVH2.[UniqueID ]
Where NVH.PropertyAddress is null

Update NVH
SET PropertyAddress = ISNULL(NVH.PropertyAddress, NVH2.PropertyAddress)
From PortfolioProject..NashvilleHousing as NVH
Join PortfolioProject..NashvilleHousing as NVH2
	on NVH.ParcelID = NVH2.ParcelID 
	AND NVH.[UniqueID ] <> NVH2.[UniqueID ]
Where NVH.PropertyAddress is null

--Separating PropertyAddress (Using Substrings)
Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) As Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) As City
From PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add StreetAddress nvarchar(255), City nvarchar(255);

Update NashvilleHousing
SET  StreetAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1), 
City = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

--Separate OwnerAddress
Select
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerStreetAddress nvarchar(255), OwnerCity nvarchar(255), OwnerState nvarchar(255);

Update NashvilleHousing
SET  OwnerStreetAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3), 
OwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2),
OwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

--Update "Sold as Vacant" Category
Update NashvilleHousing
SET SoldAsVacant = CASE	When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant= 'N' Then 'No'
		Else SoldAsVacant
		END
From PortfolioProject..NashvilleHousing

--Removing Duplicates
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order by UniqueID) row_num
From PortfolioProject..NashvilleHousing
)
DELETE
From RowNumCTE
Where row_num > 1

-- Delete Redundant/Unused Columns
Alter table PortfolioProject..NashvilleHousing
Drop Column OwnerAddress, PropertyAddress, SaleDate