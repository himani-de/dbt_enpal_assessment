/*------------------------------------------------------------------------------------------------------
    Description:
        Staging table for Pipedrive users.
        Contains all user records for assignments and ownership reference.
        Source: public.users
    Notes:
        - contains pii column of customer
        - needs restricted access  on tables
        - md5 is used to mask the pii columns(name, email)
            * for techdebt, SHA256 can be used instead md5 as sha256 is more reliable
-----------------------------------------------------------------------------------------------------------*/

/* ******************************* config ********************************************************************/
{{
    config(
        materialized='table',
        tags=["stg", "users"]
    )
}}

/* *************************************** source query *******************************************************/
select
    id as user_id,
    md5(name) as name_hash,          -- hash the pii column using digest function as postgres supports di
    md5(email) as email_hash,         -- hash the pii column using digest function as postgres supports digest
    cast(modified as timestamp) as modified_timestamp,

    now() as _ingested_at,
    current_timestamp as _updated_at

from {{ source('pipedrive_crm', 'users') }}
