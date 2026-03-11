with loans as (
    select * from {{ ref('fct_loan_portfolio') }}
),

by_segment as (
    select
        segment,
        count(loan_id)                                      as total_loans,
        sum(case when is_npl then 1 else 0 end)             as npl_loans,
        round(sum(principal), 2)                            as total_exposure,
        round(sum(case when is_npl then principal else 0 end), 2) as npl_exposure,
        case
            when sum(principal) = 0 then null
            else round(sum(case when is_npl then principal else 0 end) / sum(principal) * 100, 2)
        end                                                 as npl_ratio_pct
    from loans
    group by segment
),

total_row as (
    select
        'TOTAL'                                             as segment,
        count(loan_id)                                      as total_loans,
        sum(case when is_npl then 1 else 0 end)             as npl_loans,
        round(sum(principal), 2)                            as total_exposure,
        round(sum(case when is_npl then principal else 0 end), 2) as npl_exposure,
        case
            when sum(principal) = 0 then null
            else round(sum(case when is_npl then principal else 0 end) / sum(principal) * 100, 2)
        end                                                 as npl_ratio_pct
    from loans
),

final as (
    select * from by_segment
    union all
    select * from total_row
)

select * from final
order by case when segment = 'TOTAL' then 1 else 0 end, segment
