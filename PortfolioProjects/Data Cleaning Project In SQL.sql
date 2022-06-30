Select * from NashvilleHousing

---------------------------------------------------------------

-- Strandize Date Format 

Select SaleDate
from   NashvilleHousing

Select  SaleDate , Convert(Date , SaleDate)
from    NashvilleHousing 

Update NashvilleHousing
set   SaleDate = Convert(Date , SaleDate)

Alter table NashvilleHousing
Add SaledateConverted Date ;

Update  NashvilleHousing
set SaledateConverted = Convert(Date , SaleDate)

--------------------------------------------------------------------------

Select * from NashvilleHousing
Select PropertyAddress from NashvilleHousing where PropertyAddress is null 

-- Populate Property Address Data 

Select    *
from      NashvilleHousing
--Where   PropertyAddress is null
Order by  ParcelID

Select     A.ParcelID , 
             A.PropertyAddress , 
			    B.ParcelID , 
				  B.PropertyAddress ,
				     Isnull(A.PropertyAddress , B.PropertyAddress)
from       NashvilleHousing as A 
Inner join NashvilleHousing as B 
On         A.ParcelID = B.ParcelID
              and A.[UniqueID ] <> B.[UniqueID ]
Where      A.PropertyAddress is null
 

Update  A
set     PropertyAddress = Isnull(A.PropertyAddress , B.PropertyAddress)
from       NashvilleHousing as A 
Inner join NashvilleHousing as B 
On         A.ParcelID = B.ParcelID
              and A.[UniqueID ] <> B.[UniqueID ]
Where      A.PropertyAddress is null

------------------------------------------------------------------------

-- Breaking Out Address Into Individual Columns (Address , City , State)

Select * from NashvilleHousing order by ParcelID

Select    PropertyAddress
from      NashvilleHousing
--Where   PropertyAddress is null
--Order by  ParcelID

Select  
SUBSTRING(PropertyAddress , 1 , CHARINDEX(',' ,PropertyAddress)-1) as Address 
, SUBSTRING(PropertyAddress , CHARINDEX(',' ,PropertyAddress) + 1 , Len(PropertyAddress)) as Address 
From     NashvilleHousing

Alter table NashvilleHousing
Add PropertysplitAddress Nvarchar(255) 

Update  NashvilleHousing
set PropertysplitAddress = SUBSTRING(PropertyAddress , 1 , CHARINDEX(',' ,PropertyAddress)-1) 


Alter table NashvilleHousing
Add PropertysplitCity Nvarchar(255) ;

Update  NashvilleHousing
set PropertysplitCity = SUBSTRING(PropertyAddress , CHARINDEX(',' ,PropertyAddress) + 1 , Len(PropertyAddress))

Select OwnerAddress
from  NashvilleHousing
order by ParcelID

select 
Parsename(replace(OwnerAddress , ',' , '.') , 1)
from  NashvilleHousing
order by ParcelID

Alter table NashvilleHousing
Add PropertysplitState Nvarchar(255) ;

Update  NashvilleHousing
set PropertysplitState = Parsename(replace(OwnerAddress , ',' , '.') , 1)

---------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "SOld as Vacant" Field 

Select distinct(SoldAsVacant) , count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2

Select    SoldAsVacant 
, Case when SoldAsVacant = 'Y' then 'Yes' 
       when SoldAsVacant = 'N' then 'No'
	   Else SoldAsVacant
  end 
from     NashvilleHousing

Update NashvilleHousing
set SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes' 
       when SoldAsVacant = 'N' then 'No'
	   Else SoldAsVacant
  end 

--------------------------------------------------------------------------------

-- Remove DUplicate 

select * from NashvilleHousing

Select *,
        Row_number() over(
		Partition by ParcelID,
		             PropertyAddress,
					 SalePrice,
					 legalReference
					 Order by 
					  UniqueID
					  ) row_num
Into  RowNumCTE
From NashvilleHousing
order by ParcelID

Select * 
from RowNumCTE
where row_num > 1
Order by PropertyAddress

Delete  
from RowNumCTE
where row_num > 1
--Order by PropertyAddress

------------------------------------------------------------------------

-- Delete Unused Column 

Select * 
from NashvilleHousing
Order by ParcelID

Alter table NashvilleHousing
drop Column OwnerAddress , PropertyAddress , TaxDistrict

Alter table NashvilleHousing
drop Column SaleDate 

Alter table RowNumCTE
drop Column OwnerAddress , PropertyAddress , TaxDistrict , SaleDate

Alter table RowNumCTE
drop Column row_num

Select * 
from RowNumCTE
where row_num > 1