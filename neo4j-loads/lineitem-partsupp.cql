-- LINEITEM (PS_ID) -> PARTSUPP (PS_ID)

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///C:/datacsv/lineitem_innerjoin_partsupp.csv" AS row FIELDTERMINATOR ';'
MATCH (lineitem:LINEITEM {L_ORDERKEY: toInteger(row.L_ORDERKEY), L_PARTKEY: toInteger(row.L_PARTKEY), L_SUPPKEY: toInteger(row.L_SUPPKEY),L_LINENUMBER: toInteger(row.L_LINENUMBER) })
MATCH (partsupp:PARTSUPP {PS_PARTKEY:toInteger(row.PS_PARTKEY) , PS_SUPPKEY: toInteger(row.PS_SUPPKEY)})
MERGE (lineitem)-[:COMPOSED_BY_6]->(partsupp);
