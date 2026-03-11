# Banking Demo — Flow Guide
## dbt + dbt MCP Server: AI-Ready Data Infrastructure

**Setup:** Claude Desktop open, `dbt-banking` local MCP active, split screen (Claude left, VS Code right)
**Total time:** 12 min | **MCP server:** `dbt-banking` (local) throughout, switch to `dbt` (cloud) for Act 3

---

## Before You Go On Stage

```bash
cd /Users/hichambabahmed/dbt-banking
~/.local/bin/dbt build --profiles-dir .
# Expected: 43 tests | 41 pass | 2 warn (intentional — negative transaction T_BAD)
```

Verify Claude Desktop sees the MCP: open a new chat → type *"What dbt tools do you have access to?"*

---

## The Setup (30 sec, no slides needed)

> *"Banking runs on data. Risk models, fraud detection, regulatory reporting — all built
> on pipelines. When you add AI on top, the AI inherits every quality problem, every
> missing label, every undocumented join. AI-ready analytics requires AI-ready
> infrastructure. Three things: quality, context, and auditability. Let me show you
> what that looks like."*

---

## Act 1 — Context (2 min)
### *"Your AI knows your data"*

**Type live:**
> "I'm preparing a quarterly credit risk report. What data models are available,
> what do they contain, and how are they structured?"

**What Claude returns:**
- 3-layer architecture: staging → intermediate → marts
- 6 mart models: `dim_customers`, `fct_transactions`, `fct_loan_portfolio`,
  `monthly_nii`, `customer_risk_exposure`, `portfolio_npl_ratio`
- Column descriptions from `_marts.yml`

**Narrate:** *"It's reading your team's documentation in real time — not hallucinating,
not guessing. Every description you see came from a YAML file a data engineer wrote."*

---

**Type live:**
> "Show me the full lineage for the loan portfolio model — trace it all the way
> back to the raw source data."

**What Claude returns:**
```
raw_loans (seed)
  └── stg_loans (staging: casts, is_npl flag, annual_interest_income)
        └── int_loan_risk_metrics (intermediate: Basel II PD/LGD/EAD/EL/RWA)
              └── fct_loan_portfolio (mart: reporting layer)
                    ├── customer_risk_exposure
                    └── portfolio_npl_ratio
```

**Narrate:** *"Any regulator who asks 'where did this number come from?' —
that is your answer, in seconds. Full provenance from raw source to final report."*

---

## Act 2 — Quality (3.5 min)
### *"Bad data never reaches your AI"*

**Type live:**
> "Before I use this data for analysis, are there any data quality issues
> or test failures I should know about?"

**What Claude returns:**
- 41/43 tests passing
- 2 warnings on `stg_transactions` and `fct_transactions`:
  `transactions_amount_must_be_non_negative` — 1 row with amount = -200 (T_BAD)

**Narrate:** *"It found a problem before you ran a single query. Transaction T_BAD
has a negative amount — an invalid adjustment that would silently skew any risk
calculation. Caught automatically. Flagged before the AI ever touched it."*

---

**Type live:**
> "What data quality contracts are enforced on the customer dimension?
> What would cause a pipeline failure?"

**What Claude returns:**
- `dim_customers` has `contract: enforced: true`
- Tests: not_null + unique on `customer_id`, accepted_values on `risk_rating` (A/B/C),
  accepted_values on `segment` (retail/institutional/wealth/sme),
  accepted_values on `risk_tier` (low_risk/medium_risk/high_risk)
- Primary key constraint enforced at the schema level

**Narrate:** *"Contract enforcement means any downstream consumer — a dashboard,
an AI tool, a regulatory report — is guaranteed this schema. It's a machine-readable
promise that the data engine enforces on every run."*

---

**Switch to terminal (30 sec):**
```bash
cd /Users/hichambabahmed/dbt-banking
~/.local/bin/dbt test --select stg_loans int_loan_risk_metrics --profiles-dir .
```

→ Show 3 unit tests passing: `npl_flag_correctly_set`, `customer_risk_tier_assigned`,
`expected_loss_calculation`

**Narrate:** *"Unit tests verify business logic — not just 'is the column non-null'
but 'is the Expected Loss formula PD × LGD × EAD actually correct?'
The calculation is tested, not assumed."*

---

## Act 3 — Auditability (2 min)
### *"Traceable by design"*

**Type live (switch to `dbt` cloud MCP):**
> "Show me the last 3 job runs in the production environment — when did they run,
> who triggered them, and did they succeed?"

**What Claude returns:**
- Admin API: job run timestamps, triggered_by user, git SHA, status from sa-standard-shared-demo

**Narrate:** *"Job ID, timestamp, git commit SHA, who clicked run — every production
execution is logged. DORA, Basel III, internal audit — answered in one prompt.
This is the operational audit trail. The calculation audit trail lives in the
lineage we just saw. Together, that's regulatory-grade auditability."*

---

**Type live (back to `dbt-banking` MCP):**
> "If the raw_transactions source schema changes next week, what models
> and metrics would be affected downstream?"

**What Claude returns:**
```
raw_transactions
  └── stg_transactions
        └── fct_transactions
              └── (metrics: transaction-level analysis)
```

**Narrate:** *"Impact analysis before you touch anything. No surprises.
No midnight incidents. You know the blast radius before the first line changes."*

---

## Act 4 — Self-Serve Analytics (3 min)
### *"Business users speak plain English"*

**Type live:**
> "What is our current non-performing loan ratio? Break it down by customer
> segment. Which segment has the highest credit risk concentration?"

**What Claude returns** (from `portfolio_npl_ratio` via `dbt show`):

| Segment | NPL Loans | Total Loans | NPL Ratio |
|---|---|---|---|
| sme | 1 | 2 | **50%** |
| retail | 3 | 7 | **42.9%** |
| institutional | 0 | 4 | 0% |
| wealth | 0 | 2 | 0% |
| **TOTAL** | **4** | **15** | **26.7%** |

**Narrate:** *"SME segment — 50% NPL ratio. Retail — 42.9%. Institutional and wealth:
clean. A risk officer with no SQL just got the answer that would have taken a data
analyst 30 minutes to pull. And every number is tested, documented, and auditable."*

---

**Type live:**
> "Which customers have the highest credit risk exposure? Show me the
> high-risk tier broken down by segment."

**What Claude returns** (from `customer_risk_exposure`):

| Segment | Risk Tier | Customers | Total Exposure | NPL Ratio |
|---|---|---|---|---|
| sme | high_risk | 1 | €120K | **100%** |
| retail | high_risk | 3 | €25K | **52%** |

**Narrate:** *"One SME counterparty with 100% NPL exposure. Three retail C-rated
clients at 52%. This is your watchlist — generated from a single prompt, from
data that was quality-checked before the AI ever touched it."*

---

**Type live:**
> "Using the Basel II risk metrics in the loan portfolio model, what is our
> total expected loss across the portfolio? Break it down by loan type."

**What Claude returns** (from `fct_loan_portfolio`, EL = PD × LGD × EAD):
- Queries the `total_expected_loss` metric or runs `dbt show --select fct_loan_portfolio`
- Shows EL by loan_type: personal_loan highest PD, corporate_loan highest EAD

**Narrate:** *"The intermediate layer computed PD, LGD, and EAD using Basel II
parameters before this data ever reached the mart. The AI didn't calculate this —
it read a tested, documented, version-controlled formula. That's the difference
between an AI answer and an auditable AI answer."*

---

## Closing (30 sec)

> *"This is what AI-ready data infrastructure looks like. Not a chatbot sitting on
> top of a data lake. A tested, documented, contract-enforced, three-layer semantic
> foundation — with an AI that knows how to use it.*
>
> *Quality. Context. Auditability.*
>
> *dbt delivers all three. The MCP Server connects your AI directly to it."*

---

## Prompt Cheat Sheet (print and laminate)

```
1. "What data models are available and how are they structured?"

2. "Show me the full lineage for the loan portfolio model —
   trace it back to the raw source."

3. "Are there any data quality issues I should know about
   before using this data?"

4. "What contracts are enforced on the customer dimension?
   What causes a pipeline failure?"

5. [terminal] dbt test --select stg_loans int_loan_risk_metrics --profiles-dir .

6. [switch to cloud dbt MCP]
   "Show me the last 3 job runs in production."

7. "If raw_transactions schema changes, what is impacted downstream?"

8. "What is our NPL ratio by segment?"

9. "Which customers have the highest credit risk concentration?"

10. "What is our total expected loss broken down by loan type?"
```

---

## Key Numbers to Know

| Metric | Value |
|---|---|
| Total loans | 15 |
| NPL loans | 4 |
| Portfolio NPL ratio | **26.7%** |
| SME NPL ratio | **50%** |
| Retail NPL ratio | **42.9%** |
| Institutional NPL | **0%** |
| Tests passing | **41 / 43** |
| Intentional quality catch | T_BAD: amount = -200 |
| Unit tests | **3 / 3** |
| Metrics defined | **6** |
| Layers | staging → intermediate → marts |

---

## If Something Goes Wrong

| Problem | Recovery |
|---|---|
| MCP not responding | Ask "What dbt tools do you have?" — if blank, restart Claude Desktop |
| Slow response | Pre-run `dbt build` before the demo, results are cached on Snowflake |
| Wrong numbers | Confirm you're on `dbt-banking` MCP not the cloud `dbt` MCP |
| dbt show fails | Run the query manually: `~/.local/bin/dbt show --select portfolio_npl_ratio --profiles-dir .` |
