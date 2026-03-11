{{ config(
    materialized='table',
    contract={'enforced': true}
) }}

select
    customer_id,
    customer_name,
    segment,
    risk_rating,
    risk_tier,
    kyc_date,
    kyc_age_days,
    country_code,
    total_accounts,
    total_deposits,
    total_credit_utilisation,
    customer_since,
    current_account_count,
    savings_account_count,
    total_loans,
    total_loan_exposure,
    npl_exposure,
    annual_interest_income
from {{ ref('int_customer_financial_summary') }}
