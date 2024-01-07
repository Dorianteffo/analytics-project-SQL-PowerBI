SET search_path = balanced_tree;

---High Level Sales Analysis

---What was the total quantity sold for all products?
SELECT COUNT(DISTINCT prod_id) AS Total_product, 
SUM(qty) AS total_quantity
FROM sales;


---What is the total generated revenue for all products before discounts?
SELECT SUM(qty*price) AS revenue_before_discount 
FROM sales;

---What was the total discount amount for all products?
SELECT SUM(discount) AS total_discount
FROM sales;


---Transaction Analysis

---How many unique transactions were there?
SELECT COUNT(DISTINCT txn_id) AS total_unique_trans
FROM sales;


---What is the average unique products purchased in each transaction?
SELECT DISTINCT prod_id, ROUND(AVG(qty) OVER(PARTITION BY prod_id),2) AS avg_qty
FROM sales;


---What are the 25th, 50th and 75th percentile values for the revenue per transaction?
SELECT percentile_disc(0.25) WITHIN GROUP (ORDER BY x.revenue_per_transaction) AS Percentile_25,
percentile_disc(0.50) WITHIN GROUP (ORDER BY x.revenue_per_transaction) AS Percentile_50,
percentile_disc(0.75) WITHIN GROUP (ORDER BY x.revenue_per_transaction) AS Percentile_75
FROM (SELECT txn_id, SUM((qty*price)-discount) AS revenue_per_transaction
	  FROM sales
	  GROUP BY txn_id
	 ) x;
	 
	 
---What is the average discount value per transaction?
SELECT SUM(discount)/COUNT(DISTINCT txn_id) AS avg_discount_per_transaction
FROM sales;


---What is the percentage split of all transactions for members vs non-members?
SELECT DISTINCT member, 
ROUND((COUNT(txn_id) OVER(PARTITION BY member)::decimal/COUNT(txn_id) OVER()::decimal)*100,2) AS percentage_split_transaction
FROM sales;


---What is the average revenue for member transactions and non-member transactions?
SELECT DISTINCT member,
ROUND(AVG((qty*price)-discount) OVER(PARTITION BY member),2) AS average_revenue
FROM sales;


---Product Analysis

---What are the top 3 products by total revenue before discount?
SELECT s.prod_id, pd.product_name, 
SUM(s.qty*s.price) AS revenue 
FROM sales s 
JOIN product_details pd ON s.prod_id = pd.product_id
GROUP BY s.prod_id, pd.product_name
ORDER BY revenue DESC
LIMIT 3;


---What is the total quantity, revenue and discount for each segment?
SELECT pd.segment_id,pd.segment_name,SUM(s.qty) AS total_quantity, 
SUM(s.qty*s.price) AS revenue, SUM(s.discount) AS total_discount
FROM product_details pd 
JOIN sales s ON pd.product_id = s.prod_id
GROUP BY pd.segment_id, pd.segment_name
ORDER BY pd.segment_id;


---What is the top selling product for each segment?
SELECT * 
FROM (
		SELECT pd.segment_id, pd.segment_name, 
		pd.product_id,pd.product_name, SUM((s.qty*s.price)-s.discount) AS revenue, 
		RANK() OVER(PARTITION BY pd.segment_id ORDER BY SUM(s.qty * s.price) DESC) AS rnk
		FROM product_details pd 
		JOIN sales s ON pd.product_id = s.prod_id 
		GROUP BY pd.segment_id, pd.segment_name, pd.product_id, pd.product_name
		ORDER BY pd.segment_id
	) x
WHERE x.rnk = 1;


---What is the total quantity, revenue and discount for each category?
SELECT pd.category_id,pd.category_name,SUM(s.qty) AS total_quantity, 
SUM(s.qty*s.price) AS revenue, SUM(s.discount) AS total_discount
FROM product_details pd 
JOIN sales s ON pd.product_id = s.prod_id
GROUP BY pd.category_id, pd.category_name
ORDER BY pd.category_id;


---What is the top selling product for each category?
SELECT * 
FROM (
		SELECT pd.category_id, pd.category_name, 
		pd.product_id,pd.product_name, SUM((s.qty*s.price)-s.discount) AS revenue, 
		RANK() OVER(PARTITION BY pd.category_id ORDER BY SUM(s.qty * s.price) DESC) AS rnk
		FROM product_details pd 
		JOIN sales s ON pd.product_id = s.prod_id 
		GROUP BY pd.category_id, pd.category_name, pd.product_id, pd.product_name
		ORDER BY pd.category_id
	) x
WHERE x.rnk = 1;


---What is the percentage split of revenue by product for each segment?
SELECT DISTINCT pd.segment_id, pd.segment_name, 
pd.product_id, pd.product_name, 
SUM((s.qty*s.price)-discount) OVER(PARTITION BY pd.segment_id) AS total_revenue_seg, 
SUM((s.qty*s.price)-discount) OVER(PARTITION BY pd.segment_id,pd.product_id) AS revenue_product,
ROUND((SUM((s.qty*s.price)-discount) OVER(PARTITION BY pd.segment_id,pd.product_id)::decimal/
 	SUM((s.qty*s.price)-discount) OVER(PARTITION BY pd.segment_id)::decimal)*100,2) AS percentage_product
FROM product_details pd 
JOIN sales s ON pd.product_id = s.prod_id
ORDER BY pd.segment_id;


---What is the percentage split of revenue by segment for each category?
SELECT DISTINCT pd.category_id, pd.category_name, 
pd.segment_id, pd.segment_name, 
SUM((s.qty*s.price)-discount) OVER(PARTITION BY pd.category_id) AS total_revenue_categ, 
SUM((s.qty*s.price)-discount) OVER(PARTITION BY pd.category_id,pd.segment_id) AS revenue_seg,
ROUND((SUM((s.qty*s.price)-discount) OVER(PARTITION BY pd.category_id,pd.segment_id)::decimal/
 	SUM((s.qty*s.price)-discount) OVER(PARTITION BY pd.category_id)::decimal)*100,2) AS percentage_seg
FROM product_details pd 
JOIN sales s ON pd.product_id = s.prod_id
ORDER BY pd.category_id, pd.segment_id;


---What is the percentage split of total revenue by category?
SELECT DISTINCT pd.category_id, pd.category_name, 
SUM((s.qty*s.price)-discount) OVER() AS total_revenue, 
SUM((s.qty*s.price)-discount) OVER(PARTITION BY pd.category_id) AS revenue_categ,
ROUND((SUM((s.qty*s.price)-discount) OVER(PARTITION BY pd.category_id)::decimal/
 	SUM((s.qty*s.price)-discount) OVER()::decimal)*100,2) AS percentage_categ
FROM product_details pd 
JOIN sales s ON pd.product_id = s.prod_id
ORDER BY pd.category_id;




















