/*
Data Cleaning in SQL queries
*/


SELECT *
FROM PortfolioProject..NashvilleHousing

--Standardize dates formats
SELECT SaleDateConverted, CONVERT(Date, SaleDate) 
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

---------------------------------------------------------------------------------------------

--POPULATE PROPERTY ADDRESS DATA
 
 SELECT *
 FROM PortfolioProject..NashvilleHousing
 --WHERE PROPERTYID IS NULL
 ORDER BY ParcelID

 SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
 FROM PortfolioProject..NashvilleHousing a
 JOIN PortfolioProject..NashVilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[uniqueID ] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL
ORDER BY a.ParcelID

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
 JOIN PortfolioProject..NashVilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


--BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)

 SELECT PropertyAddress
 FROM PortfolioProject..NashvilleHousing
 --WHERE PROPERTYID IS NULL
-- ORDER BY ParcelID

SELECT
SUBSTRING (PropertyAddress, 1 , CHARINDEX(',' , PropertyAddress) -1 ) As Address,
SUBSTRING (PropertyAddress, CHARINDEX(',' , PropertyAddress) +1, LEN(PropertyAddress )) As Address

 FROM PortfolioProject..NashvilleHousing

 ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

SELECT *
FROM NashvilleHousing

SELECT OwnerAddress
FROM NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',' , '.'),  3),
PARSENAME(REPLACE(OwnerAddress, ',' , '.'),  2),
PARSENAME(REPLACE(OwnerAddress, ',' , '.'),  1)
FROM NashVilleHousing



ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.'),  3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.'),  2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' , '.'),  1)

SELECT *
FROM PortfolioProject..NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to YES and NO in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant),
COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
			WHEN SoldAsVacant = 'N' THEN 'NO'
			ELSE SoldAsVacant
END
FROM PortfolioProject..NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant=  CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
			WHEN SoldAsVacant = 'N' THEN 'NO'
			ELSE SoldAsVacant
END


-----------------------------------------------------------------------------------------------------------------------------------

--Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Column

SELECT *
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate




