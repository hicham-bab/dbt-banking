with source as (
    select * from {{ source('raw', 'raw_customers') }}
),

standardised as (
    select
        customer_id,
        trim(name)              as customer_name,
        lower(segment)          as segment,
        upper(risk_rating)      as risk_rating,
        case upper(risk_rating)
            when 'A' then 'low_risk'
            when 'B' then 'medium_risk'
            when 'C' then 'high_risk'
        end                     as risk_tier,
        cast(kyc_date as date)  as kyc_date,
        upper(country)          as country_code,
        datediff('day', cast(kyc_date as date), current_date()) as kyc_age_days
    from source
)

select * from standardised
