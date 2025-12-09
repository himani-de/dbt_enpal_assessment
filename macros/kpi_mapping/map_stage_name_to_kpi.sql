{#
    This macro maps the stage name to the funnel kpi
#}

{% macro map_stage_name_to_kpi(field) %}
    case
        when {{ field }} = 'Lead In' then 'Lead Generation'
        when {{ field }} = 'Qualified' then 'Qualified Lead'
        when {{ field }} = 'Needs Assessment' then 'Needs Assessment'
        when {{ field }} = 'Proposal' then 'Proposal/Quote Preparation'
        when {{ field }} = 'Negotiation' then 'Negotiation'
        when {{ field }} = 'Won' then 'Closing'
        when {{ field }} = 'Implementation' then 'Implementation/Onboarding'
        when {{ field }} = 'Follow-up' then 'Follow-up/Customer Success'
        when {{ field }} = 'Renewal' then 'Renewal/Expansion'
        else null
    end
{% endmacro %}