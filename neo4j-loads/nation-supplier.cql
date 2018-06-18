-- CREATE NATION (id: N_NATIONKEY)

CREATE CONSTRAINT ON (n:NATION) ASSERT n.id IS UNIQUE;

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS 
FROM "file:///C:/datacsv/nation.csv" AS line FIELDTERMINATOR ';'

CREATE (nation:NATION { id: TOINTEGER(line.N_NATIONKEY) })
SET nation.N_NAME = line.N_NAME,
	nation.N_REGIONKEY = line.N_REGIONKEY,
    nation.N_COMMENT = line.N_COMMENT


-- CREATE SUPLIER (id: S_SUPPKEY)

CREATE CONSTRAINT ON (s:SUPPLIER) ASSERT s.id IS UNIQUE;

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS 
FROM "file:///C:/datacsv/supplier.csv" AS line FIELDTERMINATOR ';'

CREATE (supplier:SUPPLIER { id: TOINTEGER(line.S_SUPPKEY) })
SET supplier.S_NAME = line.S_NAME,
	supplier.S_ADDRESS = line.S_ADDRESS,
    supplier.S_NATIONKEY = line.S_NATIONKEY,
    supplier.S_PHONE = line.S_PHONE,
    supplier.S_ACCTBAL = line.S_ACCTBAL,
    supplier.S_COMMENT = line.S_COMMENT

-- SUPPLIER (S_NATIONKEY) -> NATION (N_NATIONKEY)

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///C:/datacsv/nation_innerjoin_supplier.csv" AS row FIELDTERMINATOR ';'
MATCH (supplier:SUPPLIER {id: toInteger(row.S_SUPPKEY)})
MATCH (nation:NATION {id: toInteger(row.S_NATIONKEY)})
MERGE (supplier)-[:BELONGS_TO_1]->(nation);