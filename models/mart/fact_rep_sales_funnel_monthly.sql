/*------------------------------------------------------------------------------------------------------
  -- Description: Monthly aggregated sales funnel report.
  -- Combines activities (with sub-steps) and deal stage changes (main stages) using dim_sales_funnel.
------------------------------------------------------------------------------------------------------*/

{{
    config(
        materialized='table',
        tags=['rep','funnel','monthly']
    )
}}

-- cte1: monthly activity with funnel step (from int activity table)
with monthly_activity_funnel as (
    select
        date_trunc('month', event_date) as month_start,
        kpi_name,
        funnel_step,       -- matching to dim funnel
        deal_id
    from {{ ref('int_activity_enriched_users') }}
),

-- cte2: monthly deal stage changes (main KPI only, no sub-steps)
monthly_deal_facts as (
    select
        date_trunc('month', change_timestamp) as month_start,
        kpi_name,         -- main stage KPI
        {{ map_activity_name_to_funnel_step('kpi_name') }} as funnel_step,
        deal_id
    from {{ ref('int_deal_changes_enriched') }}
),

-- combined cte: activities + deal_changes
monthly_report_funnel as (
    select * from monthly_activity_funnel
    union all
    select * from monthly_deal_facts
),

-- final aggregation: aggregate counts per month + funnel_step
monthly_aggregated as (
    select
        month_start,
        kpi_name,
        funnel_step,
        count(distinct deal_id) as deals_count
    from monthly_report_funnel
    group by 1,2,3
)

-- Join with dimension table for consistent ordering and labels
select
    coalesce(mg.month_start, current_date) as month_start,
    dsf.kpi_name,
    dsf.funnel_step,
    coalesce(mg.deals_count, 0) as deals_count
from {{ ref('dim_sales_funnel') }} dsf
left join monthly_aggregated mg
    on trim(lower(dsf.funnel_step)) = trim(lower(mg.funnel_step))
    --on dsf.funnel_step = mg.funnel_step
order by dsf.step_order, month_start
