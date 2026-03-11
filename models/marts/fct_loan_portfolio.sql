with risk_metrics as (
    select * from {{ ref('int_loan_risk_metrics') }}
)

select
    loan_id,
    customer_id,
    customer_name,
    segment,
    risk_rating,
    risk_tier,
    country_code,
    loan_type,
    loan_status,
    is_npl,
    principal,
    interest_rate,
    origination_date,
    annual_interest_income,
    pd,
    lgd,
    ead,
    expected_loss,
    risk_weight,
    rwa
from risk_metrics
