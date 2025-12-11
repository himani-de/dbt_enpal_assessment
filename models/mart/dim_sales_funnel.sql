/*------------------------------------------------------------------------------------------------------
  -- Description: Dimension table for sales funnel steps.
  -- Provides funnel step labels and ordering for reporting and dashboards.
------------------------------------------------------------------------------------------------------*/

{{
    config(
        materialized='table',
        tags=['dim','funnel']
    )
}}

select * from (
    values
        ('1',  'Lead Generation',              1),
        ('2',  'Qualified Lead',               2),
        ('2.1','Sales Call 1',                  3),
        ('3',  'Needs Assessment',              4),
        ('3.1','Sales Call 2',                  5),
        ('4',  'Proposal/Quote Preparation',    6),
        ('5',  'Negotiation',                   7),
        ('6',  'Closing',                       8),
        ('7',  'Implementation/Onboarding',     9),
        ('8',  'Follow-up/Customer Success',   10),
        ('9',  'Renewal/Expansion',            11)
) as dim_funnel_steps(funnel_step, kpi_name, step_order)
