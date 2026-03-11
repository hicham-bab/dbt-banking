with customers as (
    select * from {{ ref('dim_customers') }}
)

select
    segment,
    risk_tier,
    count(customer_id)              as customer_count,
    sum(total_deposits)             as total_deposits,
    sum(total_loan_exposure)        as total_loan_exposure,
    sum(npl_exposure)               as total_npl_exposure,
    case
        when sum(total_loan_exposure) = 0 then null
        else round(sum(npl_exposure) / sum(total_loan_exposure) * 100, 2)
    end                             as npl_ratio_pct,
    round(avg(annual_interest_income), 2) as avg_annual_interest_income
from customers
group by segment, risk_tier
order by segment, risk_tier
