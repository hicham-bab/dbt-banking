with source as (
    select * from {{ source('raw', 'raw_loans') }}
),

enriched as (
    select
        loan_id,
        customer_id,
        cast(principal as numeric)      as principal,
        cast(interest_rate as numeric)  as interest_rate,
        lower(loan_status)              as loan_status,
        lower(loan_type)                as loan_type,
        cast(origination_date as date)  as origination_date,
        case lower(loan_status)
            when 'non-performing' then true
            else false
        end                             as is_npl,
        cast(principal as numeric) * (cast(interest_rate as numeric) / 100.0) as annual_interest_income
    from source
)

select * from enriched
