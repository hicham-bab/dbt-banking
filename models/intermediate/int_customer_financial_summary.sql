with customers as (
    select * from {{ ref('stg_customers') }}
),

account_summary as (
    select
        customer_id,
        count(account_id)                                           as total_accounts,
        sum(case when is_deposit_account then balance else 0 end)   as total_deposits,
        sum(case when is_credit_account  then balance else 0 end)   as total_credit_utilisation,
        min(open_date)                                              as first_account_date,
        count(case when account_type = 'current' then 1 end)        as current_account_count,
        count(case when account_type = 'savings' then 1 end)        as savings_account_count
    from {{ ref('stg_accounts') }}
    group by customer_id
),

loan_summary as (
    select
        customer_id,
        count(loan_id)                                              as total_loans,
        sum(principal)                                              as total_loan_exposure,
        sum(case when is_npl then principal else 0 end)             as npl_exposure,
        sum(annual_interest_income)                                 as annual_interest_income
    from {{ ref('stg_loans') }}
    group by customer_id
),

final as (
    select
        c.customer_id,
        c.customer_name,
        c.segment,
        c.risk_rating,
        c.risk_tier,
        c.kyc_date,
        c.kyc_age_days,
        c.country_code,
        coalesce(a.total_accounts, 0)           as total_accounts,
        coalesce(a.total_deposits, 0)           as total_deposits,
        coalesce(a.total_credit_utilisation, 0) as total_credit_utilisation,
        coalesce(a.first_account_date, null)    as customer_since,
        coalesce(a.current_account_count, 0)    as current_account_count,
        coalesce(a.savings_account_count, 0)    as savings_account_count,
        coalesce(l.total_loans, 0)              as total_loans,
        coalesce(l.total_loan_exposure, 0)      as total_loan_exposure,
        coalesce(l.npl_exposure, 0)             as npl_exposure,
        coalesce(l.annual_interest_income, 0)   as annual_interest_income
    from customers c
    left join account_summary a on c.customer_id = a.customer_id
    left join loan_summary    l on c.customer_id = l.customer_id
)

select * from final
