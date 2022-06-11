
Use PortfolioProject

select *
from PortfolioProject.dbo.NashvillHousing

-- Converting Datetime to Date type:

alter table NashvillHousing
add saledateConverted Date;

update NashvillHousing
set saledateConverted  = convert(date, saledate)

select saledateConverted, convert(date, saledate)
from PortfolioProject.dbo.NashvillHousing


--------------------------------------------------------------------------------%
-- populate proprty address data

select *
from PortfolioProject.dbo.NashvillHousing
--where propertyAddress is null
order by ParcelID


select Nashvil1.ParcelID, Nashvil1.PropertyAddress, Nashvil2.ParcelID, Nashvil2.PropertyAddress, ISNULL(Nashvil1.PropertyAddress, Nashvil2.PropertyAddress)
from PortfolioProject.dbo.NashvillHousing Nashvil1
join PortfolioProject.dbo.NashvillHousing Nashvil2
	on Nashvil1.ParcelID= Nashvil2.ParcelID
	and Nashvil1.[UniqueID ]<> Nashvil2.[UniqueID ]
where Nashvil1.PropertyAddress is null


update Nashvil1
set PropertyAddress = ISNULL(Nashvil1.PropertyAddress, Nashvil2.PropertyAddress)
from PortfolioProject.dbo.NashvillHousing Nashvil1
join PortfolioProject.dbo.NashvillHousing Nashvil2
	on Nashvil1.ParcelID = Nashvil2.ParcelID
	and Nashvil1.[UniqueID ]<> Nashvil2.[UniqueID ]



------------------------------------------------------------%

-- Modifying PropertyAddress (Splitting it into two seperate coumns of 'Address' and 'City'):

select PropertyAddress
from PortfolioProject.dbo.NashvillHousing

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(propertyAddress)) Address
from PortfolioProject.dbo.NashvillHousing


alter table NashvillHousing
add PropertySplitAddress nvarchar(255);

update NashvillHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

alter table NashvillHousing
add PropertySplitCity nvarchar(255)

update NashvillHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(propertyAddress))


select *
from PortfolioProject.dbo.NashvillHousing


-- Splitting OwnerAddress to Home, City and State:

select
PARSeNAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from PortfolioProject.dbo.NashvillHousing

alter table NashvillHousing
add OwnerSplitAddress nvarchar(255)

update NashvillHousing
set OwnerSplitAddress = PARSeNAME(REPLACE(OwnerAddress, ',', '.'), 3)

alter table NashvillHousing
add OwnerSplitCity nvarchar(255)

update NashvillHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

alter table NashvillHousing
add OwnerSplitState nvarchar(255)

update NashvillHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

select *
from PortfolioProject.dbo.NashvillHousing
where OwnerAddress is not null


-------------------------------------------------------------------%

-- Change 'Y' , 'N' to 'Yes' , 'No' :


select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject.dbo.NashvillHousing
group by SoldAsVacant
order by 2


select SoldAsVacant,
CASE when SoldAsVacant = 'Y' then 'YES'
	 when SoldAsVacant = 'N' then 'No'
	 ELSE SoldAsVacant
	 END 
from PortfolioProject.dbo.NashvillHousing


update NashvillHousing
set SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'YES'
	 when SoldAsVacant = 'N' then 'No'
	 ELSE SoldAsVacant
	 END


---------------------------------------------------------------------------%

-- Remove Duplicates

with RownumCTE as(
select *,
	 Row_number() over (partition by ParcelID, 
									 PropertyAddress, 
									 SaleDate,SalePrice, 
									 LegalReference
									 Order by UniqueID) row_num
from PortfolioProject.dbo.NashvillHousing)
-- order by ParcelID

DELETE
from RownumCTE
where row_num >1

----------------------------------------------------------------------%

-- Remove Unused Columns

Alter Table PortfolioProject.dbo.NashvillHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Select *
from PortfolioProject.dbo.NashvillHousing

Alter Table NashvillHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

