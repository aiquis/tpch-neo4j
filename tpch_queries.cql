--Q1

WITH date('1998-12-01') - duration('P90D') AS my_date
MATCH (item:LINEITEM)
WHERE date(item.L_SHIPDATE) <= date(my_date)
RETURN item.L_RETURNFLAG,item.L_LINESTATUS,sum(item.L_QUANTITY) AS sum_qty, sum(item.L_EXTENDEDPRICE) AS sum_base_price, sum(item.L_EXTENDEDPRICE*(1-item.L_DISCOUNT)) AS sum_disc_price,sum(item.L_EXTENDEDPRICE*(1-item.L_DISCOUNT)*(1+item.L_TAX)) AS sum_charge,avg(item.L_QUANTITY) AS avg_qty, avg(item.L_EXTENDEDPRICE) AS avg_price, avg(item.L_DISCOUNT) AS avg_disc, COUNT(*) AS count_order
ORDER BY item.L_RETURNFLAG, item.L_LINESTATUS;

--Q2

MATCH (p:PARTSUPP)-[:SUPPLIED_BY]->(s:SUPPLIER)-[:BELONG_TO]->(n:NATION)-[:IS_FROM]->(r:REGION) 
where r.R_NAME = 'EUROPE' with p, min(p.PS_SUPPLYCOST) as minvalue
MATCH (ps:PARTSUPP)-[:COMPOSED_BY]->(p:PART)
MATCH (ps:PARTSUPP)-[:SUPPLIED_BY]->(s:SUPPLIER)-[:BELONG_TO]->(n:NATION)-[:IS_FROM]->(r:REGION)
where p.P_SIZE = 15 and p.P_TYPE =~ '.*BRASS.*' and r.R_NAME = 'EUROPE' and p.PS_SUPPLYCOST = minvalue
return p.id,p.P_MFGR,s.S_ACCTBAL,s.S_NAME,s.S_ADDRESS,s.S_PHONE,s.S_COMMENT,n.N_NAME
order by s.S_ACCTBAL desc,n.N_NAME,s.S_NAME,p.id;

--Q3

MATCH (lineitem:LINEITEM)-[:IS_PART_OF]->(order:ORDER)-[:MADE_BY]->(customer:CUSTOMER)
WHERE customer.C_MKTSEGMENT = 'BUILDING' AND date(order.O_ORDERDATE) < date('1995-03-15') AND date(lineitem.L_SHIPDATE) > date('1995-03-15')
RETURN order.id, sum(lineitem.L_EXTENDEDPRICE*(1-lineitem.L_DISCOUNT)) AS REVENUE, order.O_ORDERDATE, order.O_SHIPPRIORITY
ORDER BY REVENUE DESC, order.O_ORDERDATE
LIMIT 10;

--Q4

WITH date('1993-07-01') + duration('P3M') AS my_date
MATCH (lineitem: LINEITEM)-[:IS_PART_OF]->(order: ORDER)
WHERE  date(lineitem.L_COMMITDATE) < date(lineitem.L_RECEIPTDATE) AND date(order.O_ORDERDATE) >= date('1993-07-01') AND date(order.O_ORDERDATE) < date(my_date)
RETURN order.O_ORDERPRIORITY, COUNT(*) AS ORDER_COUNT
ORDER BY order.O_ORDERPRIORITY;


--Q5

WITH date('1994-01-01') + duration('P1Y') AS my_date
MATCH (lineitem: LINEITEM)-[:IS_PART_OF]->(order: ORDER)-[:MADE_BY]->(customer: CUSTOMER)-[:BELONG_TO]->(nation: NATION)-[:IS_FROM]-(region: REGION)
WHERE region.R_NAME = 'ASIA' AND date(order.O_ORDERDATE) >= date('1994-01-01') AND date(order.O_ORDERDATE) < date(my_date)
RETURN nation.N_NAME, SUM(lineitem.L_EXTENDEDPRICE * (1 - lineitem.L_DISCOUNT)) AS REVENUE
ORDER BY REVENUE DESC;

--Q6
MATCH (li:LINEITEM)
WHERE date(li.L_SHIPDATE) >= date('1994-01-01')
AND date(li.L_SHIPDATE) < date('1995-01-01')
AND tofloat(li.L_DISCOUNT) > 0.06 - 0.01
AND tofloat(li.L_DISCOUNT) < 0.06 + 0.01
AND li.L_QUANTITY < 24
RETURN sum(li.L_EXTENDEDPRICE * tofloat(li.L_DISCOUNT)) as revenue;

--Q7

