with source as (
    select * from {{ source('raw', 'raw_transactions') }}
),

parsed as (
    select
        txn_id,
        account_id,
        cast(amount as numeric)         as amount,
        lower(txn_type)                 as txn_type,
        cast(txn_date as date)          as txn_date,
        lower(category)                 as category,
        case lower(txn_type)
            when 'credit' then  abs(cast(amount as numeric))
            when 'debit'  then -abs(cast(amount as numeric))
        end                             as signed_amount,
        date_trunc('month', cast(txn_date as date)) as activity_period
    from source
)

select * from parsed
