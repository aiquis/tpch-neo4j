-- PARTSUPP (PS_SUPPKEY) -> SUPPLIER (S_SUPPKEY)

CREATE INDEX ON :PARTSUPP(PS_SUPPKEY)
CREATE INDEX ON :PARTSUPP(PS_PARTKEY)

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///C:/datacsv/supplier_innerjoin_partsupp.csv" AS row FIELDTERMINATOR ';'
MATCH (partsupp:PARTSUPP {PS_PARTKEY:toInteger(row.PS_PARTKEY) , PS_SUPPKEY: toInteger(row.PS_SUPPKEY)}) 
MATCH (supplier:SUPPLIER {id: toInteger(row.PS_SUPPKEY)})
MERGE (partsupp)-[:SUPPLIED_BY_3]->(supplier);
