/*------------------------------------------------------------------------------------------------------
    Description:
        Staging table for Pipedrive fields metadata.
        Contains metadata about custom fields in Pipedrive for use in downstream models.
        Source: public.fields
    last_updated: 07.12.2025
-----------------------------------------------------------------------------------------------------------*/

/* ******************************* config ********************************************************************/
{{
    config(
        materialized='view',
        tags=["stg", "fields"]
    )
}}

/* *************************************** source query *******************************************************/
select
    id as field_id,
    field_key,
    name as field_name,
    field_value_options,

    --metadata for auditing
    now() as _ingested_at,                  -- timestamp when this row was ingested
    current_timestamp as _updated_at        -- timestamp for the run

from {{ source('pipedrive_crm', 'fields') }}
