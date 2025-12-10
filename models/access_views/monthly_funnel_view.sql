{{
config(
    materialized="view",
    grant_access_to=[
        {
            "project": ref("fact_rep_sales_funnel_monthly").database,
            "dataset": "dev_mart" if target.name != "prod" else "none",
        }
    ],
    tags=["access_view", "monthly", "funnel"]
)
}}

select *
from {{ ref("fact_rep_sales_funnel_monthly") }}
