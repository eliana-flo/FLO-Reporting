--metadb:function demo

DROP FUNCTION IF EXISTS demo;

CREATE FUNCTION demo(
    start_date date DEFAULT '2000-01-01',
    end_date date DEFAULT '2050-01-01')
RETURNS TABLE(
    user_id uuid,
    barcode text,
    created_date timestamptz)
AS $$
SELECT user_id,
       barcode,
       created_date
    FROM folio_derived.users_groups
    WHERE start_date <= created_date AND created_date < end_date
$$
LANGUAGE SQL
STABLE
PARALLEL SAFE;
