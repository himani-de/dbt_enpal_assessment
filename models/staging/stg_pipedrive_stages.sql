/*------------------------------------------------------------------------------------------------------
    Description:
        Staging table for Pipedrive deal stages.
        Represents all deal stages in the pipeline for mapping funnel steps.
        Source: public.stages
    Notes:
        - stage_name maps to funnel steps
-----------------------------------------------------------------------------------------------------------*/

/* ******************************* config ********************************************************************/
{{
    config(
        materialized='table',
        tags=["stg", "stages"]
    )
}}

/* *************************************** source query *******************************************************/
select
    stage_id,
    stage_name,

    --metadata for auditing
    now() as _ingested_at,                  -- timestamp when this row was ingested
    current_timestamp as _updated_at        -- timestamp for the run

from {{ source('pipedrive_crm', 'stages') }}
