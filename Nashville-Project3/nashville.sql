/*
CLEANING DATA IN SQL QUERIES
*/
SELECT * FROM PortfolioProject.dbo.NashvilleHousing;
------------------------------------------------------------
--Standardize Date Format
SELECT saledate, CONVERT(Date, saledate)
FROM PortfolioProject.dbo.NashvilleHousing;

UPDATE NashvilleHousing
SET saledate = CONVERT(Date, saledate);

SELECT saledate FROM PortfolioProject.dbo.NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, saledate);

SELECT SaleDateConverted FROM PortfolioProject.dbo.NashvilleHousing;

---------------------------------------------------------------------
-- Populate Missing Property Address Data

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
WHERE propertyaddress IS NULL
ORDER BY parcelID;

SELECT n1.parcelID, n1.propertyaddress, n2.parcelID, n2.propertyaddress
, ISNULL(n1.propertyaddress, n2.propertyaddress)
FROM PortfolioProject.dbo.NashvilleHousing n1
JOIN PortfolioProject.dbo.NashvilleHousing n2
	ON n1.parcelID = n2.parcelID
	AND n1.[uniqueID ]<> n2.[uniqueID ]
WHERE n1.PropertyAddress IS NULL;

UPDATE n1 SET PropertyAddress = ISNULL(n1.propertyaddress, n2.propertyaddress)
FROM PortfolioProject.dbo.NashvilleHousing n1
JOIN PortfolioProject.dbo.NashvilleHousing n2
	ON n1.parcelID = n2.parcelID
	AND n1.[uniqueID ]<> n2.[uniqueID ]
WHERE n1.PropertyAddress IS NULL;

--------------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (address, city, state)

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE propertyaddress IS NULL
--ORDER BY parcelID;

-- Split property address with substrings
SELECT
SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress) -1) as 'Street Address'
, SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) +1, LEN(propertyaddress)) as City
FROM PortfolioProject.dbo.NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress) -1);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) +1, LEN(propertyaddress));

SELECT * FROM PortfolioProject.dbo.NashvilleHousing;

-- Split owner address with parsename
SELECT OwnerAddress 
FROM PortfolioProject.dbo.NashvilleHousing;

-- !IMPORTANT! PARSENAME will find commas in a backwards order
SELECT PARSENAME(REPLACE(owneraddress, ',','.') ,3)
,PARSENAME(REPLACE(owneraddress, ',','.') ,2)
,PARSENAME(REPLACE(owneraddress, ',','.') ,1)
FROM PortfolioProject.dbo.NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(owneraddress, ',','.') ,3);

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(owneraddress, ',','.') ,2);

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(owneraddress, ',','.') ,1);

SELECT * FROM PortfolioProject.dbo.NashvilleHousing;

---------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM PortfolioProject.dbo.NashvilleHousing;

UPDATE NashvilleHousing
SET SoldAsVacant = 
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END;

---------------------------------------------------------------------------------------------------
-- Removing Duplicates (not often used but good to know)

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY parcelID,
				 propertyaddress,
				 saleprice,
				 saledate,
				 legalreference
				 ORDER BY
					uniqueID
					) row_num
FROM PortfolioProject.dbo.NashvilleHousing
)
SELECT * FROM RowNumCTE
WHERE row_num > 1;


WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY parcelID,
				 propertyaddress,
				 saleprice,
				 saledate,
				 legalreference
				 ORDER BY
					uniqueID
					) row_num
FROM PortfolioProject.dbo.NashvilleHousing
)
DELETE FROM RowNumCTE
WHERE row_num > 1;

----------------------------------------------------------------------------------------------
-- Delete Unused Columns 

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing;

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN owneraddress, taxdistrict, propertyaddress;

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN saledate;





