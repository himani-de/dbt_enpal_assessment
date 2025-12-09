/*------------------------------------------------------------------------------------------------------
  -- Description: Enriched deal_changes with stages for funnel analysis
  -- Last updated: 2025-12-07
  -- Captures **main stage transitions** only (Lead → Qualified Lead → … → Renewal/Expansion).
  -- Sub-steps like Sales Call 1/2 are not included here.
  -- Produces deterministic surrogate key for incremental merge
-----------------------------------------------------------------------------------------------------------*/

{{
    config(
        materialized='incremental',
        unique_key='deal_changes_sk',
        incremental_strategy='merge',
        tags=['int','deal_changes']
    )
}}

/* *************************************** query *******************************************************/

with raw_deal_changes as (

    select
      distinct
        {{ dbt_utils.surrogate_key(['deal_id', 'change_timestamp', 'changed_field_key', 'coalesce(new_value, \'\')']) }} as deal_changes_sk,
        deal_id,
        change_timestamp,
        changed_field_key,
        new_value,
        case
            when lower(changed_field_key) = 'stage_id'
            then new_value::int
        end as new_stage_id,
        -- audit columns or int layer
        current_timestamp as _ingested_at,
        current_timestamp as _updated_at
    from {{ ref('stg_pipedrive_deal_changes') }}
    where lower(changed_field_key) = 'stage_id'
    --only fetches rows with change_timestamp newer than the max in the existing table
    {% if is_incremental() %}
        and change_timestamp > (select coalesce(max(change_timestamp), '1900-01-01') from {{ this }})
    {% endif %}
),

deduplicated_deal_changes as (
    select *
    from (
        select
            *,
            row_number() over (
                partition by deal_changes_sk
                order by change_timestamp desc
            ) as rn
        from raw_deal_changes
    )
    where rn = 1
),

-- Join with stages table to get human-readable stage names
deal_changes_enriched as (
    select
        ddc.*,
        {{ map_stage_name_to_kpi('s.stage_name') }} as kpi_name
    from deduplicated_deal_changes ddc
    left join {{ ref('stg_pipedrive_stages') }} s
         on ddc.new_stage_id = s.stage_id
)

/* *************************************** final select *******************************************************/

select *
from deal_changes_enriched