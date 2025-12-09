/*------------------------------------------------------------------------------------------------------
  -- Description: Enriched activity table  with type and user for funnel analysis
  -- Last updated: 2025-12-07
-----------------------------------------------------------------------------------------------------------*/

{{
    config(
        materialized='incremental',
        unique_key='activity_id',
        incremental_strategy='merge',
        tags=['int','activity']
    )
}}

/* *************************************** query *******************************************************/

-- CTE1: Filter base activities for incremental window
with activity_base as (
    select *
    from {{ ref('stg_pipedrive_activity') }}
    {% if is_incremental() %}
        -- only pick new activities not yet in this table
        where activity_id NOT IN (select activity_id from {{ this }})
    {% endif %}
),

-- CTE2: Join activity types to get funnel sub-step and done_text
activity_with_type as (
    select
        ab.activity_id,
        ab.deal_id,
        ab.user_id,
        at.activity_type_name as funnel_sub_step,
        ab.done_text,           -- human-readable done
        ab.done_flag,           -- boolean
        ab.due_date
    from activity_base ab
    left join {{ ref('stg_pipedrive_activity_types') }} at
        on ab.activity_type = at.activity_category
),

-- CTE3: Join users and map parent funnel step
activity_with_user as (
    select
        awt.activity_id,
        awt.deal_id,
        awt.user_id as activity_user_id,
        awt.funnel_sub_step,
        awt.done_flag,
        awt.done_text,
        {{ map_activity_name_to_funnel_step('funnel_sub_step') }} as funnel_step,
        {{ map_stage_name_to_kpi('awt.funnel_sub_step') }} as kpi_name, -- parent KPI
        awt.due_date::timestamp as event_date,
        u.user_id,
        u.name_hash as user_name_hashed,
        u.email_hash as user_email_hashed,
        current_timestamp as _ingested_at,
        current_timestamp as _updated_at
    from activity_with_type awt
    left join {{ ref('stg_pipedrive_users') }} u
        on awt.user_id = u.user_id
)

select *
from activity_with_user