MATCH (li:LINEITEM)-[:SUPPLIED_BY]->(s:SUPPLIER)-[:BELONG_TO]->(n1:NATION)
MATCH (li:LINEITEM)-[:IS_PART_OF]->(o:ORDER)-[:MADE_BY]->(c:CUSTOMER)-[:BELONG_TO]->(n2:NATION) 
WHERE (n1.N_NAME = 'FRANCE'and n2.N_NAME = 'GERMANY')
or (n1.N_NAME = 'GERMANY' and n2.N_NAME = 'FRANCE')
AND date(li.L_SHIPDATE) > date('1995-01-01')
AND date(li.L_SHIPDATE) < date('1996-12-31')
RETURN n1.N_NAME as supp_nation ,n2.N_NAME as cust_nation, date(li.L_SHIPDATE).year as l_year, sum(li.L_EXTENDEDPRICE * (1-tofloat(li.L_DISCOUNT))) as volume
order by supp_nation, cust_nation, l_year;

--Q8

MATCH (li:LINEITEM)-[:COMPOSED_BY]->(p:PART)
MATCH (li:LINEITEM)-[:SUPPLIED_BY]->(s:SUPPLIER)-[:BELONG_TO]->(n2:NATION)
MATCH (li:LINEITEM)-[:IS_PART_OF]->(o:ORDER)-[:MADE_BY]->(c:CUSTOMER)-[:BELONG_TO]->(n1:NATION)
MATCH (n2:NATION)-[:IS_FROM]->(r:REGION)
MATCH (n1:NATION)-[:IS_FROM]->(r:REGION)
WHERE r.R_NAME = 'AMERICA'
AND date(o.O_ORDERDATE) > date('1995-01-01')
AND date(o.O_ORDERDATE) < date('1996-12-31')
AND p.P_TYPE = 'ECONOMY ANODIZED STEEL'
WITH o,li,n2, date(o.O_ORDERDATE) as o_year, sum(li.L_EXTENDEDPRICE * (1-tofloat(li.L_DISCOUNT))) as volume, n2.N_NAME as nation
return distinct o_year,
sum(CASE WHEN n2.N_NAME = 'BRAZIL'
    THEN volume
    ELSE 0 END) /volume as mkt_share
order by o_year;

--Q9

MATCH (li:LINEITEM)-[:SUPPLIED_BY]->(s:SUPPLIER) 
MATCH (ps:PARTSUPP)-[:SUPPLIED_BY]->(s:SUPPLIER)
MATCH (ps:PARTSUPP)-[:COMPOSED_BY]->(p:PART)
MATCH (s:SUPPLIER)-[:BELONG_TO]->(n:NATION)
MATCH (li:LINEITEM)-[:IS_PART_OF]->(o:ORDER)
where p.P_NAME contains 'green'
with li,ps,n,o 
order by n.N_NAME desc, date(o.O_ORDERDATE).year
return n.N_NAME as nation, date(o.O_ORDERDATE).year as year,
sum(tofloat(li.L_EXTENDEDPRICE) * (1 -tofloat(li.L_DISCOUNT))-ps.PS_SUPPLYCOST * li.L_QUANTITY) as amount;

--Q10

MATCH (li:LINEITEM)-[:IS_PART_OF]->(o:ORDER)-[:MADE_BY]->(c:CUSTOMER)-[:BELONG_TO]->(n:NATION)
where date(o.O_ORDERDATE) >= date('1993-10-01')
and date(o.O_ORDERDATE) < date('1994-01-01')
and li.L_RETURNFLAG = 'R'
return c.id,c.C_NAME, c.C_ACCTBAL, n.N_NAME, c.C_ADDRESS, c.C_PHONE, c.C_COMMENT, sum(tofloat(li.L_EXTENDEDPRICE) * (1-tofloat(li.L_DISCOUNT))) as revenue
order by revenue desc
LIMIT 20;

--Q11

MATCH (p:PARTSUPP)-[:SUPPLIED_BY]->(s:SUPPLIER)-[:BELONG_TO]->(n:NATION)
WHERE n.N_NAME = 'GERMANY'
with p, sum(tofloat(p.PS_SUPPLYCOST) * tofloat(p.PS_AVAILQTY)) * 0.0001 as subquery, sum(tofloat(p.PS_SUPPLYCOST) * tofloat(p.PS_AVAILQTY)) as value 
MATCH (p:PARTSUPP)-[:SUPPLIED_BY]->(s:SUPPLIER)-[:BELONG_TO]->(n:NATION)
WHERE n.N_NAME = 'GERMANY' AND value > subquery
RETURN p.PS_PARTKEY, value
order by value desc;

--Q12

MATCH (li:LINEITEM)-[:IS_PART_OF]->(o:ORDER)
WHERE toUpper(li.L_SHIPMODE) in ['MAIL','SHIP'] and 
date(li.L_COMMITDATE) < date(li.L_RECEIPTDATE)
and date(li.L_SHIPDATE) < date(li.L_COMMITDATE)
and date(li.L_RECEIPTDATE) >= date('1994-01-01')
and date(li.L_RECEIPTDATE) < date('1995-01-01')
RETURN 
	li.L_SHIPMODE,
    sum(CASE WHEN o.O_ORDERPRIORITY IN ['1-URGENT','2-HIGH']
    THEN 1
    ELSE 0 END) as high_line_count,
    sum(CASE WHEN o.O_ORDERPRIORITY IN ['3-MEDIUM','4-NOT SPECIFIED','5-LOW']
    THEN 1
    ELSE 0 END) as low_line_count
 order by li.L_SHIPMODE;

