-- ================================================================
-- SCRIPT 01: Client Receivables & Cash Settlement Summary
-- Business Request: Finance team needs a client-by-client report
-- showing total billed, settled cash, and overdue balances to
-- track collection rates and highlight outstanding payment risk.
-- ================================================================
select e.client_id,e.company_name,e.account_tier, count( u.invoice_id) as
count_of_invoices,
sum(case when u.invoice_status='Paid' then u.gross_amount else 0 end )as settled_cash,
sum(case when u.invoice_status='Overdue' then u.gross_amount else 0 end )as overdue_exposure,
sum(case when u.invoice_status='Pending' then u.gross_amount else 0 end )as pending_exposure,
coalesce(sum(u.gross_amount),0) as total_billed_amount,
round((sum(case when u.invoice_status='Paid' then u.gross_amount else 0 end )*100.0)/
nullif(sum(u.gross_amount),0),2) as collection_efficiency_pct,
case when sum(u.gross_amount)=0 then 'INACTIVE'
when(sum(case when u.invoice_status='Overdue' then u.gross_amount else 0 end )*100.0)/
nullif(sum(u.gross_amount),0)>=40.0 then 'CRITICAL OVERDUE'
when(sum(case when u.invoice_status='Paid' then u.gross_amount else 0 end )*100.0)/
nullif(sum(u.gross_amount),0) >=75.0 then 'HEALTHY'
else 'MODERATE EXPOSURE'
end as risk_category
from enterprise_clients e
left join usage_and_billing u on e.client_id=u.client_id
group by e.client_id,e.company_name,e.account_tier;

-- ============================================================================
-- SCRIPT 02: Revenue Contribution & Performance by Account Tier
-- Business Request: Executive leadership requires a breakdown of gross
--   revenue across client tiers (Enterprise, Mid-Market, Startup) to evaluate
--   portfolio concentration, average deal sizes, and relative revenue share.
-- ============================================================================
select e.account_tier,count(u.invoice_id) as total_invoices,
sum(u.gross_amount) as tier_gross_revenue,
round(avg(u.gross_amount),2) as avg_invoice_amt,
round(
 (sum(u.gross_amount)*100.0)/sum(sum(u.gross_amount)) over(), 2
) as revenue_share_pct
from enterprise_clients e
join  usage_and_billing u on e.client_id=u.client_id
group by e.account_tier
order by tier_gross_revenue desc;

-- ======================================================================
-- SCRIPT 03: Top Account Ranking & Risk Exposure (CTE Architecture)
-- Business Request: Executive leadership requires a ranked evaluation of 
--   top-tier revenue contributors along with their outstanding overdue 
--   exposure to pinpoint concentration risk and credit exposure.
-- ======================================================================
with ranked_accounts as(select e.client_id,e.company_name,e.account_tier,
sum(u.gross_amount) as total_billed,
sum(case when u.invoice_status in ('Pending','Overdue') then u.gross_amount else 0 end) 
as total_outstanding,
dense_rank() over (order by sum(u.gross_amount)desc) as revenue_rank
from enterprise_clients e
join  usage_and_billing u on e.client_id=u.client_id
group by e.client_id,e.company_name,e.account_tier)
select 
revenue_rank,client_id,company_name,account_tier,total_billed,total_outstanding,
round((total_outstanding*100.0)/nullif(total_billed,0),2) as outstanding_share_pct
from ranked_accounts
where revenue_rank <=10
order by revenue_rank asc;

select * from enterprise_clients;
select * from cloud_services;
select * from usage_and_billing;  
