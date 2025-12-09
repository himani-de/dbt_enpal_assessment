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
        date_trunc('month', event_date) as month,
        -- kpi_name from macro
        {{ map_activity_name_to_kpi('funnel_sub_step') }} as kpi_name,
        -- map sub-steps to dim funnel_step values
        case funnel_sub_step
            when 'Sales Call 1' then '2.1'
            when 'Sales Call 2' then '3.1'
            else funnel_sub_step
        end as funnel_step,
        deal_id
    from {{ ref('int_activity_enriched_users') }}
),

-- cte2: monthly deal stage changes (main KPI only, no sub-steps)
monthly_deal_facts as (
    select
        date_trunc('month', change_timestamp) as month,
        kpi_name,         -- main stage KPI
        kpi_name as funnel_step,
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
        month,
        kpi_name,
        funnel_step,
        count(distinct deal_id) as deals_count
    from monthly_report_funnel
    group by 1,2,3
)

-- Join with dimension table for consistent ordering and labels
select
    coalesce(mg.month, current_date) as month,
    dsf.kpi_name,
    dsf.funnel_step,
    coalesce(mg.deals_count, 0) as deals_count
from {{ ref('dim_sales_funnel') }} dsf
left join monthly_aggregated mg
    on trim(lower(dsf.funnel_step)) = trim(lower(mg.funnel_step))
    --on dsf.funnel_step = mg.funnel_step
order by dsf.step_order, month
