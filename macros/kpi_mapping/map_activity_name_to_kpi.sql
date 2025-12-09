{#
    This macro maps the activity name to the funnel kpi
#}

{% macro map_activity_name_to_kpi(field) %}
    case
        when {{ field }} = 'Sales Call 1' then 'Qualified Lead'
        when {{ field }} = 'Sales Call 2' then 'Needs Assessment'
        when {{ field }} = 'Follow Up Call' then 'Follow-up/Customer Success'
        when {{ field }} = 'After Close Call' then 'Closing'
        else null
    end
{% endmacro %}
