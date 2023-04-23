/*

-- Data Cleaning in SQL Qureies (Project) 

*/


SELECT *
FROM PortfolioProject..NashvilleHousing


-----------------------------------------------------------------------------------------------

-- Standard data format


ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM PortfolioProject..NashvilleHousing


------------------------------------------------------------------------------------------------------------

-- Populating missing Property Address data

SELECT*
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT alpha.ParcelID, alpha.PropertyAddress, bravo.ParcelID, bravo.PropertyAddress, ISNULL(alpha.PropertyAddress, bravo.PropertyAddress)
FROM PortfolioProject..NashvilleHousing alpha
JOIN PortfolioProject..NashvilleHousing bravo
	ON alpha.ParcelID = bravo.ParcelID
	AND alpha.[UniqueID ] <> bravo.[UniqueID ]
WHERE alpha.PropertyAddress is null

UPDATE alpha
SET PropertyAddress = ISNULL(alpha.PropertyAddress, bravo.PropertyAddress)
FROM PortfolioProject..NashvilleHousing alpha
JOIN PortfolioProject..NashvilleHousing bravo
	ON alpha.ParcelID = bravo.ParcelID
	AND alpha.[UniqueID ] <> bravo.[UniqueID ]
WHERE alpha.PropertyAddress is null


-------------------------------------------------------------------------------------------------------------

-- Breaking Address into individual Columns (Address, City, State)
-- Substring

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress is null
--ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS Address

FROM PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing 
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


-- Clear
SELECT *
FROM PortfolioProject..NashvilleHousing


-- Splitting Owner Address (Address, City, State)
-- Parsname

SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing 
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing 
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


SELECT *
FROM PortfolioProject..NashvilleHousing



-----------------------------------------------------------------------------------------------------------

--  Correct Y and N to Yes and No in "SoldAs Vacant" field


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2



SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM PortfolioProject..NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

-- Clear
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant



-------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
SELECT*, 
	ROW_NUMBER() OVER(
		PARTITION BY ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
		Order BY UniqueID
	) row_num

FROM PortfolioProject..NashvilleHousing
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num >1
ORDER BY propertyAddress


WITH RowNumCTE AS(
SELECT*, 
	ROW_NUMBER() OVER(
		PARTITION BY ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
		Order BY UniqueID
	) row_num

FROM PortfolioProject..NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num >1

-- CLEAR

SELECT*
FROM PortfolioProject..NashvilleHousing



-------------------------------------------------------------------------------------------

--Delete unused columns

SELECT*
FROM PortfolioProject..NashvilleHousing


ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress, TaxDistrict

-- Clear



------------------------------------------------------------------------------------------------------------------

-- Summary

--		What I did to Organize and clean this data was by first repopulating missing property address. Seperating the address so that it could be easily accessed when looking 
-- through the data by using substring, charindex and parsname. Then correct "Sold As Vacant" case statements from Y and N to Yes and No. To finish off and complete the data 
-- cleaning process I removed all dulipicate rows using CTE and windows function Partition by and delete columns that were no longer useful to me.
