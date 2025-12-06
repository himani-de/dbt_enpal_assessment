/*------------------------------------------------------------------------------------------------------
    Description:
        Staging table for Pipedrive users.
        Contains all user records for assignments and ownership reference.
        Source: public.users
    Notes:
        - contains pii column of customer
        - needs restricted access  on tables
        - mask the pii columns (future scope)
            - can be used
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
    name as user_name,
    email as user_email,
    cast(modified as timestamp) as modified_timestamp,

    now() as _ingested_at,
    current_timestamp as _updated_at

from {{ source('pipedrive_crm', 'users') }}