--Q13

MATCH (order: ORDER)
OPTIONAL MATCH (order: ORDER)-[:MADE_BY]->(customer: CUSTOMER)
WHERE NOT (order.O_COMMENT =~ '.*special.*.*requests.*')
WITH customer.id AS c_id, COUNT(order.id) AS c_count 
RETURN c_count, COUNT(c_id) AS custdist
ORDER BY custdist DESC, c_count DESC;

--Q14

WITH date('1995-09-01') + duration('P1M') AS my_date
MATCH (item: LINEITEM)-[:COMPOSED_BY]->(part: PART)
WHERE date(item.L_SHIPDATE) >= date('1995-09-01') AND date(item.L_SHIPDATE) < date(my_date)
RETURN 100 * SUM(CASE WHEN part.P_TYPE =~ '.*PROMO.*' THEN item.L_EXTENDEDPRICE*(1 - item.L_DISCOUNT) ELSE 0 END) / SUM(item.L_EXTENDEDPRICE * (1 - item.L_DISCOUNT)) AS PROMO_REVENUE;

--Q15

--Q16

MATCH (s:SUPPLIER) WHERE s.S_COMMENT =~ '.*Customer.*.*Complaints.*' WITH s, s.id as p_id
MATCH (ps:PARTSUPP)-[:COMPOSED_BY]->(p:PART)
WHERE p.P_BRAND <> 'Brand#45' 
and NOT (p.P_TYPE =~ '.MEDIUM POLISHED.*')
and p.P_SIZE in [49,14,23,45,19,3,36,9]
and NOT ps.PS_SUPPKEY IN p_id
RETURN p.P_BRAND,p.P_TYPE,p.P_SIZE,count(distinct ps.PS_SUPPKEY) as supplier_cnt
order by supplier_cnt desc, p.P_BRAND, p.P_TYPE, p.P_SIZE;

--Q17

MATCH (lineitem: LINEITEM)-[:COMPOSED_BY]->(part: PART)
WITH 0.2 * AVG(lineitem.L_QUANTITY) AS L_QUANTITY
MATCH (item: LINEITEM)-[:COMPOSED_BY]->(part: PART)
WHERE part.P_BRAND = 'Brand#23' AND part.P_CONTAINER = 'MED BOX' AND item.L_QUANTITY < L_QUANTITY
RETURN SUM(item.L_EXTENDEDPRICE)/7.0 AS avg_yearly;


--Q18

MATCH (lineitem: LINEITEM)
WITH lineitem.L_ORDERKEY as l_orderkey, SUM(lineitem.L_QUANTITY) AS sum_lquantity
WHERE sum_lquantity > 300
MATCH (item: LINEITEM)-[:IS_PART_OF]->(order: ORDER)-[:MADE_BY]->(customer: CUSTOMER)
WHERE order.id IN [l_orderkey]
RETURN customer.C_NAME, customer.id, order.id, order.O_ORDERDATE, order.O_TOTALPRICE, SUM(item.L_QUANTITY)
ORDER BY order.O_TOTALPRICE desc, order.O_ORDERDATE
LIMIT 100;


--Q19

MATCH (lineitem: LINEITEM)-[:COMPOSED_BY]->(part: PART)
WHERE (part.P_BRAND = 'Brand#12'
		and part.P_CONTAINER in ['SM CASE', 'SM BOX', 'SM PACK', 'SM PKG']
		and lineitem.L_QUANTITY >= 1 and lineitem.L_QUANTITY <= 1 + 10
		and part.P_SIZE > 1 and part.P_SIZE < 5
		and lineitem.L_SHIPMODE in ['AIR', 'AIR REG']
		and lineitem.L_SHIPINSTRUCT = 'DELIVER IN PERSON')
OR (part.P_BRAND = 'Brand#23'
		and part.P_CONTAINER in ['MED BAG', 'MED BOX', 'MED PKG', 'MED PACK']
		and lineitem.L_QUANTITY >= 10 and lineitem.L_QUANTITY <= 10 + 10
		and part.P_SIZE > 1 and part.P_SIZE < 10
		and lineitem.L_SHIPMODE in ['AIR', 'AIR REG']
		and lineitem.L_SHIPINSTRUCT = 'DELIVER IN PERSON')
OR (part.P_BRAND = 'Brand#34'
		and part.P_CONTAINER in ['LG CASE', 'LG BOX', 'LG PACK', 'LG PKG']
		and lineitem.L_QUANTITY >= 20 and lineitem.L_QUANTITY <= 20 + 10
		and part.P_SIZE > 1 and part.P_SIZE < 15
		and lineitem.L_SHIPMODE in ['AIR', 'AIR REG']
		and lineitem.L_SHIPINSTRUCT = 'DELIVER IN PERSON')
RETURN SUM(lineitem.L_EXTENDEDPRICE * (1 - lineitem.L_DISCOUNT)) AS revenue;