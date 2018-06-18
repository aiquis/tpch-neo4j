-- CREATE PARTSUPP (id: PS_PARTKEY)

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS 
FROM "file:///C:/datacsv/partsupp.csv" AS line FIELDTERMINATOR ';'

CREATE (partsupp:PARTSUPP { PS_PARTKEY: TOINTEGER(line.PS_PARTKEY) })
SET partsupp.PS_SUPPKEY = TOINTEGER(line.PS_SUPPKEY),
    partsupp.PS_AVAILQTY = TOINTEGER(line.PS_AVAILQTY),	
    partsupp.PS_SUPPLYCOST = TOFLOAT(line.PS_SUPPLYCOST),
    partsupp.PS_COMMENT = line.PS_COMMENT

-- CREATE PART (id: P_PARTKEY)

CREATE CONSTRAINT ON (p:PART) ASSERT p.id IS UNIQUE;

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS 
FROM "file:///C:/datacsv/part.csv" AS line FIELDTERMINATOR ';'

CREATE (part:PART { id: TOINTEGER(line.P_PARTKEY) })
SET part.P_NAME =line.P_NAME,
    part.P_MFGR = line.P_MFGR,	
    part.P_BRAND = line.P_BRAND,
    part.P_TYPE = line.P_TYPE,
    part.P_SIZE = TOINTEGER(line.P_SIZE),
    part.P_CONTAINER = line.P_CONTAINER,
    part.P_RETAILPRICE =TOFLOAT( line.P_RETAILPRICE),
    part.P_COMMENT = line.P_COMMENT

-- PARTSUPP (PS_PARTKEY) -> PART (P_PARTKEY)

CREATE INDEX ON :PARTSUPP(PS_PARTKEY)

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///C:/datacsv/part_innerjoin_partsupp.csv" AS row FIELDTERMINATOR ';'
MATCH (partsupp:PARTSUPP {PS_PARTKEY: toInteger(row.P_PARTKEY)})
MATCH (part:PART {id: toInteger(row.P_PARTKEY)})
MERGE (partsupp)-[:COMPOSED_BY_2]->(part);
