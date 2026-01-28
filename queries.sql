-- dataset
select *
from customer;

-- Query 1
/*Quel est le chiffre d'affaires total généré par les clients masculins par rapport aux clientes féminines? */
select 
  sum(purchase_amount) filter(where gender = 'Male') as male_purchase_amount,
  sum(purchase_amount) filter(where gender = 'Female') as male_purchase_amount
from customer;

-- Query 2
/* Quels clients ont utilisé une réduction mais ont tout de même dépensé plus que le montant moyen des achats? */
select 
  customer_id as clients
from customer 
where 
  discount_applied = 'Yes' and purchase_amount > (select avg(purchase_amount) from customer);

-- Query 3
/*Quels sont les 5 produits ayant obtenu la meilleure note moyenne dans les avis clients ? */
select 
  item_purchased as best_product, 
  round(avg(review_rating::numeric),2) as "average_rating"
from customer
group by item_purchased
order by avg(review_rating) desc
limit 5;

-- Query 4
/* Comparez les montants moyens des achats entre la livraison standard et la livraison express.*/
select 
  round(avg(purchase_amount) filter(where shipping_type = 'Standard')::numeric,2) as amount_with_standard_shipping,
  round(avg(purchase_amount) filter(where shipping_type = 'Express') ::numeric,2) as amount_with_standard_shipping
from customer;

-- Query 5 
/* Les clients abonnés dépensent-ils plus ? Comparez le montant moyen des achats et le chiffre d'affaires total entre les clients abonnés et les clients non abonnés.*/
select 
  case 
      when subscription_status = 'Yes' then 'subscriber'
      else 'non-subscriber'
  end as subscription_status,
  count(customer_id) as total_customers,
  round(avg(purchase_amount)::numeric,2) as avg_amount,
  sum(purchase_amount) as revenue
from customer
group by subscription_status;

-- Query 6
/* Quels sont les 5 produits qui ont le pourcentage le plus élevé d'achats avec des réductions appliquées? */
select 
  item_purchased,
  round(100.0 * count(*)filter(where discount_applied = 'Yes')/count(*)::numeric,2) as high_revenue_percent
from customer
group by item_purchased
order by high_revenue_percent desc 
limit 5;

-- Query 7
/*Segmentez les clients en nouveaux, fidèles et réguliers en fonction du nombre total de leurs achats précédents, et affichez le nombre de clients dans chaque segment.*/
with 
  cte as (
    select 
      *,
      case 
        when previous_purchases = 0 then 'new_customer'
        when previous_purchases between 1 and 10 then 'frequent_customer'
        else 'loyal_customer'
      end as segment
    from customer
  )
select
  cte.segment as segment,
  count(*) as total_customers
from cte 
group by cte.segment;

-- Query 8
/*Top three most purchased product by category*/
with 
  cte as(
    select 
      row_number()over(partition by category order by count(item_purchased) desc) as rank,
      category,
      item_purchased,
      count(item_purchased) as total_products
    from customer
    group by category,item_purchased
    order by category asc, total_products desc 
  )
select 
  *
from cte 
where cte.rank in (1,2,3)


