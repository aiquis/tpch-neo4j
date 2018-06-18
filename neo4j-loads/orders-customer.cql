
-- CREATE ORDER (id: O_ORDERKEY)

CREATE CONSTRAINT ON (o:ORDER) ASSERT o.id IS UNIQUE;

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS 
FROM "file:///C:/datacsv/orders.csv" AS line FIELDTERMINATOR ';'
WITH DISTINCT line, SPLIT(line.O_ORDERDATE, '/') AS date

CREATE (order:ORDER { id: TOINTEGER(line.O_ORDERKEY) })
SET order.O_CUSTKEY = TOINTEGER(line.O_CUSTKEY),
    order.O_ORDERSTATUS = line.O_ORDERSTATUS,	
    order.O_TOTALPRICE = TOFLOAT(line.O_TOTALPRICE),
    order.O_ORDERDATE = line.O_ORDERDATE,
    order.O_ORDERPRIORITY = line.O_ORDERPRIORITY,
    order.O_CLERK = line.O_CLERK,
    order.O_SHIPPRIORITY = line.O_SHIPPRIORITY,
    order.O_COMMENT = line.O_COMMENT,
    order.O_YEAR = TOINTEGER(date[2]),
    order.O_MONTH = TOINTEGER(date[1]),
    order.O_DAY = TOINTEGER(date[0])

-- ORDERS (O_CUSTKEY) -> CUSTOMER (C_CUSTKEY)

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///C:/datacsv/orders_innerjoin_customer.csv" AS row FIELDTERMINATOR ';'
MATCH (orders:ORDER {id: toInteger(row.O_ORDERKEY)})
MATCH (customer:CUSTOMER {id: toInteger(row.O_CUSTKEY)})
MERGE (orders)-[:BY_5]->(customer);
