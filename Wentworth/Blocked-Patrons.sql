--metadb:function Blocked-Patrons

DROP FUNCTION IF EXISTS Blocked-Patrons
CREATE FUNCTION Blocked-Patrons()
  
--This report finds patrons in the Wentworth system that meet the block criteria, not necessarily patrons that currently have a block
AS $$
select ug.user_id, ug.user_last_name, ug.user_first_name, ug.barcode, ug.user_email, ug.group_name, count(loan_id), sum(faa.account_balance), 'Max checkouts exceeded' as block_reason from 
folio_derived.users_groups ug
left join folio_derived.loans_items li on (li.user_id = ug.user_id) 
left join folio_derived.feesfines_accounts_actions faa on (faa.user_id = ug.user_id) 
where loan_status = 'Open' and (ug.group_name = 'Alumnus' or ug.group_name = 'FLO User')
group by ug.user_id, ug.user_last_name, ug.user_first_name, ug.barcode, ug.user_email, ug.group_name, faa.account_balance
having count(loan_id) = 15
UNION
select ug.user_id, ug.user_last_name, ug.user_first_name, ug.barcode, ug.user_email, ug.group_name, count(loan_id), sum(faa.account_balance), 'Max checkouts exceeded' as block_reason from 
folio_derived.users_groups ug
left join folio_derived.feesfines_accounts_actions faa on (faa.user_id = ug.user_id) 
left join folio_derived.loans_items li on (li.user_id = ug.user_id) 
where loan_status = 'Open' and ug.group_name = 'Student'
group by ug.user_id, ug.user_last_name, ug.user_first_name, ug.barcode, ug.group_name, faa.account_balance, ug.user_email
having count(loan_id) = 50
UNION
select ug.user_id, ug.user_last_name, ug.user_first_name, ug.barcode, ug.user_email, ug.group_name, count(loan_id), sum(faa.account_balance), 'Max checkouts exceeded' as block_reason from 
folio_derived.users_groups ug
left join folio_derived.feesfines_accounts_actions faa on (faa.user_id = ug.user_id) 
left join folio_derived.loans_items li on (li.user_id = ug.user_id) 
where loan_status = 'Open' and ug.group_name in ('Library Staff', 'Graduate', 'Staff') 
group by ug.user_id, ug.user_last_name, ug.user_first_name, ug.barcode, ug.group_name, faa.account_balance, ug.user_email
having count(loan_id) = 100
UNION
select ug.user_id, ug.user_last_name, ug.user_first_name, ug.barcode, ug.user_email, ug.group_name, count(loan_id), sum(faa.account_balance), 'Max lost items exceeded' as block_reason from 
folio_derived.users_groups ug
left join folio_derived.feesfines_accounts_actions faa on (faa.user_id = ug.user_id) 
left join folio_derived.loans_items li on (li.user_id = ug.user_id) 
where loan_status = 'Open' and li.item_status like '%lost%' and ug.group_name in ('Alumnus', 'Emeritus', 'Graduate', 'Library Staff', 'Student') 
group by ug.user_id, ug.user_last_name, ug.user_first_name, ug.barcode, ug.group_name, faa.account_balance, ug.user_email
having count(loan_id) = 10
UNION
select ug.user_id, ug.user_last_name, ug.user_first_name, ug.barcode, ug.user_email, ug.group_name, count(loan_id), sum(faa.account_balance), 'Max lost items exceeded' as block_reason from 
folio_derived.users_groups ug
left join folio_derived.feesfines_accounts_actions faa on (faa.user_id = ug.user_id) 
left join folio_derived.loans_items li on (li.user_id = ug.user_id) 
where loan_status = 'Open' and li.item_status like '%lost%' and ug.group_name = 'FLO User'
group by ug.user_id, ug.user_last_name, ug.user_first_name, ug.barcode, ug.group_name, faa.account_balance, ug.user_email
having count(loan_id) = 1
UNION
select ug.user_id, ug.user_last_name, ug.user_first_name, ug.barcode, ug.user_email, ug.group_name, count(loan_id), sum(faa.account_balance), 'Max fine balance exceeded' as block_reason
from folio_derived.users_groups ug
left join folio_derived.loans_items li on (li.user_id = ug.user_id) 
left join folio_derived.feesfines_accounts_actions faa on (faa.user_id = ug.user_id) 
where faa.fine_status = 'Open' and faa.account_balance > 1000 and ug.group_name in ('Emeritus', 'Faculty', 'Graduate', 'Library Staff', 'Staff', 'Student') 
group by ug.user_id, ug.user_last_name, ug.user_first_name, ug.barcode, ug.group_name, faa.account_balance, ug.user_email
$$

LANGUAGE SQL
STABLE
PARALLEL SAFE;
