# Exploratory Analysis: Pipedrive CRM Data

This document outlines the exploration and reasoning behind building the staging (`stg_`) and intermediate (`int_`) layers for the Pipedrive CRM dataset. It captures the relationships between tables, the handling of PII, and the transformations applied to prepare the data for analytics.

---

## 1. Overview of Staging Layer

In the staging layer, the goal was to **ingest raw data from the Pipedrive CRM table**, clean the data, standardize types, and prepare audit columns. No heavy logic or joins were applied here
The tables were kept close to source while making them analytically friendly.

The following tables were staged:

1. **`stg_pipedrive_activity`**
   - Columns: `activity_id`, `type`, `deal_id`, `assigned_to_user`, `done`, `due_to`
   - Notes:
     - `stg_pipedrive_activity.deal_id` links to `stg_pipedrive_deal_changes.deal_id`
     - `assigned_to_user` links to `stg_piperive_users.id` -> help to know who performed each activity
     - `activity_type` links to stg.pipedrive_activity_types.activity_catgeory 
     - `done` originally stored as `[v]` / `[]`; converted to boolean (`done_flag`) and human-readable text (`done_text`)
     - `due_to` cast to date
     - Audit columns: `_ingested_at`, `_updated_at`

2. **`stg_pipedrive_activity_types`**
   - Columns: `activity_type_id`, `activity_type_name`, `is_active`, `activity_category`
   - Notes:
     - Maps activity_type_name to sub-steps `Sales Call 1` of funnel step 2 Qualified Lead in stages and  `Sales Call 2` to funnel step 3 Needs Assessment
     - It means certain funnel steps have sub-steps that are tracked as activities
     - Minimal transformation; just column renames and audit timestamps

3. **`stg_pipedrive_deal_changes`**
   - Columns: `deal_id`, `change_timestamp`, `changed_field_key`, `new_value`
   - Notes:
     - link to `stg_pipedrive_activity.deal_id`. 
     - links each deal’s activities to its changes over time, helping us track progress through the funnel
     - Captures historical changes for deals
     - Useful for tracking stage changes and deal lifecycle

4. **`stg_pipedrive_fields`**
   - Columns: `field_id`, `field_key`, `name`, `field_value`
   - Notes:
     - Contains custom fields for deals
     - Preserved raw, only cleaned column names and timestamps

5. **`stg_pipedrive_stages`**
   - Columns: `stage_id`, `stage_name`
   - Notes:
     - Maps funnel stages for deals
     - Links to `stg_users.id` if responsible user is recorded

6. **`stg_pipedrive_users`**
   - Columns: `id`, `name_hash`, `email_hash`, `modified`
   - Notes:
     - Original `name` and `email` are PII
     - Masked using `md5()` hashing for analytics
     - Audit columns added

---

## 2. Observations from Staging Layer

- **Key relationships identified:**
  - `stg_pipedrive_activity.deal_id` → `stg_deal_changes.deal_id`
    - Links each activity to the deal’s history of changes, helping track deal progress through the funnel.
  - `stg_pipedrive_activity.user_id` → `stg_pipedrive_users.id`
    - Identifies the user responsible for each activity for reporting and KPI aggregation.
  - `stg_pipedrive_activity.activitty_type → stg_pipedrive_activity_types.acitivity_category
    - Maps activity types to sub-step(e.g., Sales Call 1, Sales Call 2) to names of stages

- **PII handling:** 
  - Names and emails are hashed in `stg_pipedrive_users`, making downstream analytics safe(used md5)

- **Data quirks:**
  - `done` in `activity` stored as `[v]`/`[]` — needed to be standardized
  - Sub-steps for funnel (2.1, 3.1) exist in `stg_pipedrive_activity_type_name`

---
## 3. Deliverables
month → derived from activity due_date or deal change timestamp

kpi_name → parent funnel step from stages.stage_name

funnel_sub_step →  sub-step name from activity_type.activity_type_name

deals_count → number of deals per month per stage/sub-step

----
## 4. Transition to Intermediate Layer

The intermediate layer (`int_`) combines staging tables to create **meaningful business entities** for reporting and analysis.

1. **activity level aggregation**
   - Join `stg_pipdrive_activity` with `stg_pipedrive_activity_types` to map sub-steps (Sales Call 1, Sales Call 2)
   - Join with `stg_users` for assigned user information (not required for this use case but good to keep user level info at
      intremediate level so that in future can be incorporated at reporting layer)

2. **Stage mapping**
   - Use `stg_pipedrive_stages` to map funnel main steps (Lead Generation → Renewal/Expansion)
   - Merge activity sub-steps into the correct funnel stage
     Example: Stage 2.1 → Sales Call 1

3. **Funnel step creation**
   - Each activity and deal is assigned a funnel step (e.g., Lead In, Qualified, Proposal Sent, Sales Call 1)
   - This supports aggregation for reporting KPIs

4. **Intermediate table design**
   - Columns include: `deal_id`, `user_id`, `funnel_step`, `activity_count`, `stage_changed_at`, `_ingested_at`, `_updated_at`
   - Designed to **support reporting** without heavy computation in final layer

---

## 5. Mart Layer -> build fact tables for reporting funnel

- Build **reporting layer**:
  - Aggregates intermediate activity and deal tables by:
    - month (date_month)
    - funnel_step
    - kpi_name
    - deals_count
    
### Summary

- Staging layer: minimal transformations, clean and auditable
- PII: hashed at staging
- Intermediate layer: joins staging tables to create business entities
- Provides activity- and deal-level enriched entities
- add unique surrogate keys ensures correct merge in int tables if doesnt have a PK
- Ready for reporting layer: monthly sales funnel KPIs

