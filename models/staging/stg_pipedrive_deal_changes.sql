/*------------------------------------------------------------------------------------------------------
    Description:
        Staging table for Pipedrive deal changes.
        Contains historical changes for deals to track status and updates.
        Source: public.deal_changes
    Notes:
        - change_time is the source of truth deal change status
   last_updated: 07.12.2025
-----------------------------------------------------------------------------------------------------------*/

/* ******************************* config ********************************************************************/
{{
    config(
        materialized='view',
        tags=["stg", "deal_changes"]
    )
}}

/* *************************************** source query *******************************************************/
select
    deal_id,
    cast(change_time as timestamp) as change_timestamp,
    changed_field_key,
    new_value,

    --metadata for auditing
    now() as _ingested_at,                     -- timestamp when this row was ingested
    current_timestamp as _updated_at           -- timestamp for the run

from {{ source('pipedrive_crm', 'deal_changes') }}
