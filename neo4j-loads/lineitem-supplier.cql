-- CREATE LINEITEM (id: O_ORDERKEY)

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS 
FROM "file:///C:/datacsv/lineitem.csv" AS line FIELDTERMINATOR ';',
SPLIT(line.L_SHIPDATE,'/') AS SHIPDATE,
SPLIT(line.L_COMMITDATE,'/') AS COMMITDATE,
SPLIT(line.L_RECEIPTDATE,'/') AS RECEIPTDATE

CREATE (lineItem:LINEITEM)
SET lineItem.L_ORDERKEY = toInteger(line.L_ORDERKEY),
    lineItem.L_PARTKEY = toInteger(line.L_PARTKEY),	
    lineItem.L_SUPPKEY = toInteger(line.L_SUPPKEY),
    lineItem.L_LINENUMBER = toInteger(line.L_LINENUMBER),
    lineItem.L_QUANTITY = toFloat(line.L_QUANTITY),
    lineItem.L_EXTENDEDPRICE = toFloat(line.L_EXTENDEDPRICE),
    lineItem.L_DISCOUNT = toFloat(line.L_DISCOUNT),
    lineItem.L_TAX = toFloat(line.L_TAX),
    lineItem.L_RETURNFLAG = line.L_RETURNFLAG,
    lineItem.L_LINESTATUS = line.L_LINESTATUS,
    lineItem.L_DISCOUNT = line.L_DISCOUNT,
    lineItem.L_SHIPDATE = line.L_SHIPDATE,
    lineItem.L_COMMITDATE = line.L_COMMITDATE,
    lineItem.L_DISCOUNT = line.L_DISCOUNT,
    lineItem.L_RECEIPTDATE = line.L_RECEIPTDATE,
    lineItem.L_SHIPINSTRUCT = line.L_SHIPINSTRUCT,
    lineItem.L_SHIPMODE = line.L_SHIPMODE,
    lineItem.L_COMMENT = line.L_COMMENT,
    lineItem.L_SHIPDATE_DAY = TOINT(SHIPDATE[0]),
    lineItem.L_SHIPDATE_MONTH = TOINT(SHIPDATE[1]),
    lineItem.L_SHIPDATE_YEAR = TOINT(SHIPDATE[2]),
    lineItem.L_COMMITDATE_DAY = TOINT(COMMITDATE[0]),
    lineItem.L_COMMITDATE_MONTH = TOINT(COMMITDATE[1]),
    lineItem.L_COMMITDATE_YEAR =TOINT(COMMITDATE[2]),
    lineItem.L_RECEIPTDATE_DAY = TOINT(RECEIPTDATE[0]),
    lineItem.L_RECEIPTDATE_MONTH = TOINT(RECEIPTDATE[1]),
    lineItem.L_RECEIPTDATE_YEAR = TOINT(RECEIPTDATE[2]),
    
    
-- LINEITEM (L_SUPPKEY) -> SUPPLIER (S_SUPPKEY)

CREATE INDEX ON :LINEITEM(L_SUPPKEY)
CREATE INDEX ON :LINEITEM(L_ORDERKEY)
CREATE INDEX ON :LINEITEM(L_PARTKEY)
CREATE INDEX ON :LINEITEM(L_LINENUMBER)


USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///C:/datacsv/lineitem_innerjoin_supplier.csv" AS row FIELDTERMINATOR ';'
MATCH (lineitem:LINEITEM {L_ORDERKEY: toInteger(row.L_ORDERKEY), L_PARTKEY: toInteger(row.L_PARTKEY), L_SUPPKEY: toInteger(row.L_SUPPKEY),L_LINENUMBER: toInteger(row.L_LINENUMBER)  })
MATCH (supplier:SUPPLIER {id: toInteger(row.L_SUPPKEY)})
MERGE (lineitem)-[:SUPPLIED_BY_9]->(supplier);