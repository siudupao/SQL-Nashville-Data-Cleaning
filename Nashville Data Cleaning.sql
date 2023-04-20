-- Data Cleaning with SQL using Nashville Housing Data 

SELECT * 
FROM NashvilleProject.dbo.NashvilleHousing

-- 1. Convert SaleDate Date Format
SELECT SaleDate, CONVERT(Date, SaleDate)
FROM NashvilleProject.dbo.NashvilleHousing 

ALTER TABLE NashvilleProject.dbo.NashvilleHousing
ADD SaleDateNew Date

UPDATE NashvilleProject.dbo.NashvilleHousing
SET SaleDateNew = CONVERT(Date, SaleDate)

SELECT SaleDate, SaleDateNew
FROM NashvilleProject.dbo.NashvilleHousing 

-- 2. Populate Null Property Address Data 

SELECT * 
FROM NashvilleProject.dbo.NashvilleHousing 
WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT t1.UniqueID, t1.ParcelID, t1.PropertyAddress, t2.UniqueID, t2.ParcelID, t2.PropertyAddress, ISNULL(t1.PropertyAddress, t2.PropertyAddress)
FROM NashvilleProject.dbo.NashvilleHousing t1
JOIN NashvilleProject.dbo.NashvilleHousing t2
	ON t1.ParcelID = t2.ParcelID
	AND t1.UniqueID <> t2.UniqueID
WHERE t1.PropertyAddress IS NULL

UPDATE t1
SET PropertyAddress = ISNULL(t1.PropertyAddress, t2.PropertyAddress)
FROM NashvilleProject.dbo.NashvilleHousing t1
JOIN NashvilleProject.dbo.NashvilleHousing t2
	ON t1.ParcelID = t2.ParcelID
	AND t1.UniqueID <> t2.UniqueID
WHERE t1.PropertyAddress IS NULL

-- 3.a Splitting PropertyAddress Into Multiple Columns (Street, City)

SELECT PropertyAddress
FROM NashvilleProject.dbo.NashvilleHousing 

SELECT PARSENAME(REPLACE(PropertyAddress,',','.'), 2) AS Street, PARSENAME(REPLACE(PropertyAddress,',','.'),1) AS City
FROM NashvilleProject.dbo.NashvilleHousing 

ALTER TABLE NashvilleProject.dbo.NashvilleHousing 
ADD PropertyStreet Nvarchar(255),
	PropertyCity Nvarchar(255)

UPDATE NashvilleProject.dbo.NashvilleHousing 
SET PropertyStreet = PARSENAME(REPLACE(PropertyAddress,',','.'),2), 
	PropertyCity = PARSENAME(REPLACE(PropertyAddress,',','.'),1)

-- 3.b Splitting OwnerAddress Into Multiple Columns (Street, City, State)

SELECT OwnerAddress
FROM NashvilleProject.dbo.NashvilleHousing 

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'), 3) AS Street, PARSENAME(REPLACE(OwnerAddress,',','.'),2) AS City, PARSENAME(REPLACE(OwnerAddress,',','.'),1) AS State
FROM NashvilleProject.dbo.NashvilleHousing

ALTER TABLE NashvilleProject.dbo.NashvilleHousing 
ADD OwnerStreet Nvarchar(255),
	OwnerCity Nvarchar(255),
	OwnerState Nvarchar(255)

UPDATE NashvilleProject.dbo.NashvilleHousing 
SET OwnerStreet = PARSENAME(REPLACE(OwnerAddress,',','.'), 3), 
	OwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	OwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

-- 4. Converting Y and N to Yes and No under SoldAsVacant

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) as Count
FROM NashvilleProject.dbo.NashvilleHousing 
GROUP BY SoldAsVacant
ORDER BY 2 desc

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM NashvilleProject.dbo.NashvilleHousing 

UPDATE NashvilleProject.dbo.NashvilleHousing 
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

-- 5. Dropping Duplicate Rows
WITH duplicateCTE AS(
SELECT *, ROW_NUMBER() OVER(
	PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference
	ORDER BY UniqueID) row_num
FROM NashvilleProject.dbo.NashvilleHousing
	)
DELETE
FROM duplicateCTE
WHERE row_num > 1

-- 6. Dropping Unused Columns

SELECT *
FROM NashvilleProject.dbo.NashvilleHousing

ALTER TABLE NashvilleProject.dbo.NashvilleHousing 
DROP COLUMN PropertyAddress,
	SaleDate,
	OwnerAddress 