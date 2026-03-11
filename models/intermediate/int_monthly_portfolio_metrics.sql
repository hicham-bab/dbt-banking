with loan_interest as (
    select
        date_trunc('month', origination_date)   as reporting_period,
        sum(annual_interest_income / 12.0)       as monthly_interest_income,
        count(loan_id)                           as active_loans,
        sum(principal)                           as portfolio_balance
    from {{ ref('stg_loans') }}
    where loan_status = 'performing'
    group by 1
),

deposit_costs as (
    select
        date_trunc('month', open_date)          as reporting_period,
        sum(balance * 0.015 / 12.0)             as monthly_interest_expense,
        sum(balance)                            as total_deposits
    from {{ ref('stg_accounts') }}
    where is_deposit_account = true
      and status = 'active'
    group by 1
),

combined as (
    select
        coalesce(li.reporting_period, dc.reporting_period)      as reporting_period,
        coalesce(li.monthly_interest_income, 0)                  as interest_income,
        coalesce(dc.monthly_interest_expense, 0)                 as interest_expense,
        coalesce(li.monthly_interest_income, 0)
            - coalesce(dc.monthly_interest_expense, 0)           as net_interest_income,
        coalesce(li.active_loans, 0)                             as active_loans,
        coalesce(li.portfolio_balance, 0)                        as portfolio_balance,
        coalesce(dc.total_deposits, 0)                           as total_deposits
    from loan_interest li
    full outer join deposit_costs dc on li.reporting_period = dc.reporting_period
)

select
    row_number() over (order by reporting_period) as period_id,
    reporting_period,
    round(interest_income, 2)     as interest_income,
    round(interest_expense, 2)    as interest_expense,
    round(net_interest_income, 2) as net_interest_income,
    active_loans,
    round(portfolio_balance, 2)   as portfolio_balance,
    round(total_deposits, 2)      as total_deposits
from combined
order by reporting_period
