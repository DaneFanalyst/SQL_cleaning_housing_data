Select *
From Portfolio_Project.dbo.NashvilleHousing

--Standarize the date
Select SaleDate, CONVERT(date,SaleDate)
From Portfolio_Project.dbo.NashvilleHousing

Alter Table NashvilleHousing
add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = Convert(date,SaleDate)

--Populate Property Address Data

Select* 
From Portfolio_Project.dbo.NashvilleHousing
Where PropertyAddress is null

Select* 
From Portfolio_Project.dbo.NashvilleHousing
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From Portfolio_Project.dbo.NashvilleHousing a
Join Portfolio_Project.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From Portfolio_Project.dbo.NashvilleHousing a
Join Portfolio_Project.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID] <> b.[UniqueID]

	-- Breaking Adress into useful columns with substring

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, Len(PropertyAddress)) as Address
From Portfolio_Project.dbo.NashvilleHousing

Use Portfolio_Project

Alter Table NashvilleHousing
add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter Table NashvilleHousing
add PropertySplitCity Nvarchar(255);

Update dbo.NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))

Select *
From Portfolio_Project.dbo.NashvilleHousing

--Breaking Address into columns using Parse

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From Portfolio_Project.dbo.NashvilleHousing

Alter Table NashvilleHousing
add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

Alter Table NashvilleHousing
add OwnerSplitCity Nvarchar(255);

Update dbo.NashvilleHousing
Set PropertySplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

Alter Table NashvilleHousing
add OwnerSplitState Nvarchar(255);

Update dbo.NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

--Changing Y and N to Yes and No in "Sold as Vacant" colummn

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Portfolio_Project.dbo.NashvilleHousing
Group by SoldAsVacant
Order by SoldAsVacant

Select SoldAsVacant, 
CASE When SoldAsVacant = 'Y' then 'yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End
From Portfolio_Project.dbo.NashvilleHousing

Use Portfolio_Project
go

Update NashvilleHousing
Set SoldAsVacant =CASE When SoldAsVacant = 'Y' then 'yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End 

-- Removing Duplicates
With RowNumCTE AS(
Select *,
	ROW_NUMBER() Over (
	Partition By ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order By 
					UniqueID
					) row_num
From Portfolio_Project.dbo.NashvilleHousing
)
DELETE
From RowNumCTE
Where row_num > 1

--Deleting unused Columns

Select * 
From Portfolio_Project.dbo.NashvilleHousing

Alter Table Portfolio_Project.dbo.NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table Portfolio_Project.dbo.NashvilleHousing
Drop Column SaleDate