/*

Cleaning Data in SQL Queries

*/


Select *
From PortfolioProject.dbo.NashvilleHousing
--------------------------------------------------------------------------------------

-- Standardize Date Format

Select SaleDate, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

--------------------------------------------------------------------------------------

--Populate Property Address Data

Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID



Select a.parcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.parcelID = b.parcelID
	AND a.UniqueID <> b.UniqueID
	Where a.propertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.parcelID = b.parcelID
	AND a.UniqueID <> b.UniqueID
where a.PropertyAddress is null


-----------------------------------------------------------------------------------

--Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


Select*
From PortfolioProject.dbo.NashvilleHousing


Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress,',','.'), 3)
,PARSENAME(REPLACE(OwnerAddress,',','.'), 2)
,PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255)

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)


Select*
From PortfolioProject.dbo.NashvilleHousing

-------------------------------------------------------------------------------------


--Change Y and N TO Yes and No in "Sold as Vacant" Field

Select Distinct(SoldasVacant), Count(SoldasVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldasVacant
Order by 2



Select Soldasvacant
, CASE WHEN Soldasvacant = 'Y' THEN 'Yes'
		WHEN Soldasvacant = 'N' THEN 'No'
		Else Soldasvacant
		END
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET Soldasvacant = CASE WHEN Soldasvacant = 'Y' THEN 'Yes'
		WHEN Soldasvacant = 'N' THEN 'No'
		Else Soldasvacant
		END

--------------------------------------------------------------------------------

--Remove Duplicates
WITH RowNumCTE as(
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
Where row_num >1
--Order by PropertyAddress

------------------------------------------------------------------------------------


-- Delete Unused Columns



Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate