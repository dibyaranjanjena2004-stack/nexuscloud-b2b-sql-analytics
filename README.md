# NexusCloud B2B Revenue & Credit Risk Analytics (PostgreSQL)

## Executive Summary
This project analyzes transactional billing data and credit exposure for a B2B cloud infrastructure provider (NexusCloud). Using PostgreSQL, raw operational billing logs are structured into an executive reporting framework to evaluate cash settlement velocity, tier concentration risk, and payment exposure across top accounts.

---

## Technical Stack & Competencies
- **Database Engine:** PostgreSQL 16 / pgAdmin 4
- **Relational Joins:** Key-based table joins (`enterprise_clients` + `usage_and_billing`)
- **Conditional Logic:** Multi-case risk classification (`CASE WHEN`), zero-division handling (`NULLIF`)
- **Advanced SQL:** Window aggregation (`SUM() OVER ()`), ranking analytics (`DENSE_RANK()`), Common Table Expressions (CTEs)

---

## Project Structure & Architecture

### Script 01: Client Receivables & Cash Settlement Summary
- **Business Goal:** Classify client payment status, calculate collection efficiency, and assign risk tiers.
- **Methodology:** Relational joins with conditional aggregation logic (`CASE WHEN`) to split cash into settled, overdue, and pending buckets.
- **Risk Tiers:**
  - `HEALTHY`: Collection efficiency >= 75%
  - `MODERATE EXPOSURE`: Balanced accounts with pending settlements
  - `CRITICAL OVERDUE`: Overdue balance >= 40% of total billing

### Script 02: Revenue Contribution & Portfolio Concentration
- **Business Goal:** Assess revenue reliance across business segments (`Enterprise`, `Mid-Market`, `Startup`).
- **Methodology:** Implemented Window Functions (`SUM(SUM(...)) OVER ()`) to compute relative portfolio share without collapsing group rows.
- **Finding:** Enterprise accounts drive 67.20% of total revenue across 28 billing cycles, representing the dominant driver of top-line cash flow.

### Script 03: High-Value Client Ranking & Exposure Pipeline
- **Business Goal:** Identify top 10 revenue-generating accounts and measure individual default exposure.
- **Methodology:** Modular Common Table Expression (CTE) combined with analytical window ranking (`DENSE_RANK() OVER (ORDER BY ...)`), filtered at `revenue_rank <= 10`.
- **Finding:** Highlighted that while Rank 1 and 2 accounts have settled 100% of their invoices, accounts at Rank 3 and Rank 5 hold a 100% outstanding balance ratio, representing immediate working-capital exposure.

---

## Repository Files
- `nexuscloud_analytics.sql`: Complete production script containing all 3 analytical pipelines with executive headers.
- Visual verification screenshots detailing query execution and output tables for Scripts 01, 02, and 03.
