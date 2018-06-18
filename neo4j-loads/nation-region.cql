-- CREATE REGION (id: R_REGIONKEY)

CREATE CONSTRAINT ON (r:REGION) ASSERT r.id IS UNIQUE;

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS 
FROM "file:///C:/datacsv/region.csv" AS line FIELDTERMINATOR ';'

CREATE (region:REGION { id: TOINTEGER(line.R_REGIONKEY) })
SET region.R_NAME = line.R_NAME,	
    region.R_COMMENT = line.R_COMMENT


-- NATION (N_REGIONKEY) -> REGION (R_REGIONKEY)

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///C:/datacsv/nation_innerjoin_region.csv" AS row FIELDTERMINATOR ';'
MATCH (nation:NATION {id: toInteger(row.N_NATIONKEY)})
MATCH (region:REGION {id: toInteger(row.N_REGIONKEY)})
MERGE (nation)-[:FROM_10]->(region);