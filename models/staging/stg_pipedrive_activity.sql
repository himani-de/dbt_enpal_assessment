/*------------------------------------------------------------------------------------------------------
    Description:
        Staging table for Pipedrive activities.
        Source: public.activity

 last_updated: 07.12.2025
-----------------------------------------------------------------------------------------------------------*/
/* ******************************* config ********************************************************************/
{{
    config(
        materialized='view',
        tags=["stg", "activity"],
    )
}}
/* *************************************** source query *******************************************************/

select
    activity_id,
    type as activity_type,
    deal_id,
    assigned_to_user as user_id,
    done as done_flag,
    --converted boolean values to human readable text
    case
        when done = true then 'Yes'
        when done = false then 'No'
    end as done_text,
    cast(due_to as date) as due_date,

    --metadata for auditing
    now() as _ingested_at,                  -- timestamp when this row was ingested
    current_timestamp as _updated_at        -- timestamp for the run

from
{{ source('pipedrive_crm', 'activity') }}
