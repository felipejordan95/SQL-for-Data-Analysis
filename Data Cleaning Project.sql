-- Cleaning Data in SQL Queries

-- Displaying the entire table
SELECT * FROM [NashvilleHousing]

-- Standardize Date Format

-- Selecting SaleDate and converting it to date format
SELECT SaleDate, CONVERT(date, SaleDate)
FROM [dbo].[NashvilleHousing]

-- Updating the SaleDate column to date format
UPDATE [dbo].[NashvilleHousing]
SET SaleDate = CONVERT(date, SaleDate)
------------------------------------------------------------------------------------------------------------

-- Populate Property Address data (Filling Blank spaces)

-- Inspecting rows with null PropertyAddress
SELECT *
FROM [dbo].[NashvilleHousing]
WHERE PropertyAddress IS NULL

-- Filling null values with ISNULL function
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [dbo].[NashvilleHousing] a 
JOIN [dbo].[NashvilleHousing] b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

-- Updating filled values in the original table
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [dbo].[NashvilleHousing] a 
JOIN [dbo].[NashvilleHousing] b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL
-------------------------------------------------------------------------------------------------------------

-- Breaking out address into individual columns (Address, City, State)

-- Inspecting the PropertyAddress column
SELECT PropertyAddress
FROM [dbo].[NashvilleHousing]

-- Splitting the address column into Address and City
SELECT
    SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
    SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress) - CHARINDEX(',', PropertyAddress)) AS City
FROM NashvilleHousing

-- Adding new columns and updating the table
ALTER TABLE NashvilleHousing ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE NashvilleHousing ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress) - CHARINDEX(',', PropertyAddress))

-- Splitting Owner Address using PARSENAME 

-- Inspecting the OwnerAddress column
SELECT OwnerAddress
FROM NashvilleHousing

-- Splitting the OwnerAddress column into OwnerSplitAddress, OwnerSplitCity, and OwnerSplitState
SELECT
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS OwnerSplitAddress,
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS OwnerSplitCity,
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS OwnerSplitState
FROM NashvilleHousing

-- Adding and updating new columns
ALTER TABLE NashvilleHousing ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-- Displaying the final table
SELECT * FROM NashvilleHousing
------------------------------------------------------------------------------------------------------------------

-- Change 1 and 0 to Yes and No in "Sold as Vacant" field

-- Inspecting SoldAsVacant values and counts
SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant

-- Changing the data type of the column to change values (0, 1) to strings (Yes, No)
ALTER TABLE NashvilleHousing ALTER COLUMN SoldAsVacant VARCHAR(3); 

-- Updating the table to display Yes and No
UPDATE NashvilleHousing
SET SoldAsVacant = 
    CASE 
        WHEN SoldAsVacant = '0' THEN 'No'
        WHEN SoldAsVacant = '1' THEN 'Yes'
        ELSE SoldAsVacant
    END;
-------------------------------------------------------------------------------------------------------------

-- Remove duplicates

-- CTE to assign row numbers to duplicates
WITH RowNumCTE AS (
    SELECT *,
        ROW_NUMBER() OVER(
        PARTITION BY ParcelID, 
                    PropertyAddress, 
                    SalePrice, 
                    SaleDate,
                    LegalReference
        ORDER BY UniqueID) AS row_num
    FROM NashvilleHousing
)

-- Deleting duplicated rows
DELETE
FROM RowNumCTE
WHERE row_num > 1

---------------------------------------------------------------------------------------------------------

-- Delete unused columns

-- Displaying the entire table
SELECT * FROM NashvilleHousing

-- Removing unnecessary columns
ALTER TABLE Nashvillehousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress
