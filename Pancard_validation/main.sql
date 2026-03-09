select * from pancard_data;
select count(*) from pancard_data;

ALTER TABLE pancard_data
RENAME COLUMN pancard TO pan_number;

-- handling missing data:

select * from pancard_data where pancard is null

-- check for duplicates:

select pan_number , count(1)
from pancard_data
group by pancard
having count(1)>1;  -- we can use distinct

-- handle leading spaces:

select * from pancard_data where pan_number <> trim(pan_number);

-- correct letter case:

select * from pancard_data where pan_number <> upper(pan_number);

-- cleaned pan number:
select distinct upper(trim(pan_number)) as pan_number
from pancard_data
where pan_number is not null
and trim(pan_number) <> '';

-- function to check if side by side characters are the same
-- Returns true if side by side character are same else returns false
create or replace function duplicate_check(pan text)
returns boolean
language plpgsql
as $$
begin
	for i in 1 .. (length(pan) - 1)
	loop
		if substring(pan, i, 1) = substring(pan, i+1, 1)
		then 
			return true;
		end if;
	end loop;
	return false;
end;
$$
-- select duplicate_check('SSUUR')


-- Function to check if characters are sequencial such as ABCDE, LMNOP, XYZ etc. 
-- Returns true if characters are sequencial else returns false
CREATE or replace function sequence_check(pan text)
returns boolean
language plpgsql
as $$
begin
	for i in 1 .. (length(pan) - 1)
	loop
		if ascii(substring(pan, i+1, 1)) - ascii(substring(pan, i, 1)) <> 1
		then 
			return false;
		end if;
	end loop;
	return true;
end;
$$

-- ascii values
select ascii('s')
-- select sequence_check('ABCDE')


-- Valid Invalid PAN categorization
create or replace view valid_invalid_pans 
as 
with cleaned_pan as
		(select distinct upper(trim(pan_number)) as pan_number
		from pancard_data
		where pan_number is not null
		and TRIM(pan_number) <> ''),
	    valid_pan as
		(select *
		from cleaned_pan
		where duplicate_check(pan_number) = 'false'
		and sequence_check(substring(pan_number,1,5)) = 'false'
		and sequence_check(substring(pan_number,6,4)) = 'false'
		and pan_number ~ '^[A-Z]{5}[0-9]{4}[A-Z]$')
select cln.pan_number
, case when vld.pan_number is null 
			then 'Invalid PAN' 
	   else 'Valid PAN' 
  end as status
from cleaned_pan cln
left join valid_pan vld on vld.pan_number = cln.pan_number;

-- select * from valid_invalid_pans;


-- prints the total summary of the dataset
with summary as 
	(SELECT 
	    (SELECT COUNT(*) FROM pancard_data) AS total_processed_records,
	    COUNT(*) FILTER (WHERE vw.status = 'Valid PAN') AS total_valid_pans,
	    COUNT(*) FILTER (WHERE vw.status = 'Invalid PAN') AS total_invalid_pans
	from  valid_invalid_pans vw)
select total_processed_records, total_valid_pans, total_invalid_pans
, total_processed_records - (total_valid_pans+total_invalid_pans) as missing_incomplete_PANS
from summary;
  

