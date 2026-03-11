with loans as (
    select * from {{ ref('stg_loans') }}
),

customers as (
    select * from {{ ref('stg_customers') }}
),

risk_metrics as (
    select
        l.loan_id,
        l.customer_id,
        c.customer_name,
        c.segment,
        c.risk_tier,
        c.risk_rating,
        c.country_code,
        l.loan_type,
        l.loan_status,
        l.is_npl,
        l.principal,
        l.interest_rate,
        l.origination_date,
        l.annual_interest_income,

        -- Probability of Default
        case
            when l.is_npl                      then 1.0
            when upper(c.risk_rating) = 'C'    then 0.05
            when upper(c.risk_rating) = 'B'    then 0.02
            when upper(c.risk_rating) = 'A'    then 0.005
            else 0.05
        end                                                 as pd,

        -- Loss Given Default (Basel II foundation IRB unsecured standard)
        0.45                                                as lgd,

        -- Exposure at Default
        l.principal                                         as ead,

        -- Expected Loss = PD × LGD × EAD
        case
            when l.is_npl                      then 1.0
            when upper(c.risk_rating) = 'C'    then 0.05
            when upper(c.risk_rating) = 'B'    then 0.02
            when upper(c.risk_rating) = 'A'    then 0.005
            else 0.05
        end * 0.45 * l.principal                            as expected_loss,

        -- Risk Weight
        case
            when l.is_npl                      then 1.50
            when upper(c.risk_rating) = 'C'    then 1.00
            when upper(c.risk_rating) = 'B'    then 0.75
            when upper(c.risk_rating) = 'A'    then 0.50
            else 1.00
        end                                                 as risk_weight,

        -- Risk-Weighted Asset
        l.principal * case
            when l.is_npl                      then 1.50
            when upper(c.risk_rating) = 'C'    then 1.00
            when upper(c.risk_rating) = 'B'    then 0.75
            when upper(c.risk_rating) = 'A'    then 0.50
            else 1.00
        end                                                 as rwa

    from loans l
    inner join customers c on l.customer_id = c.customer_id
)

select * from risk_metrics
