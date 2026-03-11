with transactions as (
    select * from {{ ref('stg_transactions') }}
),

accounts as (
    select
        account_id,
        customer_id,
        account_type
    from {{ ref('stg_accounts') }}
),

joined as (
    select
        t.txn_id,
        t.account_id,
        a.customer_id,
        a.account_type,
        t.amount,
        t.signed_amount,
        t.txn_type,
        t.txn_date,
        t.activity_period,
        t.category
    from transactions t
    inner join accounts a on t.account_id = a.account_id
),

with_running_balance as (
    select
        txn_id,
        account_id,
        customer_id,
        account_type,
        amount,
        signed_amount,
        txn_type,
        txn_date,
        activity_period,
        category,
        sum(signed_amount) over (
            partition by account_id
            order by txn_date, txn_id
            rows between unbounded preceding and current row
        ) as running_balance
    from joined
)

select * from with_running_balance
