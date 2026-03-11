with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),

classified as (
    select
        account_id,
        customer_id,
        lower(account_type)             as account_type,
        cast(open_date as date)         as open_date,
        lower(status)                   as status,
        cast(balance as numeric)        as balance,
        case lower(account_type)
            when 'current'       then true
            when 'savings'       then true
            when 'fixed_deposit' then true
            else false
        end                             as is_deposit_account,
        case lower(account_type)
            when 'credit_line' then true
            else false
        end                             as is_credit_account
    from source
)

select * from classified
