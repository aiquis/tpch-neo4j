-- LINEITEM (L_ORDERKEY) -> ORDER (O_ORDERKEY)

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///C:/datacsv/lineitem_innerjoin_orders.csv" AS row FIELDTERMINATOR ';'
MATCH (lineitem:LINEITEM {L_ORDERKEY: toInteger(row.L_ORDERKEY), L_PARTKEY: toInteger(row.L_PARTKEY), L_SUPPKEY: toInteger(row.L_SUPPKEY),L_LINENUMBER: toInteger(row.L_LINENUMBER) })
MATCH (orders:ORDER {id: toInteger(row.L_ORDERKEY), O_CUSTKEY: toInteger(row.O_CUSTKEY)})
MERGE (lineitem)-[:BELONGS_TO_7]->(orders);
