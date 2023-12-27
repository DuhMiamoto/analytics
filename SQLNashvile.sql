/* 
Cleaning Data in SQL Queries
*/ 

Select SaleDateConvert
From PortfolioProject .. NashvileHousing

ALTER TABLE NashvileHousing
ADD SaleDateConvert Date;

Update NashvileHousing
Set SaleDateConvert = Convert(Date, SaleDate)
---------------------------------------------------------------------------------------------
-- Populate property address data

Select *
From PortfolioProject .. NashvileHousing
--where PropertyAddress is null
order by ParcelID


Select 
	a.ParcelID,
	a.PropertyAddress,
	b.ParcelID, 
	b.PropertyAddress,
	ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject .. NashvileHousing a 
join PortfolioProject .. NashvileHousing b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

UPDATE a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject .. NashvileHousing a 
join PortfolioProject .. NashvileHousing b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]

-------------------------------------------------------------------------------
-- Breaking out adress into individual columns (Adress, City, State)

Select PropertyAddress
From PortfolioProject .. NashvileHousing
--where PropertyAddress is null
--order by ParcelID

SELECT 
    SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
    SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS AddressPart2
FROM PortfolioProject..NashvileHousing;

Alter table NashvileHousing
Add PropertySplitAdress nvarchar(255)

Update NashvileHousing
set PropertySplitAdress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

Alter table NashvileHousing
Add PropertySplitCity nvarchar(255)

Update NashvileHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))



Select OwnerAddress
From PortfolioProject .. NashvileHousing


Select
	PARSENAME(Replace(OwnerAddress, ',', '.'),  3),
	PARSENAME(Replace(OwnerAddress, ',', '.'),  2),
	PARSENAME(Replace(OwnerAddress, ',', '.'),  1)
From PortfolioProject .. NashvileHousing

Alter table NashvileHousing
Add OwnerSplitAdress nvarchar(255)

Update NashvileHousing
set OwnerSplitAdress = PARSENAME(Replace(OwnerAddress, ',', '.'),  3)

Alter table NashvileHousing
Add OwnerSplitCity nvarchar(255)

Update NashvileHousing
set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'),  2)

Alter table NashvileHousing
Add OwnerSplitState nvarchar(255)

Update NashvileHousing
set OwnerSplitState =PARSENAME(Replace(OwnerAddress, ',', '.'),  1)

select * 
from PortfolioProject .. NashvileHousing

------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select
	Distinct(SoldAsVacant),
	Count(SoldASVacant)
From PortfolioProject .. NashvileHousing
Group by SoldAsVacant
Order by 2

Select 
	SoldAsVacant, 
	Case when SoldAsVacant = 'Y' THEN 'YES'
		 When SoldAsVacant = 'N' THEN 'NO'
		 ELSE SoldAsVacant
		 END
From PortfolioProject .. NashvileHousing


Update NashvileHousing
Set SoldAsVacant = 	Case when SoldAsVacant = 'Y' THEN 'YES'
		 When SoldAsVacant = 'N' THEN 'NO'
		 ELSE SoldAsVacant
		 END
-------------------------------------------------------------------------------------------------------
-- Remove duplicates

--CTE 
With ROWNUMCTE AS (
Select *, 
	   ROW_NUMBER() OVER (
	   Partition by ParcelID,
					PropertyAddress,
					SaleDate,
					LegalReference
					ORDER BY 
						UniqueID
	   )row_num
From PortfolioProject .. NashvileHousing
--Order by ParcelID
)

Select * 
From ROWNUMCTE
where row_num > 1
Order by PropertyAddress
----------------------------------------------------------------------------------------------

-- Delete Unused columns

select * 
From PortfolioProject .. NashvileHousing

Alter Table PortfolioProject .. NashvileHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table PortfolioProject .. NashvileHousing
Drop Column SaleDate