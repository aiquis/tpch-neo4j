-- LINEITEM (L_PARTKEY) -> PART (P_PARTKEY)

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///C:/datacsv/lineitem_innerjoin_part.csv" AS row FIELDTERMINATOR ';'
MATCH (lineitem:LINEITEM {L_ORDERKEY: toInteger(row.L_ORDERKEY), L_PARTKEY: toInteger(row.L_PARTKEY), L_SUPPKEY: toInteger(row.L_SUPPKEY),L_LINENUMBER: toInteger(row.L_LINENUMBER) })
MATCH (part:PART {id: toInteger(row.L_PARTKEY), P_NAME: row.P_NAME })
MERGE (lineitem)-[:COMPOSED_BY_8]->(part);
