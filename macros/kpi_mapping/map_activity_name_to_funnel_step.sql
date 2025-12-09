{#
    This macro maps the activity name to the funnel kpi
    funnel_step: optional sub-step mapping (like 2.1, 3.1)
#}

{% macro map_activity_name_to_funnel_step(field) %}
    case
        -- Sub-step activities
        when {{ field }} = 'Sales Call 1' then '2.1'
        when {{ field }} = 'Sales Call 2' then '3.1'
        when {{ field }} = 'Follow Up Call' then '8'   -- Follow-up/Customer Success
        when {{ field }} = 'After Close Call' then '6' -- Closing

        -- Main stages (if used in activity)
        when {{ field }} = 'Lead Generation' then '1'
        when {{ field }} = 'Qualified Lead' then '2'
        when {{ field }} = 'Needs Assessment' then '3'
        when {{ field }} = 'Proposal/Quote Preparation' then '4'
        when {{ field }} = 'Negotiation' then '5'
        when {{ field }} = 'Closing' then '6'
        when {{ field }} = 'Implementation/Onboarding' then '7'
        when {{ field }} = 'Follow-up/Customer Success' then '8'
        when {{ field }} = 'Renewal/Expansion' then '9'
    end
{% endmacro %}