/*------------------------------------------------------------------------------------------------------
    Description:
        Staging table for Pipedrive activity types. Represents all activity types from the source
        for reference in activities.
        Source: public.activity_types
    Notes:
        - Links to activity.type
-----------------------------------------------------------------------------------------------------------*/

/* ******************************* config ********************************************************************/
{{
    config(
        materialized='table',
        tags=["stg", "activity_types"]
    )
}}

/* *************************************** source query *******************************************************/
select
    id as activity_type_id,
    name as activity_type_name,
    cast(active as boolean) as is_active,
    type as activity_category,

    --metadata for auditing
    now() as _ingested_at,                     -- timestamp when this row was ingested
    current_timestamp as _updated_at           -- timestamp for the run

from {{ source('pipedrive_crm', 'activity_types') }}
